class AppConstants {
  // App Info
  static const String appName = 'Instagram';
  static const String appVersion = '1.0.0';

  // Supabase Configuration
  static const String supabaseUrl = 'https://tbmbqrxqbvpnmrblbnjx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRibWJxcnhxYnZwbm1yYmxibmp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2MjIwMDQsImV4cCI6MjA4NTE5ODAwNH0.Wosxxi7AIhEg7AJmxN96mci6ZjjxE5mnUtfz07S0cq4';

  // Database Tables
  static const String usersTable = 'users';
  static const String commentsTable = 'comments';
  static const String postsTable = 'posts';
  static const String followersTable = 'followers';
  static const String likesTable = 'likes';
  static const String commentLikesTable = 'comment_likes';
  static const String postLikesTable = 'post_likes';

  // Routes
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String createPost = '/create-post';
  static const String comments = '/comments';
  static const String profileEdit = '/profile-edit';
  static const String settings = '/settings';
  static const String userProfile = '/user-profile';
  static const String myPosts = '/my-posts';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int minFullNameLength = 2;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double buttonHeight = 50.0;
}
