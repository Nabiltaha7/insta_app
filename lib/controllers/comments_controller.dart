import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import '../services/comments_service.dart';

class CommentsController extends GetxController {
  final String postId;
  late final CommentsService _commentsService;
  final supabase = Supabase.instance.client;

  CommentsController(this.postId);

  // Form controller
  final commentController = TextEditingController();

  // Observable variables
  var comments = <CommentModel>[].obs;
  var isLoading = false.obs;
  var isAddingComment = false.obs;
  var replyingTo = Rxn<CommentModel>();

  // Real-time subscription
  RealtimeChannel? _commentsSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize CommentsService if not already initialized
    if (!Get.isRegistered<CommentsService>()) {
      Get.put(CommentsService());
    }
    _commentsService = Get.find<CommentsService>();
    
    loadComments();
    _setupRealtimeSubscription();
  }

  @override
  void onClose() {
    _commentsSubscription?.unsubscribe();
    try {
      commentController.dispose();
    } catch (e) {
      debugPrint('Error disposing CommentsController controllers: $e');
    }
    super.onClose();
  }

  // Setup real-time subscription for comments
  void _setupRealtimeSubscription() {
    try {
      _commentsSubscription = supabase
          .channel('comments_changes_$postId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'comments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'post_id',
              value: postId,
            ),
            callback: (payload) {
              _handleNewComment(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'comments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'post_id',
              value: postId,
            ),
            callback: (payload) {
              _handleUpdatedComment(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'comments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'post_id',
              value: postId,
            ),
            callback: (payload) {
              _handleDeletedComment(payload.oldRecord['id']);
            },
          )
          // Listen to comment likes changes
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'comment_likes',
            callback: (payload) {
              _handleCommentLikeChange(payload.newRecord, true);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'comment_likes',
            callback: (payload) {
              _handleCommentLikeChange(payload.oldRecord, false);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error setting up comments real-time subscription: $e');
    }
  }

  // Handle new comment from real-time
  void _handleNewComment(Map<String, dynamic> commentData) {
    try {
      final newComment = CommentModel.fromJson(commentData);
      
      // Don't add if it's from current user (already added locally)
      final currentUserId = supabase.auth.currentUser?.id;
      if (newComment.userId == currentUserId) return;
      
      if (newComment.parentCommentId != null) {
        // It's a reply
        final parentIndex = comments.indexWhere(
          (comment) => comment.id == newComment.parentCommentId,
        );
        if (parentIndex != -1) {
          final updatedReplies = List<CommentModel>.from(comments[parentIndex].replies);
          updatedReplies.add(newComment);
          comments[parentIndex] = comments[parentIndex].copyWith(
            replies: updatedReplies,
            repliesCount: updatedReplies.length,
          );
        }
      } else {
        // It's a main comment
        comments.insert(0, newComment);
      }
    } catch (e) {
      debugPrint('Error handling new comment: $e');
    }
  }

  // Handle updated comment from real-time
  void _handleUpdatedComment(Map<String, dynamic> commentData) {
    try {
      final updatedComment = CommentModel.fromJson(commentData);
      
      // Update main comment
      final mainIndex = comments.indexWhere((comment) => comment.id == updatedComment.id);
      if (mainIndex != -1) {
        comments[mainIndex] = updatedComment;
        return;
      }
      
      // Update reply
      for (int i = 0; i < comments.length; i++) {
        final replyIndex = comments[i].replies.indexWhere(
          (reply) => reply.id == updatedComment.id,
        );
        if (replyIndex != -1) {
          final updatedReplies = List<CommentModel>.from(comments[i].replies);
          updatedReplies[replyIndex] = updatedComment;
          comments[i] = comments[i].copyWith(replies: updatedReplies);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error handling updated comment: $e');
    }
  }

  // Handle deleted comment from real-time
  void _handleDeletedComment(String commentId) {
    try {
      // Remove main comment
      comments.removeWhere((comment) => comment.id == commentId);
      
      // Remove from replies
      for (int i = 0; i < comments.length; i++) {
        final updatedReplies = comments[i].replies.where(
          (reply) => reply.id != commentId,
        ).toList();
        
        if (updatedReplies.length != comments[i].replies.length) {
          comments[i] = comments[i].copyWith(
            replies: updatedReplies,
            repliesCount: updatedReplies.length,
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling deleted comment: $e');
    }
  }

  // Handle comment like/unlike changes from real-time
  void _handleCommentLikeChange(Map<String, dynamic> likeData, bool isLiked) {
    try {
      final commentId = likeData['comment_id'];
      final userId = likeData['user_id'];
      final currentUserId = supabase.auth.currentUser?.id;
      
      // Update main comment
      for (int i = 0; i < comments.length; i++) {
        if (comments[i].id == commentId) {
          final currentComment = comments[i];
          final newLikesCount = isLiked 
            ? currentComment.likesCount + 1 
            : currentComment.likesCount - 1;
          
          final isCurrentUserAction = userId == currentUserId;
          
          comments[i] = currentComment.copyWith(
            likesCount: newLikesCount,
            isLikedByCurrentUser: isCurrentUserAction 
              ? isLiked 
              : currentComment.isLikedByCurrentUser,
          );
          return;
        }
        
        // Update reply
        for (int j = 0; j < comments[i].replies.length; j++) {
          if (comments[i].replies[j].id == commentId) {
            final currentReply = comments[i].replies[j];
            final newLikesCount = isLiked 
              ? currentReply.likesCount + 1 
              : currentReply.likesCount - 1;
            
            final isCurrentUserAction = userId == currentUserId;
            
            final updatedReplies = List<CommentModel>.from(comments[i].replies);
            updatedReplies[j] = currentReply.copyWith(
              likesCount: newLikesCount,
              isLikedByCurrentUser: isCurrentUserAction 
                ? isLiked 
                : currentReply.isLikedByCurrentUser,
            );
            
            comments[i] = comments[i].copyWith(replies: updatedReplies);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling comment like change: $e');
    }
  }

  // Load comments
  Future<void> loadComments() async {
    try {
      isLoading.value = true;
      final loadedComments = await _commentsService.getPostComments(postId);
      comments.value = loadedComments;
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل التعليقات: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add comment
  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    try {
      isAddingComment.value = true;

      final newComment = await _commentsService.addComment(
        postId: postId,
        text: text,
        parentCommentId: replyingTo.value?.id,
      );

      if (replyingTo.value != null) {
        // It's a reply - add to parent comment's replies
        final parentIndex = comments.indexWhere(
          (comment) => comment.id == replyingTo.value!.id,
        );
        if (parentIndex != -1) {
          final updatedReplies = List<CommentModel>.from(comments[parentIndex].replies);
          updatedReplies.add(newComment);
          comments[parentIndex] = comments[parentIndex].copyWith(
            replies: updatedReplies,
            repliesCount: updatedReplies.length,
          );
        }
        cancelReply();
      } else {
        // It's a main comment - add to comments list
        comments.insert(0, newComment);
      }

      commentController.clear();
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة التعليق: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAddingComment.value = false;
    }
  }

  // Toggle comment like
  Future<void> toggleCommentLike(String commentId) async {
    try {
      final isLiked = await _commentsService.toggleCommentLike(commentId);

      // Update comment in list
      for (int i = 0; i < comments.length; i++) {
        if (comments[i].id == commentId) {
          comments[i] = comments[i].copyWith(
            isLikedByCurrentUser: isLiked,
            likesCount: isLiked 
              ? comments[i].likesCount + 1 
              : comments[i].likesCount - 1,
          );
          return;
        }

        // Check replies
        for (int j = 0; j < comments[i].replies.length; j++) {
          if (comments[i].replies[j].id == commentId) {
            final updatedReplies = List<CommentModel>.from(comments[i].replies);
            updatedReplies[j] = updatedReplies[j].copyWith(
              isLikedByCurrentUser: isLiked,
              likesCount: isLiked 
                ? updatedReplies[j].likesCount + 1 
                : updatedReplies[j].likesCount - 1,
            );
            comments[i] = comments[i].copyWith(replies: updatedReplies);
            return;
          }
        }
      }
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في تسجيل الإعجاب: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Reply to comment
  void replyToComment(CommentModel comment) {
    replyingTo.value = comment;
    // Focus on text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(Get.context!).requestFocus(FocusNode());
    });
  }

  // Cancel reply
  void cancelReply() {
    replyingTo.value = null;
  }

  // Refresh comments
  Future<void> refreshComments() async {
    await loadComments();
  }
}