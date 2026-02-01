class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? userProfileImage;
  final bool isUserVerified;
  final String text;
  final int likesCount;
  final List<String> likedBy;
  final String? parentCommentId;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final bool isLikedByCurrentUser;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.userProfileImage,
    this.isUserVerified = false,
    required this.text,
    this.likesCount = 0,
    this.likedBy = const [],
    this.parentCommentId,
    this.repliesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    this.isLikedByCurrentUser = false,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      userProfileImage: json['user_profile_image'],
      isUserVerified: json['is_user_verified'] ?? false,
      text: json['text'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      likedBy: List<String>.from(json['liked_by'] ?? []),
      parentCommentId: json['parent_comment_id'],
      repliesCount: json['replies_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isEdited: json['is_edited'] ?? false,
      isLikedByCurrentUser: json['is_liked_by_current_user'] ?? false,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((reply) => CommentModel.fromJson(reply))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'username': username,
      'user_profile_image': userProfileImage,
      'is_user_verified': isUserVerified,
      'text': text,
      'likes_count': likesCount,
      'liked_by': likedBy,
      'parent_comment_id': parentCommentId,
      'replies_count': repliesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_edited': isEdited,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? userProfileImage,
    bool? isUserVerified,
    String? text,
    int? likesCount,
    List<String>? likedBy,
    String? parentCommentId,
    int? repliesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    bool? isLikedByCurrentUser,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      isUserVerified: isUserVerified ?? this.isUserVerified,
      text: text ?? this.text,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      replies: replies ?? this.replies,
    );
  }
}