# دليل إعداد قاعدة البيانات - Instagram Clone

هذا الدليل يوضح كيفية إعداد قاعدة البيانات لتطبيق Instagram Clone باستخدام Supabase.

## 📁 الملفات المتوفرة

### 1. `database_schema.sql`
**الملف الرئيسي** - يحتوي على جميع أكواد إنشاء الجداول والفهارس والسياسات

### 2. `database_maintenance.sql`
**ملف الصيانة** - يحتوي على استعلامات الصيانة والإحصائيات والتنظيف

### 3. `app_specific_queries.sql`
**استعلامات التطبيق** - يحتوي على الاستعلامات المحددة التي يستخدمها التطبيق

## 🚀 خطوات الإعداد

### الخطوة 1: إنشاء مشروع Supabase
1. اذهب إلى [supabase.com](https://supabase.com)
2. أنشئ حساب جديد أو سجل دخول
3. أنشئ مشروع جديد
4. انتظر حتى يكتمل إعداد المشروع

### الخطوة 2: الحصول على بيانات الاتصال
1. اذهب إلى Settings → API
2. انسخ `Project URL`
3. انسخ `anon/public key`
4. احفظ هذه البيانات لاستخدامها في التطبيق

### الخطوة 3: تشغيل أكواد قاعدة البيانات
1. اذهب إلى SQL Editor في Supabase
2. افتح ملف `database_schema.sql`
3. انسخ المحتوى والصقه في SQL Editor
4. اضغط Run لتشغيل الأكواد

### الخطوة 4: التحقق من الإعداد
```sql
-- تشغيل هذا الاستعلام للتحقق من إنشاء الجداول
SELECT tablename FROM pg_tables WHERE schemaname = 'public';
```

### الخطوة 5: تحديث إعدادات التطبيق
قم بتحديث ملف `lib/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  
  // باقي الإعدادات...
}
```

## 📊 هيكل قاعدة البيانات

### الجداول الرئيسية

#### 1. `users` - جدول المستخدمين
```sql
- id (UUID, Primary Key)
- username (TEXT, Unique)
- full_name (TEXT)
- profile_image_url (TEXT)
- bio (TEXT)
- is_verified (BOOLEAN)
- posts_count (INTEGER)
- followers_count (INTEGER)
- following_count (INTEGER)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### 2. `posts` - جدول المنشورات
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key)
- username (TEXT)
- caption (TEXT)
- media_urls (TEXT[])
- type (TEXT: 'text', 'image', 'carousel')
- likes_count (INTEGER)
- comments_count (INTEGER)
- views_count (INTEGER)
- created_at (TIMESTAMP)
```

#### 3. `comments` - جدول التعليقات
```sql
- id (UUID, Primary Key)
- post_id (UUID, Foreign Key)
- user_id (UUID, Foreign Key)
- text (TEXT)
- parent_comment_id (UUID, Foreign Key)
- likes_count (INTEGER)
- liked_by (TEXT[])
- created_at (TIMESTAMP)
```

#### 4. `post_likes` - جدول إعجابات المنشورات
```sql
- id (UUID, Primary Key)
- post_id (UUID, Foreign Key)
- user_id (UUID, Foreign Key)
- created_at (TIMESTAMP)
- UNIQUE(post_id, user_id)
```

#### 5. `followers` - جدول المتابعين
```sql
- id (UUID, Primary Key)
- follower_id (UUID, Foreign Key)
- following_id (UUID, Foreign Key)
- created_at (TIMESTAMP)
- UNIQUE(follower_id, following_id)
```

## 🔒 الأمان (Row Level Security)

جميع الجداول محمية بـ RLS مع السياسات التالية:

### سياسات المستخدمين:
- **القراءة**: الجميع يمكنهم رؤية الملفات الشخصية
- **التحديث**: المستخدمون يمكنهم تحديث ملفاتهم الشخصية فقط
- **الإدراج**: المستخدمون يمكنهم إنشاء ملفاتهم الشخصية فقط

### سياسات المنشورات:
- **القراءة**: الجميع يمكنهم رؤية المنشورات
- **الإدراج**: المستخدمون المسجلون يمكنهم إنشاء منشورات
- **التحديث/الحذف**: المستخدمون يمكنهم تعديل منشوراتهم فقط

### سياسات التعليقات:
- **القراءة**: الجميع يمكنهم رؤية التعليقات
- **الإدراج**: المستخدمون المسجلون يمكنهم التعليق
- **التحديث/الحذف**: المستخدمون يمكنهم تعديل تعليقاتهم فقط

## ⚡ الأداء والفهارس

تم إنشاء فهارس على:
- `users.username`
- `posts.user_id`
- `posts.created_at`
- `comments.post_id`
- `post_likes.post_id`
- `followers.follower_id`
- `followers.following_id`

## 🔄 التحديثات التلقائية

### Triggers المفعلة:
1. **تحديث updated_at**: يحدث تلقائياً عند تعديل السجلات
2. **تحديث عدادات المنشورات**: يحدث عند إضافة/حذف إعجاب أو تعليق
3. **تحديث عدادات المتابعة**: يحدث عند المتابعة/إلغاء المتابعة
4. **تحديث عدد المنشورات**: يحدث عند إضافة/حذف منشور

## 🛠️ الصيانة الدورية

### استعلامات مفيدة للصيانة:

```sql
-- التحقق من حالة قاعدة البيانات
SELECT 'users' as table_name, COUNT(*) as count FROM public.users
UNION ALL
SELECT 'posts' as table_name, COUNT(*) as count FROM public.posts
UNION ALL
SELECT 'comments' as table_name, COUNT(*) as count FROM public.comments;

-- إعادة حساب العدادات
UPDATE public.posts 
SET likes_count = (
    SELECT COUNT(*) FROM public.post_likes WHERE post_id = posts.id
);
```

## 📱 ربط التطبيق

### في Flutter:
1. أضف التبعيات في `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

2. قم بتهيئة Supabase في `main.dart`:
```dart
await Supabase.initialize(
  url: AppConstants.supabaseUrl,
  anonKey: AppConstants.supabaseAnonKey,
);
```

## 🔍 استكشاف الأخطاء

### مشاكل شائعة وحلولها:

#### 1. خطأ في RLS
```
Row Level Security policy violation
```
**الحل**: تأكد من تسجيل دخول المستخدم وأن السياسات صحيحة

#### 2. خطأ في Foreign Key
```
Foreign key constraint violation
```
**الحل**: تأكد من وجود السجلات المرجعية قبل الإدراج

#### 3. خطأ في Unique Constraint
```
Unique constraint violation
```
**الحل**: تحقق من عدم تكرار البيانات الفريدة

## 📊 مراقبة الأداء

### استعلامات مراقبة الأداء:
```sql
-- حجم الجداول
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size('public.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public';

-- استخدام الفهارس
SELECT 
    indexname,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public';
```

## 🚨 النسخ الاحتياطي

### نسخ احتياطي يدوي:
```sql
-- تصدير البيانات
COPY public.users TO '/tmp/users_backup.csv' WITH CSV HEADER;
COPY public.posts TO '/tmp/posts_backup.csv' WITH CSV HEADER;
```

### نسخ احتياطي تلقائي:
Supabase يقوم بنسخ احتياطي تلقائي، يمكن الوصول إليه من Dashboard.

## 📞 الدعم

إذا واجهت أي مشاكل:
1. راجع [وثائق Supabase](https://supabase.com/docs)
2. تحقق من [مجتمع Supabase](https://github.com/supabase/supabase/discussions)
3. راجع ملف `database_maintenance.sql` للاستعلامات المفيدة

---

**ملاحظة**: تأكد من تشغيل جميع الأكواد في بيئة آمنة وعمل نسخة احتياطية قبل أي تعديلات كبيرة.