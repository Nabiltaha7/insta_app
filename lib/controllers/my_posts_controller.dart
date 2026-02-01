import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../services/posts_service.dart';
import '../utils/error_handler.dart';

class MyPostsController extends GetxController {
  late final PostsService _postsService;
  final supabase = Supabase.instance.client;

  // Observable variables
  var myPosts = <PostModel>[].obs;
  var isLoading = false.obs;

  // Real-time subscription
  RealtimeChannel? _myPostsSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize PostsService if not already initialized
    if (!Get.isRegistered<PostsService>()) {
      Get.put(PostsService());
    }
    _postsService = Get.find<PostsService>();
    
    loadMyPosts();
    _setupRealtimeSubscription();
  }

  @override
  void onClose() {
    _myPostsSubscription?.unsubscribe();
    super.onClose();
  }

  // Setup real-time subscription for current user's posts
  void _setupRealtimeSubscription() {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      _myPostsSubscription = supabase
          .channel('my_posts_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'posts',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: currentUserId,
            ),
            callback: (payload) {
              _handleNewPost(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'posts',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: currentUserId,
            ),
            callback: (payload) {
              _handleUpdatedPost(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'posts',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: currentUserId,
            ),
            callback: (payload) {
              _handleDeletedPost(payload.oldRecord['id']);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error setting up my posts real-time subscription: $e');
    }
  }

  // Handle new post from real-time
  void _handleNewPost(Map<String, dynamic> postData) {
    try {
      final newPost = PostModel.fromJson(postData);
      myPosts.insert(0, newPost);
      
      Get.snackbar(
        'منشور جديد',
        'تم نشر منشورك بنجاح!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('Error handling new post: $e');
    }
  }

  // Handle updated post from real-time
  void _handleUpdatedPost(Map<String, dynamic> postData) {
    try {
      final updatedPost = PostModel.fromJson(postData);
      final index = myPosts.indexWhere((post) => post.id == updatedPost.id);
      
      if (index != -1) {
        myPosts[index] = updatedPost;
      }
    } catch (e) {
      debugPrint('Error handling updated post: $e');
    }
  }

  // Handle deleted post from real-time
  void _handleDeletedPost(String postId) {
    try {
      myPosts.removeWhere((post) => post.id == postId);
    } catch (e) {
      debugPrint('Error handling deleted post: $e');
    }
  }

  // Load current user's posts
  Future<void> loadMyPosts() async {
    await ErrorHandler.safeAsyncOperation(
      () async {
        isLoading.value = true;

        final currentUserId = supabase.auth.currentUser?.id;
        if (currentUserId == null) {
          throw Exception('يجب تسجيل الدخول أولاً');
        }

        final posts = await _postsService.getUserPosts(currentUserId);
        myPosts.value = posts;
      },
      context: 'تحميل منشوراتي',
    );

    isLoading.value = false;
  }

  // Toggle like on post
  Future<void> toggleLike(String postId) async {
    try {
      final postIndex = myPosts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      final currentPost = myPosts[postIndex];
      
      // Update UI immediately for better UX
      final newLikeStatus = !currentPost.isLikedByCurrentUser;
      final newLikesCount = newLikeStatus 
        ? currentPost.likesCount + 1 
        : currentPost.likesCount - 1;

      myPosts[postIndex] = currentPost.copyWith(
        isLikedByCurrentUser: newLikeStatus,
        likesCount: newLikesCount,
      );

      // Then update database
      await _postsService.togglePostLike(postId);
      
      // Get updated post data from database to ensure consistency
      final updatedPostData = await _postsService.getPostById(postId);
      if (updatedPostData != null) {
        final updatedIndex = myPosts.indexWhere((post) => post.id == postId);
        if (updatedIndex != -1) {
          myPosts[updatedIndex] = updatedPostData;
        }
      }
    } catch (error) {
      // Revert UI changes on error
      final revertIndex = myPosts.indexWhere((post) => post.id == postId);
      if (revertIndex != -1) {
        await loadMyPosts(); // Reload to get correct state
      }
      
      Get.snackbar(
        'خطأ',
        'فشل في تسجيل الإعجاب: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Increment views
  Future<void> incrementViews(String postId) async {
    try {
      await _postsService.incrementPostViews(postId);
      
      // Update post views in list
      final postIndex = myPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        myPosts[postIndex] = myPosts[postIndex].copyWith(
          viewsCount: myPosts[postIndex].viewsCount + 1,
        );
      }
    } catch (error) {
      // Ignore view increment errors
    }
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    await loadMyPosts();
  }

  // Get posts count
  int get postsCount => myPosts.length;
}