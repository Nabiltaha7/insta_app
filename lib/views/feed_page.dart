import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/posts_controller.dart';
import '../widgets/post_card.dart';
import '../widgets/filter_tabs.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PostsController postsController = Get.put(PostsController());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => postsController.refreshPosts(),
        color: Colors.blue,
        child: CustomScrollView(
          slivers: [
          // Modern AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.1),
                      Colors.blue.withOpacity(0.1),
                      Colors.pink.withOpacity(0.1),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.purple, Colors.pink, Colors.orange],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Colors.purple, Colors.pink, Colors.orange],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Instagram',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'اكتشف المحتوى الجديد',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildActionButton(
                              icon: Icons.search_rounded,
                              onTap: () {
                                Get.snackbar(
                                  'قريباً',
                                  'سيتم إضافة البحث في التحديث القادم',
                                  backgroundColor: Colors.blue,
                                  colorText: Colors.white,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              icon: Icons.notifications_rounded,
                              onTap: () {
                                Get.snackbar(
                                  'قريباً',
                                  'سيتم إضافة الإشعارات في التحديث القادم',
                                  backgroundColor: Colors.blue,
                                  colorText: Colors.white,
                                );
                              },
                              hasNotification: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Filter tabs
          SliverToBoxAdapter(
            child: const FilterTabs(),
          ),
          
          // Posts list
          Obx(() {
            if (postsController.isLoading.value && postsController.posts.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (postsController.posts.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == postsController.posts.length) {
                    // Load more indicator
                    if (postsController.isLoadingMore.value) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      // Trigger load more
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        postsController.loadMorePosts();
                      });
                      return const SizedBox.shrink();
                    }
                  }

                  final post = postsController.posts[index];
                  return PostCard(
                    post: post,
                    onLike: () => postsController.toggleLike(post.id),
                    onComment: () => Get.toNamed('/comments', arguments: post),
                    onShare: () => _sharePost(post),
                    onView: () => postsController.incrementViews(post.id),
                    onUserTap: () => Get.toNamed('/user-profile', arguments: post.userId),
                  );
                },
                childCount: postsController.posts.length + 
                  (postsController.hasMorePosts.value ? 1 : 0),
              ),
            );
          }),
        ],
      ),
    ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Get.theme.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Get.theme.dividerColor.withOpacity(0.2),
          ),
        ),
        child: Stack(
          children: [
            Icon(
              icon,
              size: 22,
              color: Get.theme.textTheme.bodyLarge?.color,
            ),
            if (hasNotification)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: Colors.blue.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد منشورات بعد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Get.theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'كن أول من ينشر محتوى رائع',
              style: TextStyle(
                fontSize: 16,
                color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.toNamed('/create-post'),
                  borderRadius: BorderRadius.circular(25),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'إنشاء منشور جديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(post) {
    // TODO: Implement share functionality
    Get.snackbar(
      'مشاركة',
      'سيتم تطبيق المشاركة قريباً',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}