import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../controllers/comments_controller.dart';
import '../widgets/comment_thread.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PostModel post = Get.arguments as PostModel;
    final CommentsController controller = Get.put(CommentsController(post.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('comment'.tr),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Post preview
          _buildPostPreview(post),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshComments(),
              color: Colors.blue,
              child: Obx(() {
                if (controller.isLoading.value && controller.comments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_comments_yet'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'be_first_to_comment'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.comments.length,
                  itemBuilder: (context, index) {
                    final comment = controller.comments[index];
                    return CommentThread(
                      comment: comment,
                      controller: controller,
                    );
                  },
                );
              }),
            ),
          ),

          // Comment input
          _buildCommentInput(controller),
        ],
      ),
    );
  }

  Widget _buildPostPreview(PostModel post) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(Get.context!).cardColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          CircleAvatar(
            radius: 20,
            backgroundImage:
                post.userProfileImage != null
                    ? CachedNetworkImageProvider(post.userProfileImage!)
                    : null,
            child:
                post.userProfileImage == null
                    ? Text(post.username[0].toUpperCase())
                    : null,
          ),
          const SizedBox(width: 12),

          // Post content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                    if (post.isUserVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                    ],
                  ],
                ),
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.caption!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(CommentsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(Get.context!).dividerColor),
        ),
      ),
      child: Obx(
        () => Column(
          children: [
            // Reply indicator
            if (controller.replyingTo.value != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'الرد على ${controller.replyingTo.value!.username}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.cancelReply,
                      child: const Icon(
                        Icons.close,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commentController,
                    style: TextStyle(
                      color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          controller.replyingTo.value != null
                              ? 'الرد على ${controller.replyingTo.value!.username}...'
                              : 'إضافة تعليق...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(Get.context!).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.addComment(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap:
                      controller.isAddingComment.value
                          ? null
                          : controller.addComment,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child:
                        controller.isAddingComment.value
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 16,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
