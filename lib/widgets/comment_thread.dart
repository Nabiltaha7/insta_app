import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import '../controllers/comments_controller.dart';

class CommentThread extends StatelessWidget {
  final CommentModel comment;
  final CommentsController controller;

  const CommentThread({
    super.key,
    required this.comment,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isCurrentUser = comment.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // التعليق الرئيسي
          _buildMainComment(context, isCurrentUser),

          // الردود
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...comment.replies.map(
              (reply) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildReplyItem(context, reply),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainComment(BuildContext context, bool isCurrentUser) {
    return Container(
      margin: EdgeInsets.only(
        right: isCurrentUser ? 0 : 40,
        left: isCurrentUser ? 40 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            // صورة الملف الشخصي للآخرين
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  comment.userProfileImage != null
                      ? CachedNetworkImageProvider(comment.userProfileImage!)
                      : null,
              child:
                  comment.userProfileImage == null
                      ? Text(comment.username[0].toUpperCase())
                      : null,
            ),
            const SizedBox(width: 12),
          ],

          // محتوى التعليق
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isCurrentUser
                        ? Colors.blue.shade50
                        : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isCurrentUser
                          ? Colors.blue.shade300
                          : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  // اسم المستخدم والوقت
                  Row(
                    mainAxisAlignment:
                        isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      if (!isCurrentUser) ...[
                        Text(
                          comment.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (comment.isUserVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.blue,
                          ),
                        ],
                        const Spacer(),
                      ],
                      Text(
                        timeago.format(comment.createdAt, locale: 'ar'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const Spacer(),
                        if (comment.isUserVerified) ...[
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          comment.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // نص التعليق
                  Text(
                    comment.text,
                    textAlign: isCurrentUser ? TextAlign.right : TextAlign.left,
                  ),

                  const SizedBox(height: 8),

                  // أزرار الإجراءات
                  Row(
                    mainAxisAlignment:
                        isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      // زر الرد
                      GestureDetector(
                        onTap: () => controller.replyToComment(comment),
                        child: const Text(
                          'رد',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // زر الإعجاب
                      GestureDetector(
                        onTap: () => controller.toggleCommentLike(comment.id),
                        child: Row(
                          children: [
                            if (comment.likesCount > 0) ...[
                              Text(
                                comment.likesCount.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Icon(
                              comment.isLikedByCurrentUser
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color:
                                  comment.isLikedByCurrentUser
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isCurrentUser) ...[
            const SizedBox(width: 12),
            // صورة الملف الشخصي لصاحب الحساب
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  comment.userProfileImage != null
                      ? CachedNetworkImageProvider(comment.userProfileImage!)
                      : null,
              child:
                  comment.userProfileImage == null
                      ? Text(comment.username[0].toUpperCase())
                      : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyItem(BuildContext context, CommentModel reply) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isCurrentUserReply = reply.userId == currentUserId;

    return Container(
      margin: EdgeInsets.only(
        right: isCurrentUserReply ? 0 : 60,
        left: isCurrentUserReply ? 60 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isCurrentUserReply
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        children: [
          if (!isCurrentUserReply) ...[
            // صورة الملف الشخصي للآخرين
            CircleAvatar(
              radius: 12,
              backgroundImage:
                  reply.userProfileImage != null
                      ? CachedNetworkImageProvider(reply.userProfileImage!)
                      : null,
              child:
                  reply.userProfileImage == null
                      ? Text(
                        reply.username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      )
                      : null,
            ),
            const SizedBox(width: 8),
          ],

          // محتوى الرد
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isCurrentUserReply
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isCurrentUserReply
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  // اسم المستخدم والوقت
                  Row(
                    mainAxisAlignment:
                        isCurrentUserReply
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      if (!isCurrentUserReply) ...[
                        Text(
                          reply.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (reply.isUserVerified) ...[
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.verified,
                            size: 10,
                            color: Colors.blue,
                          ),
                        ],
                        const Spacer(),
                      ],
                      Text(
                        timeago.format(reply.createdAt, locale: 'ar'),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (isCurrentUserReply) ...[
                        const Spacer(),
                        if (reply.isUserVerified) ...[
                          const Icon(
                            Icons.verified,
                            size: 10,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 2),
                        ],
                        Text(
                          reply.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),

                  // نص الرد
                  Text(
                    reply.text,
                    style: const TextStyle(fontSize: 12),
                    textAlign:
                        isCurrentUserReply ? TextAlign.right : TextAlign.left,
                  ),

                  const SizedBox(height: 4),

                  // زر الإعجاب للرد
                  Row(
                    mainAxisAlignment:
                        isCurrentUserReply
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => controller.toggleCommentLike(reply.id),
                        child: Row(
                          children: [
                            if (reply.likesCount > 0) ...[
                              Text(
                                reply.likesCount.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 2),
                            ],
                            Icon(
                              reply.isLikedByCurrentUser
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 12,
                              color:
                                  reply.isLikedByCurrentUser
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isCurrentUserReply) ...[
            const SizedBox(width: 8),
            // صورة الملف الشخصي لصاحب الحساب
            CircleAvatar(
              radius: 12,
              backgroundImage:
                  reply.userProfileImage != null
                      ? CachedNetworkImageProvider(reply.userProfileImage!)
                      : null,
              child:
                  reply.userProfileImage == null
                      ? Text(
                        reply.username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      )
                      : null,
            ),
          ],
        ],
      ),
    );
  }
}
