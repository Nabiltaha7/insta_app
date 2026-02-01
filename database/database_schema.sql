-- =====================================================
-- Instagram Clone - Database Schema
-- =====================================================
-- هذا الملف يحتوي على جميع أكواد SQL لإنشاء جداول قاعدة البيانات
-- الخاصة بتطبيق Instagram Clone المطور بـ Flutter و Supabase
-- =====================================================

-- تفعيل Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret-here';

-- =====================================================
-- 1. جدول المستخدمين (users)
-- =====================================================
-- هذا الجدول يتم إنشاؤه تلقائياً بواسطة Supabase Auth
-- لكن نحتاج لإضافة حقول إضافية

-- إضافة حقول إضافية لجدول المستخدمين
ALTER TABLE auth.users 
ADD COLUMN IF NOT EXISTS username TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS profile_image_url TEXT,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS is_private BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS show_last_seen BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS allow_messages_from_everyone BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS posts_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0;

-- إنشاء جدول users منفصل للبيانات العامة
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT,
    profile_image_url TEXT,
    bio TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_private BOOLEAN DEFAULT FALSE,
    show_last_seen BOOLEAN DEFAULT TRUE,
    allow_messages_from_everyone BOOLEAN DEFAULT TRUE,
    posts_count INTEGER DEFAULT 0,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء فهرس على اسم المستخدم
CREATE INDEX IF NOT EXISTS idx_users_username ON public.users(username);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at);

-- تفعيل RLS على جدول المستخدمين
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول المستخدمين
CREATE POLICY "Users can view all profiles" ON public.users
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- 2. جدول المنشورات (posts)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    username TEXT NOT NULL,
    user_profile_image TEXT,
    is_user_verified BOOLEAN DEFAULT FALSE,
    caption TEXT,
    media_urls TEXT[] DEFAULT '{}',
    type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'carousel')),
    tags TEXT[] DEFAULT '{}',
    location TEXT,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    comments_enabled BOOLEAN DEFAULT TRUE,
    likes_visible BOOLEAN DEFAULT TRUE,
    is_premium_content BOOLEAN DEFAULT FALSE,
    has_priority_in_trending BOOLEAN DEFAULT FALSE,
    trending_score DECIMAL DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON public.posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON public.posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_trending_score ON public.posts(trending_score DESC);
CREATE INDEX IF NOT EXISTS idx_posts_likes_count ON public.posts(likes_count DESC);
CREATE INDEX IF NOT EXISTS idx_posts_type ON public.posts(type);

-- تفعيل RLS على جدول المنشورات
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول المنشورات
CREATE POLICY "Anyone can view posts" ON public.posts
    FOR SELECT USING (true);

CREATE POLICY "Users can insert own posts" ON public.posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON public.posts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" ON public.posts
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 3. جدول التعليقات (comments)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    username TEXT NOT NULL,
    user_profile_image TEXT,
    is_user_verified BOOLEAN DEFAULT FALSE,
    text TEXT NOT NULL,
    parent_comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    likes_count INTEGER DEFAULT 0,
    liked_by TEXT[] DEFAULT '{}',
    replies_count INTEGER DEFAULT 0,
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON public.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON public.comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON public.comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON public.comments(created_at);

-- تفعيل RLS على جدول التعليقات
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول التعليقات
CREATE POLICY "Anyone can view comments" ON public.comments
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert comments" ON public.comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON public.comments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON public.comments
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 4. جدول إعجابات المنشورات (post_likes)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.post_likes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON public.post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user_id ON public.post_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_created_at ON public.post_likes(created_at);

-- تفعيل RLS على جدول إعجابات المنشورات
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول إعجابات المنشورات
CREATE POLICY "Anyone can view post likes" ON public.post_likes
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can like posts" ON public.post_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike own likes" ON public.post_likes
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 5. جدول إعجابات التعليقات (comment_likes)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.comment_likes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(comment_id, user_id)
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_comment_likes_comment_id ON public.comment_likes(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_likes_user_id ON public.comment_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_comment_likes_created_at ON public.comment_likes(created_at);

-- تفعيل RLS على جدول إعجابات التعليقات
ALTER TABLE public.comment_likes ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول إعجابات التعليقات
CREATE POLICY "Anyone can view comment likes" ON public.comment_likes
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can like comments" ON public.comment_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike own comment likes" ON public.comment_likes
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 6. جدول المتابعين (followers)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.followers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    follower_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    following_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_followers_follower_id ON public.followers(follower_id);
CREATE INDEX IF NOT EXISTS idx_followers_following_id ON public.followers(following_id);
CREATE INDEX IF NOT EXISTS idx_followers_created_at ON public.followers(created_at);

-- تفعيل RLS على جدول المتابعين
ALTER TABLE public.followers ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول المتابعين
CREATE POLICY "Anyone can view followers" ON public.followers
    FOR SELECT USING (true);

CREATE POLICY "Users can follow others" ON public.followers
    FOR INSERT WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can unfollow others" ON public.followers
    FOR DELETE USING (auth.uid() = follower_id);

-- =====================================================
-- 7. جدول المشاركات (shares) - اختياري
-- =====================================================

CREATE TABLE IF NOT EXISTS public.shares (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    shared_to TEXT, -- 'story', 'direct', 'external'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_shares_post_id ON public.shares(post_id);
CREATE INDEX IF NOT EXISTS idx_shares_user_id ON public.shares(user_id);
CREATE INDEX IF NOT EXISTS idx_shares_created_at ON public.shares(created_at);

-- تفعيل RLS على جدول المشاركات
ALTER TABLE public.shares ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول المشاركات
CREATE POLICY "Anyone can view shares" ON public.shares
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can share posts" ON public.shares
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- 8. جدول الإشعارات (notifications) - اختياري
-- =====================================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    from_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    from_username TEXT,
    from_user_profile_image TEXT,
    type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow', 'mention', 'share')),
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);

-- تفعيل RLS على جدول الإشعارات
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول الإشعارات
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications" ON public.notifications
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- 9. إنشاء Storage Buckets
-- =====================================================

-- إنشاء bucket للوسائط
INSERT INTO storage.buckets (id, name, public)
VALUES ('media', 'media', true)
ON CONFLICT (id) DO NOTHING;

-- سياسات الأمان للـ Storage
CREATE POLICY "Anyone can view media" ON storage.objects
    FOR SELECT USING (bucket_id = 'media');

CREATE POLICY "Authenticated users can upload media" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'media' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update own media" ON storage.objects
    FOR UPDATE USING (bucket_id = 'media' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own media" ON storage.objects
    FOR DELETE USING (bucket_id = 'media' AND auth.uid()::text = (storage.foldername(name))[1]);

-- =====================================================
-- 10. Functions و Triggers
-- =====================================================

-- دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إضافة triggers لتحديث updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON public.posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON public.comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- دالة لتحديث عدادات المنشورات
CREATE OR REPLACE FUNCTION update_post_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'post_likes' THEN
        IF TG_OP = 'INSERT' THEN
            UPDATE public.posts 
            SET likes_count = likes_count + 1 
            WHERE id = NEW.post_id;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE public.posts 
            SET likes_count = GREATEST(likes_count - 1, 0) 
            WHERE id = OLD.post_id;
        END IF;
    ELSIF TG_TABLE_NAME = 'comments' THEN
        IF TG_OP = 'INSERT' THEN
            UPDATE public.posts 
            SET comments_count = comments_count + 1 
            WHERE id = NEW.post_id;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE public.posts 
            SET comments_count = GREATEST(comments_count - 1, 0) 
            WHERE id = OLD.post_id;
        END IF;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ language 'plpgsql';

-- إضافة triggers لتحديث العدادات
CREATE TRIGGER update_post_likes_count 
    AFTER INSERT OR DELETE ON public.post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_counts();

CREATE TRIGGER update_post_comments_count 
    AFTER INSERT OR DELETE ON public.comments
    FOR EACH ROW EXECUTE FUNCTION update_post_counts();

-- دالة لتحديث عدادات المتابعين
CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- زيادة عدد المتابعين للمستخدم المتابَع
        UPDATE public.users 
        SET followers_count = followers_count + 1 
        WHERE id = NEW.following_id;
        
        -- زيادة عدد المتابعين للمستخدم المتابِع
        UPDATE public.users 
        SET following_count = following_count + 1 
        WHERE id = NEW.follower_id;
        
    ELSIF TG_OP = 'DELETE' THEN
        -- تقليل عدد المتابعين للمستخدم المتابَع
        UPDATE public.users 
        SET followers_count = GREATEST(followers_count - 1, 0) 
        WHERE id = OLD.following_id;
        
        -- تقليل عدد المتابعين للمستخدم المتابِع
        UPDATE public.users 
        SET following_count = GREATEST(following_count - 1, 0) 
        WHERE id = OLD.follower_id;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ language 'plpgsql';

-- إضافة trigger لتحديث عدادات المتابعة
CREATE TRIGGER update_follow_counts_trigger 
    AFTER INSERT OR DELETE ON public.followers
    FOR EACH ROW EXECUTE FUNCTION update_follow_counts();

-- دالة لتحديث عدد المنشورات
CREATE OR REPLACE FUNCTION update_user_posts_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.users 
        SET posts_count = posts_count + 1 
        WHERE id = NEW.user_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.users 
        SET posts_count = GREATEST(posts_count - 1, 0) 
        WHERE id = OLD.user_id;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ language 'plpgsql';

-- إضافة trigger لتحديث عدد المنشورات
CREATE TRIGGER update_user_posts_count_trigger 
    AFTER INSERT OR DELETE ON public.posts
    FOR EACH ROW EXECUTE FUNCTION update_user_posts_count();

-- =====================================================
-- 11. Views مفيدة
-- =====================================================

-- View لعرض المنشورات مع معلومات الإعجاب
CREATE OR REPLACE VIEW posts_with_likes AS
SELECT 
    p.*,
    CASE 
        WHEN pl.user_id IS NOT NULL THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.posts p
LEFT JOIN public.post_likes pl ON p.id = pl.post_id AND pl.user_id = auth.uid();

-- View لعرض التعليقات مع معلومات الإعجاب
CREATE OR REPLACE VIEW comments_with_likes AS
SELECT 
    c.*,
    CASE 
        WHEN auth.uid()::text = ANY(c.liked_by) THEN true 
        ELSE false 
    END as is_liked_by_current_user
FROM public.comments c;

-- =====================================================
-- 12. بيانات تجريبية (اختياري)
-- =====================================================

-- يمكن إضافة بيانات تجريبية هنا إذا لزم الأمر
-- INSERT INTO public.users (id, username, full_name, bio) VALUES ...

-- =====================================================
-- انتهاء ملف إنشاء قاعدة البيانات
-- =====================================================

-- ملاحظات مهمة:
-- 1. تأكد من تشغيل هذه الأكواد في Supabase SQL Editor
-- 2. قم بتحديث JWT secret في إعدادات المشروع
-- 3. تأكد من تفعيل RLS على جميع الجداول
-- 4. راجع سياسات الأمان حسب احتياجات التطبيق
-- 5. قم بإنشاء فهارس إضافية حسب الحاجة لتحسين الأداء