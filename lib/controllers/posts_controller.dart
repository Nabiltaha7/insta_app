import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../services/posts_service.dart';
import '../utils/error_handler.dart';

class PostsController extends GetxController {
  late final PostsService _postsService;
  final supabase = Supabase.instance.client;

  // Observable variables
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMorePosts = true.obs;
  var currentFilter = 'trending'.obs;

  // Pagination
  int _currentPage = 0;
  final int _postsPerPage = 20;

  // Real-time subscription
  RealtimeChannel? _postsSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize PostsService if not already initialized
    if (!Get.isRegistered<PostsService>()) {
      Get.put(PostsService());
    }
    _postsService = Get.find<PostsService>();
    
    loadPosts();
    _setupRealtimeSubscription();
  }

  @override
  void onClose() {
    _postsSubscription?.unsubscribe();
    super.onClose();
  }

  // Setup real-time subscription for posts
  void _setupRealtimeSubscription() {
    try {
      _postsSubscription = supabase
          .channel('posts_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'posts',
            callback: (payload) {
              _handleNewPost(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'posts',
            callback: (payload) {
              _handleUpdatedPost(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'posts',
            callback: (payload) {
              _handleDeletedPost(payload.oldRecord['id']);
            },
          )
          // Listen to likes changes
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'post_likes',
            callback: (payload) {
              _handleLikeChange(payload.newRecord, true);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'post_likes',
            callback: (payload) {
              _handleLikeChange(payload.oldRecord, false);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error setting up real-time subscription: $e');
    }
  }

  // Handle new post from real-time
  void _handleNewPost(Map<String, dynamic> postData) {
    try {
      final newPost = PostModel.fromJson(postData);
      
      // Add to the beginning of the list if it matches current filter
      if (currentFilter.value == 'trending' || currentFilter.value == 'recent') {
        posts.insert(0, newPost);
        
        // Show notification for new post
        Get.snackbar(
          'منشور جديد',
          'تم إضافة منشور جديد من ${newPost.username}',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      debugPrint('Error handling new post: $e');
    }
  }

  // Handle updated post from real-time
  void _handleUpdatedPost(Map<String, dynamic> postData) {
    try {
      final updatedPost = PostModel.fromJson(postData);
      final index = posts.indexWhere((post) => post.id == updatedPost.id);
      
      if (index != -1) {
        posts[index] = updatedPost;
      }
    } catch (e) {
      debugPrint('Error handling updated post: $e');
    }
  }

  // Handle deleted post from real-time
  void _handleDeletedPost(String postId) {
    try {
      posts.removeWhere((post) => post.id == postId);
    } catch (e) {
      debugPrint('Error handling deleted post: $e');
    }
  }

  // Handle like/unlike changes from real-time
  void _handleLikeChange(Map<String, dynamic> likeData, bool isLiked) {
    try {
      final postId = likeData['post_id'];
      final userId = likeData['user_id'];
      final currentUserId = supabase.auth.currentUser?.id;
      
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final currentPost = posts[postIndex];
        
        // Update like count
        final newLikesCount = isLiked 
          ? currentPost.likesCount + 1 
          : currentPost.likesCount - 1;
        
        // Update current user's like status if it's their action
        final isCurrentUserAction = userId == currentUserId;
        
        posts[postIndex] = currentPost.copyWith(
          likesCount: newLikesCount,
          isLikedByCurrentUser: isCurrentUserAction 
            ? isLiked 
            : currentPost.isLikedByCurrentUser,
        );
      }
    } catch (e) {
      debugPrint('Error handling like change: $e');
    }
  }

  // Load posts
  Future<void> loadPosts({bool refresh = false}) async {
    await ErrorHandler.safeAsyncOperation(
      () async {
        if (refresh) {
          _currentPage = 0;
          hasMorePosts.value = true;
          posts.clear();
        }

        if (!hasMorePosts.value) return;

        if (_currentPage == 0) {
          isLoading.value = true;
        } else {
          isLoadingMore.value = true;
        }

        final newPosts = await _postsService.getPosts(
          limit: _postsPerPage,
          offset: _currentPage * _postsPerPage,
          orderBy: currentFilter.value,
        );

        if (newPosts.length < _postsPerPage) {
          hasMorePosts.value = false;
        }

        if (refresh) {
          posts.value = newPosts;
        } else {
          posts.addAll(newPosts);
        }

        _currentPage++;
      },
      context: 'تحميل المنشورات',
    );

    isLoading.value = false;
    isLoadingMore.value = false;
  }

  // Change filter
  Future<void> changeFilter(String filter) async {
    if (currentFilter.value != filter) {
      currentFilter.value = filter;
      await loadPosts(refresh: true);
    }
  }

  // Toggle like
  Future<void> toggleLike(String postId) async {
    try {
      // Check if posts list is empty
      if (posts.isEmpty) {
        Get.snackbar(
          'خطأ',
          'لا توجد منشورات محملة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) {
        // Post not found in local list, try to get it from database
        final postFromDb = await _postsService.getPostById(postId);
        if (postFromDb == null) {
          Get.snackbar(
            'خطأ',
            'المنشور غير موجود',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        // Add the post to local list and continue
        posts.add(postFromDb);
        final newIndex = posts.length - 1;
        
        // Update the like status
        await _updatePostLike(newIndex, postId);
        return;
      }

      // Post found in local list
      await _updatePostLike(postIndex, postId);
      
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في تسجيل الإعجاب: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Helper method to update post like
  Future<void> _updatePostLike(int postIndex, String postId) async {
    final currentPost = posts[postIndex];
    
    // Update UI immediately for better UX
    final newLikeStatus = !currentPost.isLikedByCurrentUser;
    final newLikesCount = newLikeStatus 
      ? currentPost.likesCount + 1 
      : currentPost.likesCount - 1;

    posts[postIndex] = currentPost.copyWith(
      isLikedByCurrentUser: newLikeStatus,
      likesCount: newLikesCount,
    );

    // Then update database
    try {
      await _postsService.togglePostLike(postId);
      
      // Get updated post data from database to ensure consistency
      final updatedPostData = await _postsService.getPostById(postId);
      if (updatedPostData != null) {
        final updatedIndex = posts.indexWhere((post) => post.id == postId);
        if (updatedIndex != -1) {
          posts[updatedIndex] = updatedPostData;
        }
      }
    } catch (dbError) {
      // Revert UI changes on database error
      final revertIndex = posts.indexWhere((post) => post.id == postId);
      if (revertIndex != -1) {
        posts[revertIndex] = currentPost; // Revert to original state
      }
      rethrow;
    }
  }

  // Increment views
  Future<void> incrementViews(String postId) async {
    try {
      await _postsService.incrementPostViews(postId);
      
      // Update post views in list
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        posts[postIndex] = posts[postIndex].copyWith(
          viewsCount: posts[postIndex].viewsCount + 1,
        );
      }
    } catch (error) {
      // Ignore view increment errors
    }
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    await loadPosts(refresh: true);
  }

  // Load more posts
  Future<void> loadMorePosts() async {
    if (!isLoadingMore.value && hasMorePosts.value) {
      await loadPosts();
    }
  }
}