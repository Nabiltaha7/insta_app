import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_posts_controller.dart';
import '../widgets/post_card.dart';

class MyPostsPage extends GetView<MyPostsController> {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: controller.refreshPosts,
        color: Colors.blue,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.withValues(alpha: 0.1),
                        Colors.blue.withValues(alpha: 0.1),
                        Colors.pink.withValues(alpha: 0.1),
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
                                  Icons.person_rounded,
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
                                      child: const Text(
                                        'منشوراتي',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Obx(() => Text(
                                      '${controller.myPosts.length} منشور',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              _buildActionButton(
                                icon: Icons.add_rounded,
                                onTap: () => Get.toNamed('/create-post'),
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

            // Posts List
            Obx(() {
              if (controller.isLoading.value && controller.myPosts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.myPosts.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = controller.myPosts[index];
                    return PostCard(
                      post: post,
                      onLike: () => controller.toggleLike(post.id),
                      onComment: () => Get.toNamed('/comments', arguments: post),
                      onShare: () => _sharePost(post),
                      onView: () => controller.incrementViews(post.id),
                      onUserTap: () {}, // It's current user's post
                      showMoreOptions: true, // Show more options for own posts
                    );
                  },
                  childCount: controller.myPosts.length,
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
          color: Get.theme.cardColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Get.theme.dividerColor.withValues(alpha: 0.2),
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
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: Colors.blue.withValues(alpha: 0.7),
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
              'ابدأ بنشر محتوى رائع ومشاركته مع الآخرين',
              style: TextStyle(
                fontSize: 16,
                color: Get.theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
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
                    color: Colors.blue.withValues(alpha: 0.3),
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
    Get.snackbar(
      'مشاركة',
      'سيتم تطبيق المشاركة قريباً',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}