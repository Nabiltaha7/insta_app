import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/user_profile_controller.dart';
import '../widgets/post_card.dart';

class UserProfilePage extends GetView<UserProfileController> {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Loading indicator
          Obx(() {
            if (controller.isLoading.value) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Error state
          Obx(() {
            if (!controller.isLoading.value && controller.userProfile.value == null) {
              return const Expanded(
                child: Center(
                  child: Text('المستخدم غير موجود'),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Main content
          Obx(() {
            if (controller.isLoading.value || controller.userProfile.value == null) {
              return const SizedBox.shrink();
            }
            
            return Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshProfile,
                color: Colors.blue,
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: 100,
                      floating: false,
                      pinned: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 0,
                      leading: IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          controller.userProfile.value?.username ?? '',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        centerTitle: true,
                      ),
                    ),

                    // Profile Header
                    SliverToBoxAdapter(
                      child: _buildProfileHeader(),
                    ),

                    // Posts Grid
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.grid_on_rounded,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'المنشورات',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Posts List
                    _buildPostsList(),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return Obx(() {
      if (controller.isLoadingPosts.value && controller.userPosts.isEmpty) {
        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      if (controller.userPosts.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildEmptyPosts(),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = controller.userPosts[index];
            return PostCard(
              post: post,
              onLike: () => controller.togglePostLike(post.id),
              onComment: () => Get.toNamed('/comments', arguments: post),
              onShare: () => _sharePost(post),
              onView: () => controller.incrementPostViews(post.id),
              onUserTap: () {}, // Already on user profile
            );
          },
          childCount: controller.userPosts.length,
        ),
      );
    });
  }

  Widget _buildProfileHeader() {
    final profile = controller.userProfile.value!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Image and Stats
          Row(
            children: [
              // Profile Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.pink, Colors.orange],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
                    child: CircleAvatar(
                      radius: 39,
                      backgroundImage: profile.profileImageUrl != null
                          ? CachedNetworkImageProvider(profile.profileImageUrl!)
                          : null,
                      child: profile.profileImageUrl == null
                          ? Text(
                              profile.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Stats
              Expanded(
                child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      controller.userPosts.length.toString(),
                      'منشور',
                    ),
                    _buildStatColumn(
                      controller.followersCount.value.toString(),
                      'متابع',
                    ),
                    _buildStatColumn(
                      controller.followingCount.value.toString(),
                      'يتابع',
                    ),
                  ],
                )),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User Info
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.fullName ?? profile.username,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                    ],
                  ],
                ),
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.bio!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          if (!controller.isCurrentUser) ...[
            Row(
              children: [
                // Follow Button
                Expanded(
                  flex: 2,
                  child: Obx(() => _buildActionButton(
                    text: controller.isFollowing.value ? 'إلغاء المتابعة' : 'متابعة',
                    onPressed: controller.isFollowLoading.value 
                        ? null 
                        : controller.toggleFollow,
                    isPrimary: !controller.isFollowing.value,
                    isLoading: controller.isFollowLoading.value,
                  )),
                ),
                
                const SizedBox(width: 12),
                
                // Message Button
                Expanded(
                  child: _buildActionButton(
                    text: 'مراسلة',
                    onPressed: () {
                      Get.snackbar(
                        'قريباً',
                        'سيتم إضافة المراسلة في التحديث القادم',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                    isPrimary: false,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
    bool isPrimary = true,
    bool isLoading = false,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isPrimary ? const LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ) : null,
        color: isPrimary ? null : Theme.of(Get.context!).cardColor,
        border: isPrimary ? null : Border.all(
          color: Theme.of(Get.context!).dividerColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: isPrimary ? Colors.white : Colors.blue,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isPrimary 
                          ? Colors.white 
                          : Theme.of(Get.context!).textTheme.bodyLarge?.color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPosts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: Colors.blue.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منشورات بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(Get.context!).textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.isCurrentUser 
                  ? 'ابدأ بنشر محتوى رائع'
                  : 'لم ينشر ${controller.userProfile.value?.username} أي محتوى بعد',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(Get.context!).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(post) {
    Get.snackbar(
      'مشاركة',
      'سيتم تطبيق المشاركة قريباً',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}