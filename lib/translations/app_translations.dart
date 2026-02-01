import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': {
      // Navigation
      'home': 'الرئيسية',
      'create': 'إنشاء',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      
      // Auth
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'email': 'البريد الإلكتروني',
      'full_name': 'الاسم الكامل',
      'already_have_account': 'لديك حساب بالفعل؟ سجل دخول',
      'dont_have_account': 'ليس لديك حساب؟ أنشئ حساب جديد',
      
      // Posts
      'posts': 'المنشورات',
      'followers': 'المتابعون',
      'following': 'يتابع',
      'like': 'إعجاب',
      'comment': 'تعليق',
      'share': 'مشاركة',
      'view_all_comments': 'عرض جميع التعليقات',
      'add_comment': 'أضف تعليقاً...',
      'trending': 'الأحدث',
      'popular': 'الأكثر شعبية',
      
      // Settings
      'account': 'الحساب',
      'privacy': 'الخصوصية',
      'app_settings': 'إعدادات التطبيق',
      'developer': 'المطور',
      'logout': 'تسجيل الخروج',
      'dark_mode': 'الوضع الليلي',
      'language': 'اللغة',
      'private_account': 'حساب خاص',
      'show_last_seen': 'إظهار آخر ظهور',
      'allow_messages': 'السماح بالرسائل من الجميع',
      'edit_profile': 'تعديل الملف الشخصي',
      'notifications': 'الإشعارات',
      'about_app': 'حول التطبيق',
      
      // Messages
      'success': 'نجح',
      'error': 'خطأ',
      'loading': 'جاري التحميل...',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'follow': 'متابعة',
      'unfollow': 'إلغاء المتابعة',
      'message': 'رسالة',
      'report': 'إبلاغ',
      'block': 'حظر',
      
      // Profile
      'bio': 'النبذة الشخصية',
      'website': 'الموقع الإلكتروني',
      'phone': 'رقم الهاتف',
      'gender': 'الجنس',
      'male': 'ذكر',
      'female': 'أنثى',
      'save_changes': 'حفظ التغييرات',
      'change_photo': 'اضغط لتغيير الصورة الشخصية',
      
      // Create Post
      'new_post': 'منشور جديد',
      'caption': 'الوصف',
      'location': 'المكان',
      'tags': 'العلامات',
      'publish': 'نشر',
      'add_photos': 'إضافة صور',
      'from_gallery': 'من المعرض',
      'from_camera': 'التقاط صورة',
      'video_from_gallery': 'فيديو من المعرض',
      
      // Additional translations
      'no_posts': 'لا توجد منشورات',
      'be_first_to_post': 'كن أول من ينشر محتوى!',
      'no_comments_yet': 'لا توجد تعليقات بعد',
      'be_first_to_comment': 'كن أول من يعلق على هذا المنشور',
      'views': 'مشاهدة',
      'copy_link': 'نسخ الرابط',
      'report_post': 'الإبلاغ عن المنشور',
      'delete_post': 'حذف المنشور',
      'you': 'أنت',
      'reply': 'رد',
      
      // Notifications
      'no_notifications': 'لا توجد إشعارات',
      'notifications_will_appear_here': 'ستظهر الإشعارات هنا',
      'mark_all_read': 'وضع علامة مقروء على الكل',
      'delete_all': 'حذف الكل',
      'delete_all_notifications': 'حذف جميع الإشعارات',
      'delete_all_notifications_confirm': 'هل أنت متأكد من حذف جميع الإشعارات؟',
    },
    'en': {
      // Navigation
      'home': 'Home',
      'create': 'Create',
      'profile': 'Profile',
      'settings': 'Settings',
      
      // Auth
      'login': 'Login',
      'signup': 'Sign Up',
      'username': 'Username',
      'password': 'Password',
      'email': 'Email',
      'full_name': 'Full Name',
      'already_have_account': 'Already have an account? Sign in',
      'dont_have_account': 'Don\'t have an account? Sign up',
      
      // Posts
      'posts': 'Posts',
      'followers': 'Followers',
      'following': 'Following',
      'like': 'Like',
      'comment': 'Comment',
      'share': 'Share',
      'view_all_comments': 'View all comments',
      'add_comment': 'Add a comment...',
      'trending': 'Trending',
      'popular': 'Popular',
      
      // Settings
      'account': 'Account',
      'privacy': 'Privacy',
      'app_settings': 'App Settings',
      'developer': 'Developer',
      'logout': 'Logout',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'private_account': 'Private Account',
      'show_last_seen': 'Show Last Seen',
      'allow_messages': 'Allow Messages from Everyone',
      'edit_profile': 'Edit Profile',
      'notifications': 'Notifications',
      'about_app': 'About App',
      
      // Messages
      'success': 'Success',
      'error': 'Error',
      'loading': 'Loading...',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'follow': 'Follow',
      'unfollow': 'Unfollow',
      'message': 'Message',
      'report': 'Report',
      'block': 'Block',
      
      // Profile
      'bio': 'Bio',
      'website': 'Website',
      'phone': 'Phone',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'save_changes': 'Save Changes',
      'change_photo': 'Tap to change profile photo',
      
      // Create Post
      'new_post': 'New Post',
      'caption': 'Caption',
      'location': 'Location',
      'tags': 'Tags',
      'publish': 'Publish',
      'add_photos': 'Add Photos',
      'from_gallery': 'From Gallery',
      'from_camera': 'Take Photo',
      'video_from_gallery': 'Video from Gallery',
      
      // Additional translations
      'no_posts': 'No posts yet',
      'be_first_to_post': 'Be the first to post content!',
      'no_comments_yet': 'No comments yet',
      'be_first_to_comment': 'Be the first to comment on this post',
      'views': 'views',
      'copy_link': 'Copy Link',
      'report_post': 'Report Post',
      'delete_post': 'Delete Post',
      'you': 'You',
      'reply': 'Reply',
      
      // Notifications
      'no_notifications': 'No notifications',
      'notifications_will_appear_here': 'Notifications will appear here',
      'mark_all_read': 'Mark all as read',
      'delete_all': 'Delete all',
      'delete_all_notifications': 'Delete all notifications',
      'delete_all_notifications_confirm': 'Are you sure you want to delete all notifications?',
    },
  };
}