import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../constants/app_constants.dart';

class PostsService extends GetxService {
  final supabase = Supabase.instance.client;

  // Get posts with trending algorithm
  Future<List<PostModel>> getPosts({
    int limit = 20,
    int offset = 0,
    String orderBy = 'trending',
  }) async {
    try {
      // ترتيب بسيط حسب النوع المطلوب
      String orderColumn = 'created_at';
      bool ascending = false;

      switch (orderBy) {
        case 'trending':
        case 'recent':
          orderColumn = 'created_at';
          ascending = false;
          break;
        case 'popular':
          orderColumn = 'likes_count';
          ascending = false;
          break;
      }

      final response = await supabase
          .from(AppConstants.postsTable)
          .select('*')
          .order(orderColumn, ascending: ascending)
          .range(offset, offset + limit - 1);

      final posts =
          (response as List).map((post) => PostModel.fromJson(post)).toList();

      // Check if current user liked each post
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        for (int i = 0; i < posts.length; i++) {
          final isLiked = await isPostLikedByUser(posts[i].id, currentUserId);
          posts[i] = posts[i].copyWith(isLikedByCurrentUser: isLiked);
        }
      }

      return posts;
    } catch (error) {
      throw Exception('خطأ في تحميل المنشورات: $error');
    }
  }

  // Get single post by ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final response =
          await supabase
              .from(AppConstants.postsTable)
              .select('*')
              .eq('id', postId)
              .single();

      final post = PostModel.fromJson(response);

      // Check if current user liked this post
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        final isLiked = await isPostLikedByUser(postId, currentUserId);
        return post.copyWith(isLikedByCurrentUser: isLiked);
      }

      return post;
    } catch (error) {
      return null;
    }
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      debugPrint('Getting posts for user: $userId');
      final response = await supabase
          .from(AppConstants.postsTable)
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final posts =
          (response as List).map((post) => PostModel.fromJson(post)).toList();

      debugPrint('Found ${posts.length} posts for user: $userId');

      // Check if current user liked each post
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        for (int i = 0; i < posts.length; i++) {
          final isLiked = await isPostLikedByUser(posts[i].id, currentUserId);
          posts[i] = posts[i].copyWith(isLikedByCurrentUser: isLiked);
        }
      }

      return posts;
    } catch (error) {
      debugPrint('Error getting user posts: $error');
      throw Exception('خطأ في تحميل منشورات المستخدم: $error');
    }
  }

  // Create new post
  Future<PostModel> createPost({
    required String caption,
    required List<String> mediaUrls,
    required String type,
    List<String> tags = const [],
    String? location,
  }) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      // Get user profile
      final userProfile =
          await supabase
              .from(AppConstants.usersTable)
              .select('username, profile_image_url, is_verified')
              .eq('id', currentUser.id)
              .single();

      final postData = {
        'user_id': currentUser.id,
        'username': userProfile['username'],
        'user_profile_image': userProfile['profile_image_url'],
        'is_user_verified': userProfile['is_verified'] ?? false,
        'caption': caption,
        'media_urls': mediaUrls,
        'type': type,
        'tags': tags,
        'location': location,
      };

      final response =
          await supabase
              .from(AppConstants.postsTable)
              .insert(postData)
              .select()
              .single();

      return PostModel.fromJson(response);
    } catch (error) {
      throw Exception('خطأ في إنشاء المنشور: $error');
    }
  }

  // Like/Unlike post
  Future<bool> togglePostLike(String postId) async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      // Check if user already liked this post
      final existingLike =
          await supabase
              .from(AppConstants.likesTable)
              .select('id')
              .eq('post_id', postId)
              .eq('user_id', currentUserId)
              .maybeSingle();

      if (existingLike != null) {
        // User already liked, so unlike
        await supabase
            .from(AppConstants.likesTable)
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUserId);

        return false; // Not liked anymore
      } else {
        // User hasn't liked, so like
        await supabase.from(AppConstants.likesTable).insert({
          'post_id': postId,
          'user_id': currentUserId,
        });

        return true; // Now liked
      }
    } catch (error) {
      debugPrint('Error in togglePostLike: $error');
      throw Exception('خطأ في تسجيل الإعجاب: $error');
    }
  }

  // Check if post is liked by user
  Future<bool> isPostLikedByUser(String postId, String userId) async {
    try {
      final like =
          await supabase
              .from(AppConstants.likesTable)
              .select('id')
              .eq('post_id', postId)
              .eq('user_id', userId)
              .maybeSingle();

      return like != null;
    } catch (error) {
      return false;
    }
  }

  // Increment post views
  Future<void> incrementPostViews(String postId) async {
    try {
      final response =
          await supabase
              .from(AppConstants.postsTable)
              .select('views_count')
              .eq('id', postId)
              .single();

      final int currentViews = response['views_count'] ?? 0;

      await supabase
          .from(AppConstants.postsTable)
          .update({'views_count': currentViews + 1})
          .eq('id', postId);
    } catch (error) {
      debugPrint('Could not increment views: $error');
    }
  }
}
