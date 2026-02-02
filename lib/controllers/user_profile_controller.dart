import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:insta/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';
import '../services/posts_service.dart';
import '../utils/error_handler.dart';

class UserProfileController extends GetxController {
  final String userId;
  late final UserProfileService _userProfileService;
  late final PostsService _postsService;
  final supabase = Supabase.instance.client;

  UserProfileController(this.userId);

  // Observable variables
  var userProfile = Rxn<UserProfileModel>();
  var userPosts = <PostModel>[].obs;
  var isLoading = false.obs;
  var isLoadingPosts = false.obs;
  var isFollowing = false.obs;
  var isFollowLoading = false.obs;
  var followersCount = 0.obs;
  var followingCount = 0.obs;

  // Real-time subscriptions
  RealtimeChannel? _followersSubscription;
  RealtimeChannel? _postsSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize services
    if (!Get.isRegistered<UserProfileService>()) {
      Get.put(UserProfileService());
    }
    if (!Get.isRegistered<PostsService>()) {
      Get.put(PostsService());
    }
    
    _userProfileService = Get.find<UserProfileService>();
    _postsService = Get.find<PostsService>();
    
    // Check if followers table exists
    _userProfileService.ensureFollowersTableExists();
    
    loadUserProfile();
    _setupRealtimeSubscriptions();
  }

  @override
  void onClose() {
    _followersSubscription?.unsubscribe();
    _postsSubscription?.unsubscribe();
    super.onClose();
  }

  // Check if viewing current user's profile
  bool get isCurrentUser => supabase.auth.currentUser?.id == userId;

  // Setup real-time subscriptions
  void _setupRealtimeSubscriptions() {
    try {
      // Subscribe to followers changes
      _followersSubscription = supabase
          .channel('followers_changes_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: AppConstants.followersTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'following_id',
              value: userId,
            ),
            callback: (payload) {
              followersCount.value++;
              _checkIfCurrentUserFollows();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: AppConstants.followersTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'following_id',
              value: userId,
            ),
            callback: (payload) {
              followersCount.value--;
              _checkIfCurrentUserFollows();
            },
          )
          .subscribe();

      // Subscribe to user's posts changes
      _postsSubscription = supabase
          .channel('user_posts_changes_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'posts',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleNewPost(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'posts',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              userPosts.removeWhere((post) => post.id == payload.oldRecord['id']);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error setting up user profile real-time subscriptions: $e');
    }
  }

  // Handle new post from real-time
  void _handleNewPost(Map<String, dynamic> postData) {
    try {
      final newPost = PostModel.fromJson(postData);
      userPosts.insert(0, newPost);
    } catch (e) {
      debugPrint('Error handling new post: $e');
    }
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    await ErrorHandler.safeAsyncOperation(
      () async {
        isLoading.value = true;

        // Load user profile
        final profile = await _userProfileService.getUserProfile(userId);
        if (profile == null) {
          Get.snackbar(
            'خطأ',
            'المستخدم غير موجود',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        userProfile.value = profile;

        // Load user posts first to get accurate count
        await _loadUserPosts();

        // Load follow counts
        await _loadFollowCounts();

        // Check if current user follows this user
        await _checkIfCurrentUserFollows();
      },
      context: 'تحميل الملف الشخصي',
    );

    isLoading.value = false;
  }

  // Load follow counts
  Future<void> _loadFollowCounts() async {
    try {
      debugPrint('Loading follow counts for user: $userId');
      final counts = await _userProfileService.getFollowCounts(userId);
      followersCount.value = counts[AppConstants.followersTable] ?? 0;
      followingCount.value = counts['following'] ?? 0;
      debugPrint('Loaded follow counts - Followers: ${followersCount.value}, Following: ${followingCount.value}');
    } catch (e) {
      debugPrint('Error loading follow counts: $e');
    }
  }

  // Check if current user follows this user
  Future<void> _checkIfCurrentUserFollows() async {
    if (isCurrentUser) {
      isFollowing.value = false;
      return;
    }

    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final following = await _userProfileService.isFollowing(currentUserId, userId);
      isFollowing.value = following;
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  // Load user posts
  Future<void> _loadUserPosts() async {
    try {
      isLoadingPosts.value = true;
      debugPrint('Loading posts for user: $userId');
      final posts = await _postsService.getUserPosts(userId);
      userPosts.value = posts;
      debugPrint('Loaded ${posts.length} posts for user: $userId');
    } catch (e) {
      debugPrint('Error loading user posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  // Toggle follow/unfollow
  Future<void> toggleFollow() async {
    if (isCurrentUser) return;

    await ErrorHandler.safeAsyncOperation(
      () async {
        isFollowLoading.value = true;

        final currentUserId = supabase.auth.currentUser?.id;
        if (currentUserId == null) {
          throw Exception('يجب تسجيل الدخول أولاً');
        }

        if (isFollowing.value) {
          // Unfollow
          await _userProfileService.unfollowUser(currentUserId, userId);
          isFollowing.value = false;
          followersCount.value--;
          
          Get.snackbar(
            'تم إلغاء المتابعة',
            'تم إلغاء متابعة ${userProfile.value?.username}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          // Follow
          await _userProfileService.followUser(currentUserId, userId);
          isFollowing.value = true;
          followersCount.value++;
          
          Get.snackbar(
            'تمت المتابعة',
            'أصبحت تتابع ${userProfile.value?.username}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      },
      context: isFollowing.value ? 'إلغاء المتابعة' : 'المتابعة',
    );

    isFollowLoading.value = false;
  }

  // Toggle post like
  Future<void> togglePostLike(String postId) async {
    try {
      final postIndex = userPosts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      final currentPost = userPosts[postIndex];
      
      // Update UI immediately
      final newLikeStatus = !currentPost.isLikedByCurrentUser;
      final newLikesCount = newLikeStatus 
        ? currentPost.likesCount + 1 
        : currentPost.likesCount - 1;

      userPosts[postIndex] = currentPost.copyWith(
        isLikedByCurrentUser: newLikeStatus,
        likesCount: newLikesCount,
      );

      // Update database
      await _postsService.togglePostLike(postId);
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في تسجيل الإعجاب: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Increment post views
  Future<void> incrementPostViews(String postId) async {
    try {
      await _postsService.incrementPostViews(postId);
      
      // Update post views in list
      final postIndex = userPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        userPosts[postIndex] = userPosts[postIndex].copyWith(
          viewsCount: userPosts[postIndex].viewsCount + 1,
        );
      }
    } catch (error) {
      // Ignore view increment errors
    }
  }

  // Refresh profile
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }
}