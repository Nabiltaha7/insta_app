-- =====================================================
-- Instagram Clone - Database Usage Examples
-- =====================================================
-- هذا الملف يحتوي على أمثلة عملية لاستخدام قاعدة البيانات
-- مع بيانات تجريبية وسيناريوهات حقيقية
-- =====================================================

-- =====================================================
-- 1. إنشاء بيانات تجريبية
-- =====================================================

-- إنشاء مستخدمين تجريبيين
INSERT INTO public.users (id, username, full_name, bio, is_verified) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'ahmed_dev', 'أحمد المطور', 'مطور تطبيقات Flutter 📱', true),
('550e8400-e29b-41d4-a716-446655440002', 'sara_designer', 'سارة المصممة', 'مصممة UI/UX 🎨', false),
('550e8400-e29b-41d4-a716-446655440003', 'omar_photographer', 'عمر المصور', 'مصور فوتوغرافي محترف 📸', true),
('550e8400-e29b-41d4-a716-446655440004', 'layla_writer', 'ليلى الكاتبة', 'كاتبة ومدونة 📝', false),
('550e8400-e29b-41d4-a716-446655440005', 'khalid_chef', 'خالد الطباخ', 'شيف ومدرب طبخ 👨‍🍳', false);

-- إنشاء منشورات تجريبية
INSERT INTO public.posts (user_id, username, user_profile_image, is_user_verified, caption, media_urls, type, tags, likes_count, comments_count, views_count) VALUES
-- منشور نصي من أحمد
('550e8400-e29b-41d4-a716-446655440001', 'ahmed_dev', null, true, 
'بدأت العمل على تطبيق جديد بـ Flutter! متحمس جداً لمشاركة التقدم معكم 🚀', 
'{}', 'text', '{"flutter", "تطوير", "تطبيقات"}', 15, 3, 45),

-- منشور بصورة من سارة
('550e8400-e29b-41d4-a716-446655440002', 'sara_designer', null, false,
'تصميم جديد لواجهة تطبيق التسوق الإلكتروني. ما رأيكم؟ 🛍️',
'{"https://example.com/design1.jpg"}', 'image', '{"تصميم", "UI", "تسوق"}', 28, 7, 89),

-- منشور بصور متعددة من عمر
('550e8400-e29b-41d4-a716-446655440003', 'omar_photographer', null, true,
'جلسة تصوير رائعة في الصحراء اليوم! الطبيعة مذهلة 🏜️',
'{"https://example.com/desert1.jpg", "https://example.com/desert2.jpg", "https://example.com/desert3.jpg"}', 'carousel', '{"تصوير", "صحراء", "طبيعة"}', 42, 12, 156),

-- منشور نصي من ليلى
('550e8400-e29b-41d4-a716-446655440004', 'layla_writer', null, false,
'أفكار جديدة لمقال عن التكنولوجيا والمجتمع. أحب الكتابة في هذا المجال ✍️',
'{}', 'text', '{"كتابة", "تكنولوجيا", "مجتمع"}', 19, 5, 67),

-- منشور بصورة من خالد
('550e8400-e29b-41d4-a716-446655440005', 'khalid_chef', null, false,
'طبق جديد من المطبخ العربي! وصفة الكبسة بطريقة عصرية 🍛',
'{"https://example.com/kabsa.jpg"}', 'image', '{"طبخ", "كبسة", "مطبخ_عربي"}', 35, 9, 123);

-- إنشاء علاقات متابعة
INSERT INTO public.followers (follower_id, following_id) VALUES
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002'), -- أحمد يتابع سارة
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003'), -- أحمد يتابع عمر
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'), -- سارة تتابع أحمد
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003'), -- سارة تتابع عمر
('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'), -- عمر يتابع أحمد
('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001'), -- ليلى تتابع أحمد
('550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003'); -- خالد يتابع عمر

-- إنشاء إعجابات
INSERT INTO public.post_likes (post_id, user_id) 
SELECT p.id, u.id
FROM public.posts p
CROSS JOIN public.users u
WHERE p.username != u.username
AND random() > 0.6; -- 40% احتمال الإعجاب

-- إنشاء تعليقات
INSERT INTO public.comments (post_id, user_id, username, user_profile_image, is_user_verified, text) VALUES
-- تعليقات على منشور أحمد
((SELECT id FROM public.posts WHERE username = 'ahmed_dev' LIMIT 1), 
 '550e8400-e29b-41d4-a716-446655440002', 'sara_designer', null, false, 'رائع! متحمسة لرؤية النتيجة النهائية 👏'),

((SELECT id FROM public.posts WHERE username = 'ahmed_dev' LIMIT 1), 
 '550e8400-e29b-41d4-a716-446655440003', 'omar_photographer', null, true, 'Flutter خيار ممتاز للتطوير. بالتوفيق! 🚀'),

-- تعليقات على منشور سارة
((SELECT id FROM public.posts WHERE username = 'sara_designer' LIMIT 1), 
 '550e8400-e29b-41d4-a716-446655440001', 'ahmed_dev', null, true, 'تصميم جميل جداً! الألوان متناسقة 🎨'),

((SELECT id FROM public.posts WHERE username = 'sara_designer' LIMIT 1), 
 '550e8400-e29b-41d4-a716-446655440004', 'layla_writer', null, false, 'أحب البساطة في التصميم. عمل رائع! ✨'),

-- تعليقات على منشور عمر
((SELECT id FROM public.posts WHERE username = 'omar_photographer' LIMIT 1), 
 '550e8400-e29b-41d4-a716-446655440002', 'sara_designer', null, false, 'صور مذهلة! الإضاءة الطبيعية رائعة 📸'),

((SELECT id FROM public.posts WHERE username = 'omar_photographer' LIMIT 1), 
 '550e8400-e29b-41d4-a716-446655440005', 'khalid_chef', null, false, 'الصحراء جميلة في هذا الوقت من السنة 🏜️');

-- =====================================================
-- 2. أمثلة على الاستعلامات الشائعة
-- =====================================================

-- مثال 1: الحصول على الصفحة الرئيسية لمستخدم معين
-- (المنشورات من المستخدمين المتابعين + منشورات المستخدم نفسه)
SELECT 
    p.id,
    p.username,
    p.caption,
    p.type,
    p.media_urls,
    p.likes_count,
    p.comments_count,
    p.created_at,
    u.profile_image_url,
    u.is_verified,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.posts p
JOIN public.users u ON p.user_id = u.id
LEFT JOIN public.post_likes pl ON p.id = pl.post_id 
    AND pl.user_id = '550e8400-e29b-41d4-a716-446655440001' -- المستخدم الحالي
WHERE p.user_id IN (
    -- المستخدمين المتابعين
    SELECT following_id 
    FROM public.followers 
    WHERE follower_id = '550e8400-e29b-41d4-a716-446655440001'
    UNION
    -- المستخدم نفسه
    SELECT '550e8400-e29b-41d4-a716-446655440001'
)
ORDER BY p.created_at DESC
LIMIT 10;

-- مثال 2: البحث عن المستخدمين
SELECT 
    u.id,
    u.username,
    u.full_name,
    u.profile_image_url,
    u.is_verified,
    u.followers_count,
    u.posts_count,
    CASE 
        WHEN f.follower_id IS NOT NULL THEN true 
        ELSE false 
    END as is_following
FROM public.users u
LEFT JOIN public.followers f ON u.id = f.following_id 
    AND f.follower_id = '550e8400-e29b-41d4-a716-446655440001' -- المستخدم الحالي
WHERE u.username ILIKE '%dev%' 
   OR u.full_name ILIKE '%مطور%'
ORDER BY u.followers_count DESC, u.username;

-- مثال 3: الحصول على تعليقات منشور مع الردود
WITH main_comments AS (
    SELECT 
        c.*,
        CASE 
            WHEN '550e8400-e29b-41d4-a716-446655440001' = ANY(c.liked_by) THEN true 
            ELSE false 
        END as is_liked_by_current_user
    FROM public.comments c
    WHERE c.post_id = (SELECT id FROM public.posts WHERE username = 'sara_designer' LIMIT 1)
    AND c.parent_comment_id IS NULL
    ORDER BY c.created_at ASC
),
replies AS (
    SELECT 
        c.*,
        CASE 
            WHEN '550e8400-e29b-41d4-a716-446655440001' = ANY(c.liked_by) THEN true 
            ELSE false 
        END as is_liked_by_current_user
    FROM public.comments c
    WHERE c.parent_comment_id IN (SELECT id FROM main_comments)
    ORDER BY c.created_at ASC
)
SELECT * FROM main_comments
UNION ALL
SELECT * FROM replies
ORDER BY created_at ASC;

-- مثال 4: إحصائيات مستخدم
SELECT 
    u.username,
    u.full_name,
    u.posts_count,
    u.followers_count,
    u.following_count,
    -- إجمالي الإعجابات على جميع المنشورات
    COALESCE(SUM(p.likes_count), 0) as total_likes_received,
    -- إجمالي التعليقات على جميع المنشورات
    COALESCE(SUM(p.comments_count), 0) as total_comments_received,
    -- متوسط الإعجابات لكل منشور
    CASE 
        WHEN u.posts_count > 0 THEN COALESCE(AVG(p.likes_count), 0)
        ELSE 0 
    END as avg_likes_per_post
FROM public.users u
LEFT JOIN public.posts p ON u.id = p.user_id
WHERE u.id = '550e8400-e29b-41d4-a716-446655440003' -- عمر المصور
GROUP BY u.id, u.username, u.full_name, u.posts_count, u.followers_count, u.following_count;

-- مثال 5: أكثر الهاشتاجز استخداماً
SELECT 
    unnest(tags) as hashtag,
    COUNT(*) as usage_count,
    COUNT(DISTINCT user_id) as unique_users
FROM public.posts 
WHERE created_at >= NOW() - INTERVAL '30 days'
AND array_length(tags, 1) > 0
GROUP BY hashtag
ORDER BY usage_count DESC
LIMIT 10;

-- مثال 6: اقتراحات المتابعة
-- (مستخدمين لا يتابعهم المستخدم الحالي ولكن يتابعهم أصدقاؤه)
SELECT 
    u.id,
    u.username,
    u.full_name,
    u.profile_image_url,
    u.is_verified,
    u.followers_count,
    COUNT(DISTINCT f2.follower_id) as mutual_followers_count,
    array_agg(DISTINCT u2.username) as mutual_followers_usernames
FROM public.users u
-- المستخدمين الذين يتابعهم أصدقاء المستخدم الحالي
JOIN public.followers f1 ON u.id = f1.following_id
-- أصدقاء المستخدم الحالي
JOIN public.followers f2 ON f1.follower_id = f2.following_id
JOIN public.users u2 ON f2.follower_id = u2.id
WHERE f2.follower_id = '550e8400-e29b-41d4-a716-446655440001' -- المستخدم الحالي
-- استبعاد المستخدم الحالي
AND u.id != '550e8400-e29b-41d4-a716-446655440001'
-- استبعاد المستخدمين المتابعين بالفعل
AND u.id NOT IN (
    SELECT following_id 
    FROM public.followers 
    WHERE follower_id = '550e8400-e29b-41d4-a716-446655440001'
)
GROUP BY u.id, u.username, u.full_name, u.profile_image_url, u.is_verified, u.followers_count
HAVING COUNT(DISTINCT f2.follower_id) >= 1
ORDER BY mutual_followers_count DESC, u.followers_count DESC
LIMIT 5;

-- =====================================================
-- 3. أمثلة على العمليات المتقدمة
-- =====================================================

-- مثال 7: تحديث إعجابات التعليق
DO $$
DECLARE
    comment_id UUID := (SELECT id FROM public.comments WHERE username = 'sara_designer' LIMIT 1);
    current_user_id UUID := '550e8400-e29b-41d4-a716-446655440001';
    current_liked_by TEXT[];
    new_liked_by TEXT[];
BEGIN
    -- الحصول على قائمة المعجبين الحالية
    SELECT liked_by INTO current_liked_by 
    FROM public.comments 
    WHERE id = comment_id;
    
    -- التحقق من وجود المستخدم في القائمة
    IF current_user_id::text = ANY(current_liked_by) THEN
        -- إزالة الإعجاب
        SELECT array_remove(current_liked_by, current_user_id::text) INTO new_liked_by;
        RAISE NOTICE 'تم إزالة الإعجاب';
    ELSE
        -- إضافة الإعجاب
        SELECT array_append(current_liked_by, current_user_id::text) INTO new_liked_by;
        RAISE NOTICE 'تم إضافة الإعجاب';
    END IF;
    
    -- تحديث التعليق
    UPDATE public.comments 
    SET 
        liked_by = new_liked_by,
        likes_count = array_length(new_liked_by, 1),
        updated_at = NOW()
    WHERE id = comment_id;
END $$;

-- مثال 8: إنشاء تقرير نشاط المستخدم
WITH user_activity AS (
    SELECT 
        '550e8400-e29b-41d4-a716-446655440001' as user_id,
        'posts' as activity_type,
        COUNT(*) as count,
        MAX(created_at) as last_activity
    FROM public.posts 
    WHERE user_id = '550e8400-e29b-41d4-a716-446655440001'
    AND created_at >= NOW() - INTERVAL '30 days'
    
    UNION ALL
    
    SELECT 
        '550e8400-e29b-41d4-a716-446655440001' as user_id,
        'comments' as activity_type,
        COUNT(*) as count,
        MAX(created_at) as last_activity
    FROM public.comments 
    WHERE user_id = '550e8400-e29b-41d4-a716-446655440001'
    AND created_at >= NOW() - INTERVAL '30 days'
    
    UNION ALL
    
    SELECT 
        '550e8400-e29b-41d4-a716-446655440001' as user_id,
        'likes' as activity_type,
        COUNT(*) as count,
        MAX(created_at) as last_activity
    FROM public.post_likes 
    WHERE user_id = '550e8400-e29b-41d4-a716-446655440001'
    AND created_at >= NOW() - INTERVAL '30 days'
)
SELECT 
    activity_type,
    count,
    last_activity,
    CASE 
        WHEN last_activity >= NOW() - INTERVAL '1 day' THEN 'نشط اليوم'
        WHEN last_activity >= NOW() - INTERVAL '7 days' THEN 'نشط هذا الأسبوع'
        WHEN last_activity >= NOW() - INTERVAL '30 days' THEN 'نشط هذا الشهر'
        ELSE 'غير نشط'
    END as activity_status
FROM user_activity
ORDER BY count DESC;

-- مثال 9: البحث المتقدم في المنشورات
SELECT 
    p.id,
    p.username,
    p.caption,
    p.type,
    p.likes_count,
    p.comments_count,
    p.tags,
    -- نقاط البحث
    (
        CASE WHEN p.caption ILIKE '%flutter%' THEN 3 ELSE 0 END +
        CASE WHEN 'flutter' = ANY(p.tags) THEN 5 ELSE 0 END +
        CASE WHEN p.username ILIKE '%dev%' THEN 2 ELSE 0 END +
        CASE WHEN p.is_user_verified THEN 1 ELSE 0 END
    ) as search_score
FROM public.posts p
WHERE (
    p.caption ILIKE '%flutter%' 
    OR 'flutter' = ANY(p.tags)
    OR p.username ILIKE '%dev%'
)
AND p.created_at >= NOW() - INTERVAL '90 days'
ORDER BY search_score DESC, p.likes_count DESC
LIMIT 10;

-- =====================================================
-- 4. أمثلة على التحليلات والإحصائيات
-- =====================================================

-- مثال 10: تحليل النمو الشهري
SELECT 
    DATE_TRUNC('month', created_at) as month,
    COUNT(*) as new_users,
    SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', created_at)) as cumulative_users
FROM public.users
WHERE created_at >= NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month;

-- مثال 11: أكثر المستخدمين تفاعلاً
SELECT 
    u.username,
    u.full_name,
    u.is_verified,
    -- عدد المنشورات
    COUNT(DISTINCT p.id) as posts_count,
    -- عدد التعليقات
    COUNT(DISTINCT c.id) as comments_count,
    -- عدد الإعجابات المعطاة
    COUNT(DISTINCT pl.id) as likes_given,
    -- إجمالي النقاط (منشور = 3 نقاط، تعليق = 2 نقطة، إعجاب = 1 نقطة)
    (COUNT(DISTINCT p.id) * 3 + COUNT(DISTINCT c.id) * 2 + COUNT(DISTINCT pl.id)) as engagement_score
FROM public.users u
LEFT JOIN public.posts p ON u.id = p.user_id
LEFT JOIN public.comments c ON u.id = c.user_id
LEFT JOIN public.post_likes pl ON u.id = pl.user_id
WHERE u.created_at >= NOW() - INTERVAL '30 days'
GROUP BY u.id, u.username, u.full_name, u.is_verified
HAVING engagement_score > 0
ORDER BY engagement_score DESC
LIMIT 10;

-- مثال 12: تحليل أوقات النشاط
SELECT 
    EXTRACT(hour FROM created_at) as hour_of_day,
    COUNT(*) as posts_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM public.posts
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY EXTRACT(hour FROM created_at)
ORDER BY hour_of_day;

-- =====================================================
-- 5. تنظيف البيانات التجريبية
-- =====================================================

-- حذف جميع البيانات التجريبية
-- تحذير: هذا سيحذف جميع البيانات!

/*
DELETE FROM public.post_likes WHERE user_id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440005'
);

DELETE FROM public.comments WHERE user_id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440005'
);

DELETE FROM public.followers WHERE follower_id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440005'
);

DELETE FROM public.posts WHERE user_id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440005'
);

DELETE FROM public.users WHERE id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440005'
);
*/

-- =====================================================
-- انتهاء أمثلة قاعدة البيانات
-- =====================================================