-- =====================================================
-- Instagram Clone - App Specific Queries
-- =====================================================
-- هذا الملف يحتوي على الاستعلامات المحددة التي يستخدمها التطبيق
-- مرتبة حسب الوظائف والشاشات
-- =====================================================

-- =====================================================
-- 1. استعلامات المصادقة والمستخدمين
-- =====================================================

-- إنشاء مستخدم جديد (يتم استدعاؤه بعد التسجيل في Supabase Auth)
INSERT INTO public.users (id, username, full_name, profile_image_url, bio)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (id) DO UPDATE SET
    username = EXCLUDED.username,
    full_name = EXCLUDED.full_name,
    profile_image_url = EXCLUDED.profile_image_url,
    bio = EXCLUDED.bio,
    updated_at = NOW();

-- الحصول على بيانات المستخدم الحالي
SELECT 
    id,
    username,
    full_name,
    profile_image_url,
    bio,
    is_verified,
    posts_count,
    followers_count,
    following_count,
    created_at
FROM public.users 
WHERE id = $1;

-- البحث عن المستخدمين
SELECT 
    id,
    username,
    full_name,
    profile_image_url,
    is_verified,
    followers_count
FROM public.users 
WHERE username ILIKE '%' || $1 || '%' 
   OR full_name ILIKE '%' || $1 || '%'
ORDER BY followers_count DESC, username
LIMIT 20;

-- تحديث الملف الشخصي
UPDATE public.users 
SET 
    username = $2,
    full_name = $3,
    profile_image_url = $4,
    bio = $5,
    updated_at = NOW()
WHERE id = $1;

-- =====================================================
-- 2. استعلامات المنشورات
-- =====================================================

-- الحصول على المنشورات للصفحة الرئيسية (الأحدث)
SELECT 
    p.*,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.posts p
LEFT JOIN public.post_likes pl ON p.id = pl.post_id AND pl.user_id = $1
ORDER BY p.created_at DESC
LIMIT $2 OFFSET $3;

-- الحصول على المنشورات الأكثر شعبية
SELECT 
    p.*,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user,
    (p.likes_count * 2 + p.comments_count * 3 + p.views_count * 0.1) as popularity_score
FROM public.posts p
LEFT JOIN public.post_likes pl ON p.id = pl.post_id AND pl.user_id = $1
WHERE p.created_at >= NOW() - INTERVAL '7 days'
ORDER BY popularity_score DESC, p.created_at DESC
LIMIT $2 OFFSET $3;

-- الحصول على منشور واحد
SELECT 
    p.*,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.posts p
LEFT JOIN public.post_likes pl ON p.id = pl.post_id AND pl.user_id = $2
WHERE p.id = $1;

-- الحصول على منشورات مستخدم معين
SELECT 
    p.*,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.posts p
LEFT JOIN public.post_likes pl ON p.id = pl.post_id AND pl.user_id = $2
WHERE p.user_id = $1
ORDER BY p.created_at DESC
LIMIT $3 OFFSET $4;

-- إنشاء منشور جديد
INSERT INTO public.posts (
    user_id, username, user_profile_image, is_user_verified,
    caption, media_urls, type, tags, location
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
RETURNING *;

-- حذف منشور
DELETE FROM public.posts 
WHERE id = $1 AND user_id = $2;

-- تحديث عدد المشاهدات
UPDATE public.posts 
SET views_count = views_count + 1 
WHERE id = $1;

-- =====================================================
-- 3. استعلامات الإعجابات
-- =====================================================

-- إضافة إعجاب لمنشور
INSERT INTO public.post_likes (post_id, user_id)
VALUES ($1, $2)
ON CONFLICT (post_id, user_id) DO NOTHING;

-- إزالة إعجاب من منشور
DELETE FROM public.post_likes 
WHERE post_id = $1 AND user_id = $2;

-- التحقق من إعجاب المستخدم بمنشور
SELECT EXISTS(
    SELECT 1 FROM public.post_likes 
    WHERE post_id = $1 AND user_id = $2
) as is_liked;

-- الحصول على قائمة المعجبين بمنشور
SELECT 
    u.id,
    u.username,
    u.full_name,
    u.profile_image_url,
    u.is_verified,
    pl.created_at as liked_at
FROM public.post_likes pl
JOIN public.users u ON pl.user_id = u.id
WHERE pl.post_id = $1
ORDER BY pl.created_at DESC
LIMIT $2 OFFSET $3;

-- =====================================================
-- 4. استعلامات التعليقات
-- =====================================================

-- الحصول على تعليقات منشور
SELECT 
    c.*,
    CASE 
        WHEN $2::text = ANY(c.liked_by) THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.comments c
WHERE c.post_id = $1 AND c.parent_comment_id IS NULL
ORDER BY c.created_at ASC;

-- الحصول على ردود تعليق
SELECT 
    c.*,
    CASE 
        WHEN $2::text = ANY(c.liked_by) THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.comments c
WHERE c.parent_comment_id = $1
ORDER BY c.created_at ASC;

-- إضافة تعليق جديد
INSERT INTO public.comments (
    post_id, user_id, username, user_profile_image, 
    is_user_verified, text, parent_comment_id
) VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- تحديث إعجابات التعليق
UPDATE public.comments 
SET 
    liked_by = $2,
    likes_count = array_length($2, 1),
    updated_at = NOW()
WHERE id = $1;

-- حذف تعليق
DELETE FROM public.comments 
WHERE id = $1 AND user_id = $2;

-- =====================================================
-- 5. استعلامات المتابعة
-- =====================================================

-- متابعة مستخدم
INSERT INTO public.followers (follower_id, following_id)
VALUES ($1, $2)
ON CONFLICT (follower_id, following_id) DO NOTHING;

-- إلغاء متابعة مستخدم
DELETE FROM public.followers 
WHERE follower_id = $1 AND following_id = $2;

-- التحقق من المتابعة
SELECT EXISTS(
    SELECT 1 FROM public.followers 
    WHERE follower_id = $1 AND following_id = $2
) as is_following;

-- الحصول على قائمة المتابعين
SELECT 
    u.id,
    u.username,
    u.full_name,
    u.profile_image_url,
    u.is_verified,
    u.followers_count,
    f.created_at as followed_at,
    CASE 
        WHEN f2.follower_id IS NOT NULL THEN true 
        ELSE false 
    END as is_following_back
FROM public.followers f
JOIN public.users u ON f.follower_id = u.id
LEFT JOIN public.followers f2 ON f2.follower_id = $2 AND f2.following_id = u.id
WHERE f.following_id = $1
ORDER BY f.created_at DESC
LIMIT $3 OFFSET $4;

-- الحصول على قائمة المتابعين
SELECT 
    u.id,
    u.username,
    u.full_name,
    u.profile_image_url,
    u.is_verified,
    u.followers_count,
    f.created_at as following_since,
    CASE 
        WHEN f2.follower_id IS NOT NULL THEN true 
        ELSE false 
    END as is_follower
FROM public.followers f
JOIN public.users u ON f.following_id = u.id
LEFT JOIN public.followers f2 ON f2.follower_id = u.id AND f2.following_id = $2
WHERE f.follower_id = $1
ORDER BY f.created_at DESC
LIMIT $3 OFFSET $4;

-- =====================================================
-- 6. استعلامات الإحصائيات
-- =====================================================

-- إحصائيات المستخدم
SELECT 
    posts_count,
    followers_count,
    following_count
FROM public.users 
WHERE id = $1;

-- إحصائيات منشور
SELECT 
    likes_count,
    comments_count,
    views_count,
    shares_count
FROM public.posts 
WHERE id = $1;

-- أكثر المنشورات إعجاباً للمستخدم
SELECT 
    id,
    caption,
    type,
    likes_count,
    comments_count,
    created_at
FROM public.posts 
WHERE user_id = $1
ORDER BY likes_count DESC
LIMIT 5;

-- =====================================================
-- 7. استعلامات البحث
-- =====================================================

-- البحث في المنشورات
SELECT 
    p.*,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user,
    ts_rank(to_tsvector('english', COALESCE(p.caption, '')), plainto_tsquery('english', $2)) as rank
FROM public.posts p
LEFT JOIN public.post_likes pl ON p.id = pl.post_id AND pl.user_id = $1
WHERE to_tsvector('english', COALESCE(p.caption, '')) @@ plainto_tsquery('english', $2)
   OR $2 = ANY(p.tags)
ORDER BY rank DESC, p.created_at DESC
LIMIT 20;

-- البحث في الهاشتاجز
SELECT 
    unnest(tags) as hashtag,
    COUNT(*) as usage_count
FROM public.posts 
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY hashtag
HAVING unnest(tags) ILIKE '%' || $1 || '%'
ORDER BY usage_count DESC
LIMIT 10;

-- =====================================================
-- 8. استعلامات التحديثات الفورية
-- =====================================================

-- الحصول على المنشورات الجديدة منذ وقت معين
SELECT 
    p.*,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.posts p
LEFT JOIN public.post_likes pl ON p.id = pl.post_id AND pl.user_id = $1
WHERE p.created_at > $2
ORDER BY p.created_at DESC;

-- الحصول على التعليقات الجديدة لمنشور
SELECT 
    c.*,
    CASE 
        WHEN $2::text = ANY(c.liked_by) THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.comments c
WHERE c.post_id = $1 AND c.created_at > $3
ORDER BY c.created_at ASC;

-- =====================================================
-- 9. استعلامات التنظيف والصيانة للتطبيق
-- =====================================================

-- تنظيف المنشورات المحذوفة (soft delete)
UPDATE public.posts 
SET caption = '[deleted]', media_urls = '{}' 
WHERE id = $1 AND user_id = $2;

-- إعادة حساب عدادات منشور معين
UPDATE public.posts 
SET 
    likes_count = (SELECT COUNT(*) FROM public.post_likes WHERE post_id = $1),
    comments_count = (SELECT COUNT(*) FROM public.comments WHERE post_id = $1)
WHERE id = $1;

-- إعادة حساب عدادات مستخدم معين
UPDATE public.users 
SET 
    posts_count = (SELECT COUNT(*) FROM public.posts WHERE user_id = $1),
    followers_count = (SELECT COUNT(*) FROM public.followers WHERE following_id = $1),
    following_count = (SELECT COUNT(*) FROM public.followers WHERE follower_id = $1)
WHERE id = $1;

-- =====================================================
-- 10. استعلامات الأمان والتحقق
-- =====================================================

-- التحقق من ملكية المنشور
SELECT EXISTS(
    SELECT 1 FROM public.posts 
    WHERE id = $1 AND user_id = $2
) as is_owner;

-- التحقق من ملكية التعليق
SELECT EXISTS(
    SELECT 1 FROM public.comments 
    WHERE id = $1 AND user_id = $2
) as is_owner;

-- التحقق من صحة المستخدم
SELECT EXISTS(
    SELECT 1 FROM public.users 
    WHERE id = $1
) as user_exists;

-- الحصول على معلومات المستخدم للتحقق
SELECT 
    id,
    username,
    is_verified,
    created_at
FROM public.users 
WHERE id = $1;

-- =====================================================
-- 11. استعلامات خاصة بالتطبيق
-- =====================================================

-- الحصول على المنشورات للمستخدمين المتابعين (Feed)
SELECT 
    p.*,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.posts p
LEFT JOIN public.post_likes pl ON p.id = pl.post_id AND pl.user_id = $1
WHERE p.user_id IN (
    SELECT following_id 
    FROM public.followers 
    WHERE follower_id = $1
) OR p.user_id = $1
ORDER BY p.created_at DESC
LIMIT $2 OFFSET $3;

-- اقتراحات المتابعة
SELECT 
    u.id,
    u.username,
    u.full_name,
    u.profile_image_url,
    u.is_verified,
    u.followers_count,
    COUNT(f.follower_id) as mutual_followers
FROM public.users u
LEFT JOIN public.followers f ON u.id = f.following_id
WHERE u.id != $1
  AND u.id NOT IN (
      SELECT following_id 
      FROM public.followers 
      WHERE follower_id = $1
  )
  AND f.follower_id IN (
      SELECT following_id 
      FROM public.followers 
      WHERE follower_id = $1
  )
GROUP BY u.id, u.username, u.full_name, u.profile_image_url, u.is_verified, u.followers_count
ORDER BY mutual_followers DESC, u.followers_count DESC
LIMIT 10;

-- =====================================================
-- انتهاء استعلامات التطبيق
-- =====================================================