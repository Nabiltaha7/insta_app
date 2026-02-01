import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import '../constants/app_constants.dart';

class CommentsService extends GetxService {
  final supabase = Supabase.instance.client;

  // Get comments for a post
  Future<List<CommentModel>> getPostComments(String postId) async {
    try {
      final response = await supabase
          .from('comments')
          .select('*')
          .eq('post_id', postId)
          .isFilter('parent_comment_id', null)
          .order('created_at', ascending: false);

      final comments = (response as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList();

      // Get replies for each comment
      for (int i = 0; i < comments.length; i++) {
        final replies = await getCommentReplies(comments[i].id);
        comments[i] = comments[i].copyWith(replies: replies);
      }

      // Check if current user liked each comment
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        for (int i = 0; i < comments.length; i++) {
          final isLiked = comments[i].likedBy.contains(currentUserId);
          comments[i] = comments[i].copyWith(isLikedByCurrentUser: isLiked);
          
          // Check replies too
          for (int j = 0; j < comments[i].replies.length; j++) {
            final isReplyLiked = comments[i].replies[j].likedBy.contains(currentUserId);
            comments[i].replies[j] = comments[i].replies[j].copyWith(
              isLikedByCurrentUser: isReplyLiked,
            );
          }
        }
      }

      return comments;
    } catch (error) {
      if (error.toString().contains('does not exist') || 
          error.toString().contains('relation') ||
          error.toString().contains('table')) {
        return [];
      }
      throw Exception('خطأ في تحميل التعليقات: $error');
    }
  }

  // Get replies for a comment
  Future<List<CommentModel>> getCommentReplies(String commentId) async {
    try {
      final response = await supabase
          .from('comments')
          .select('*')
          .eq('parent_comment_id', commentId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((reply) => CommentModel.fromJson(reply))
          .toList();
    } catch (error) {
      return [];
    }
  }

  // Add comment
  Future<CommentModel> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      // Get user profile
      final userProfile = await supabase
          .from(AppConstants.usersTable)
          .select('username, profile_image_url, is_verified')
          .eq('id', currentUser.id)
          .single();

      final commentData = {
        'post_id': postId,
        'user_id': currentUser.id,
        'username': userProfile['username'],
        'user_profile_image': userProfile['profile_image_url'],
        'is_user_verified': userProfile['is_verified'] ?? false,
        'text': text,
        'parent_comment_id': parentCommentId,
      };

      final response = await supabase
          .from('comments')
          .insert(commentData)
          .select()
          .single();

      return CommentModel.fromJson(response);
    } catch (error) {
      throw Exception('خطأ في إضافة التعليق: $error');
    }
  }

  // Like/Unlike comment
  Future<bool> toggleCommentLike(String commentId) async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      // Get current liked_by array
      final comment = await supabase
          .from('comments')
          .select('liked_by')
          .eq('id', commentId)
          .single();

      List<String> likedBy = List<String>.from(comment['liked_by'] ?? []);
      bool isLiked;

      if (likedBy.contains(currentUserId)) {
        // Unlike
        likedBy.remove(currentUserId);
        isLiked = false;
      } else {
        // Like
        likedBy.add(currentUserId);
        isLiked = true;
      }

      // Update comment
      await supabase.from('comments').update({
        'liked_by': likedBy,
        'likes_count': likedBy.length,
      }).eq('id', commentId);

      return isLiked;
    } catch (error) {
      throw Exception('خطأ في تسجيل الإعجاب: $error');
    }
  }
}