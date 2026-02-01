-- =====================================================
-- Instagram Clone - Database Maintenance & Utilities
-- =====================================================
-- هذا الملف يحتوي على استعلامات مفيدة لصيانة وإدارة قاعدة البيانات
-- =====================================================

-- =====================================================
-- 1. استعلامات التحقق من حالة قاعدة البيانات
-- =====================================================

-- التحقق من وجود جميع الجداول
SELECT 
    schemaname,
    tablename,
    tableowner,
    hasindexes,
    hasrules,
    hastriggers
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- التحقق من عدد السجلات في كل جدول
SELECT 
    'users' as table_name,
    COUNT(*) as record_count
FROM public.users
UNION ALL
SELECT 
    'posts' as table_name,
    COUNT(*) as record_count
FROM public.posts
UNION ALL
SELECT 
    'comments' as table_name,
    COUNT(*) as record_count
FROM public.comments
UNION ALL
SELECT 
    'post_likes' as table_name,
    COUNT(*) as record_count
FROM public.post_likes
UNION ALL
SELECT 
    'comment_likes' as table_name,
    COUNT(*) as record_count
FROM public.comment_likes
UNION ALL
SELECT 
    'followers' as table_name,
    COUNT(*) as record_count
FROM public.followers
ORDER BY table_name;

-- التحقق من الفهارس
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- =====================================================
-- 2. استعلامات الإحصائيات
-- =====================================================

-- إحصائيات المستخدمين
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN is_verified = true THEN 1 END) as verified_users,
    COUNT(CASE WHEN is_private = true THEN 1 END) as private_accounts,
    AVG(posts_count) as avg_posts_per_user,
    AVG(followers_count) as avg_followers_per_user,
    AVG(following_count) as avg_following_per_user
FROM public.users;

-- إحصائيات المنشورات
SELECT 
    COUNT(*) as total_posts,
    COUNT(CASE WHEN type = 'text' THEN 1 END) as text_posts,
    COUNT(CASE WHEN type = 'image' THEN 1 END) as image_posts,
    COUNT(CASE WHEN type = 'carousel' THEN 1 END) as carousel_posts,
    AVG(likes_count) as avg_likes_per_post,
    AVG(comments_count) as avg_comments_per_post,
    AVG(views_count) as avg_views_per_post,
    MAX(likes_count) as max_likes,
    MAX(comments_count) as max_comments
FROM public.posts;

-- إحصائيات التعليقات
SELECT 
    COUNT(*) as total_comments,
    COUNT(CASE WHEN parent_comment_id IS NULL THEN 1 END) as main_comments,
    COUNT(CASE WHEN parent_comment_id IS NOT NULL THEN 1 END) as replies,
    AVG(likes_count) as avg_likes_per_comment,
    MAX(likes_count) as max_comment_likes
FROM public.comments;

-- أكثر المستخدمين نشاطاً
SELECT 
    u.username,
    u.full_name,
    u.posts_count,
    u.followers_count,
    u.following_count,
    u.is_verified
FROM public.users u
ORDER BY u.posts_count DESC, u.followers_count DESC
LIMIT 10;

-- أكثر المنشورات شعبية
SELECT 
    p.id,
    p.username,
    p.caption,
    p.type,
    p.likes_count,
    p.comments_count,
    p.views_count,
    p.created_at
FROM public.posts p
ORDER BY p.likes_count DESC, p.comments_count DESC
LIMIT 10;

-- =====================================================
-- 3. استعلامات التنظيف والصيانة
-- =====================================================

-- حذف المنشورات القديمة (أكثر من سنة) بدون تفاعل
DELETE FROM public.posts 
WHERE created_at < NOW() - INTERVAL '1 year'
AND likes_count = 0 
AND comments_count = 0 
AND views_count < 10;

-- حذف التعليقات الفارغة أو المحذوفة
DELETE FROM public.comments 
WHERE text IS NULL OR text = '' OR text = '[deleted]';

-- تنظيف الإعجابات المكررة (في حالة وجود مشاكل)
DELETE FROM public.post_likes a
USING public.post_likes b
WHERE a.id < b.id
AND a.post_id = b.post_id
AND a.user_id = b.user_id;

DELETE FROM public.comment_likes a
USING public.comment_likes b
WHERE a.id < b.id
AND a.comment_id = b.comment_id
AND a.user_id = b.user_id;

-- تنظيف المتابعات المكررة
DELETE FROM public.followers a
USING public.followers b
WHERE a.id < b.id
AND a.follower_id = b.follower_id
AND a.following_id = b.following_id;

-- =====================================================
-- 4. استعلامات إعادة حساب العدادات
-- =====================================================

-- إعادة حساب عدد الإعجابات للمنشورات
UPDATE public.posts 
SET likes_count = (
    SELECT COUNT(*) 
    FROM public.post_likes 
    WHERE post_id = posts.id
);

-- إعادة حساب عدد التعليقات للمنشورات
UPDATE public.posts 
SET comments_count = (
    SELECT COUNT(*) 
    FROM public.comments 
    WHERE post_id = posts.id
);

-- إعادة حساب عدد الإعجابات للتعليقات
UPDATE public.comments 
SET likes_count = array_length(liked_by, 1);

-- إعادة حساب عدد المنشورات للمستخدمين
UPDATE public.users 
SET posts_count = (
    SELECT COUNT(*) 
    FROM public.posts 
    WHERE user_id = users.id
);

-- إعادة حساب عدد المتابعين
UPDATE public.users 
SET followers_count = (
    SELECT COUNT(*) 
    FROM public.followers 
    WHERE following_id = users.id
);

-- إعادة حساب عدد المتابعين
UPDATE public.users 
SET following_count = (
    SELECT COUNT(*) 
    FROM public.followers 
    WHERE follower_id = users.id
);

-- =====================================================
-- 5. استعلامات النسخ الاحتياطي والاستعادة
-- =====================================================

-- تصدير بيانات المستخدمين
COPY (
    SELECT id, username, full_name, bio, is_verified, posts_count, 
           followers_count, following_count, created_at
    FROM public.users
) TO '/tmp/users_backup.csv' WITH CSV HEADER;

-- تصدير بيانات المنشورات
COPY (
    SELECT id, user_id, username, caption, type, likes_count, 
           comments_count, views_count, created_at
    FROM public.posts
) TO '/tmp/posts_backup.csv' WITH CSV HEADER;

-- تصدير بيانات التعليقات
COPY (
    SELECT id, post_id, user_id, username, text, likes_count, 
           parent_comment_id, created_at
    FROM public.comments
) TO '/tmp/comments_backup.csv' WITH CSV HEADER;

-- =====================================================
-- 6. استعلامات الأمان والمراقبة
-- =====================================================

-- التحقق من سياسات RLS
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- مراقبة النشاط الحديث
SELECT 
    'posts' as activity_type,
    COUNT(*) as count,
    DATE(created_at) as date
FROM public.posts 
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
UNION ALL
SELECT 
    'comments' as activity_type,
    COUNT(*) as count,
    DATE(created_at) as date
FROM public.comments 
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
UNION ALL
SELECT 
    'likes' as activity_type,
    COUNT(*) as count,
    DATE(created_at) as date
FROM public.post_likes 
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY date DESC, activity_type;

-- البحث عن المحتوى المشبوه
SELECT 
    p.id,
    p.username,
    p.caption,
    p.likes_count,
    p.comments_count,
    p.created_at
FROM public.posts p
WHERE p.likes_count > 1000 
AND p.created_at > NOW() - INTERVAL '1 day'
ORDER BY p.likes_count DESC;

-- =====================================================
-- 7. استعلامات الأداء
-- =====================================================

-- تحليل أداء الاستعلامات
EXPLAIN ANALYZE 
SELECT p.*, u.username, u.profile_image_url
FROM public.posts p
JOIN public.users u ON p.user_id = u.id
ORDER BY p.created_at DESC
LIMIT 20;

-- إحصائيات استخدام الفهارس
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_tup_read DESC;

-- حجم الجداول
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- =====================================================
-- 8. استعلامات التطوير والاختبار
-- =====================================================

-- إنشاء بيانات تجريبية للمستخدمين
INSERT INTO public.users (id, username, full_name, bio, is_verified)
SELECT 
    gen_random_uuid(),
    'user_' || generate_series,
    'Test User ' || generate_series,
    'This is a test bio for user ' || generate_series,
    CASE WHEN generate_series % 10 = 0 THEN true ELSE false END
FROM generate_series(1, 100);

-- إنشاء بيانات تجريبية للمنشورات
INSERT INTO public.posts (user_id, username, caption, type, likes_count, comments_count)
SELECT 
    u.id,
    u.username,
    'Test post content ' || generate_series,
    CASE 
        WHEN generate_series % 3 = 0 THEN 'text'
        WHEN generate_series % 3 = 1 THEN 'image'
        ELSE 'carousel'
    END,
    floor(random() * 100),
    floor(random() * 20)
FROM public.users u
CROSS JOIN generate_series(1, 5)
LIMIT 500;

-- حذف البيانات التجريبية
DELETE FROM public.posts WHERE caption LIKE 'Test post content%';
DELETE FROM public.users WHERE username LIKE 'user_%';

-- =====================================================
-- 9. استعلامات التقارير
-- =====================================================

-- تقرير النشاط اليومي
SELECT 
    DATE(created_at) as date,
    COUNT(CASE WHEN table_name = 'posts' THEN 1 END) as new_posts,
    COUNT(CASE WHEN table_name = 'comments' THEN 1 END) as new_comments,
    COUNT(CASE WHEN table_name = 'users' THEN 1 END) as new_users
FROM (
    SELECT created_at, 'posts' as table_name FROM public.posts
    UNION ALL
    SELECT created_at, 'comments' as table_name FROM public.comments
    UNION ALL
    SELECT created_at, 'users' as table_name FROM public.users
) combined
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- تقرير أداء المحتوى
SELECT 
    p.username,
    COUNT(*) as total_posts,
    AVG(p.likes_count) as avg_likes,
    AVG(p.comments_count) as avg_comments,
    MAX(p.likes_count) as best_post_likes
FROM public.posts p
WHERE p.created_at >= NOW() - INTERVAL '30 days'
GROUP BY p.username
HAVING COUNT(*) >= 5
ORDER BY avg_likes DESC
LIMIT 20;

-- =====================================================
-- انتهاء ملف صيانة قاعدة البيانات
-- =====================================================