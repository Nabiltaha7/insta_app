class PostModel {
  final String id;
  final String userId;
  final String username;
  final String? userProfileImage;
  final bool isUserVerified;
  final String? caption;
  final List<String> mediaUrls;
  final String type; // 'image', 'carousel', 'text' (no video support)
  final List<String> tags;
  final String? location;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool commentsEnabled;
  final bool likesVisible;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double trendingScore;
  final bool isPremiumContent;
  final bool hasPriorityInTrending;
  final bool isLikedByCurrentUser;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userProfileImage,
    this.isUserVerified = false,
    this.caption,
    this.mediaUrls = const [],
    this.type = 'image',
    this.tags = const [],
    this.location,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.commentsEnabled = true,
    this.likesVisible = true,
    required this.createdAt,
    required this.updatedAt,
    this.trendingScore = 0.0,
    this.isPremiumContent = false,
    this.hasPriorityInTrending = false,
    this.isLikedByCurrentUser = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      userProfileImage: json['user_profile_image'],
      isUserVerified: json['is_user_verified'] ?? false,
      caption: json['caption'],
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      type: json['type'] ?? 'image',
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      commentsEnabled: json['comments_enabled'] ?? true,
      likesVisible: json['likes_visible'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      trendingScore: 0.0, // قيمة افتراضية
      isPremiumContent: json['is_premium_content'] ?? false,
      hasPriorityInTrending: json['has_priority_in_trending'] ?? false,
      isLikedByCurrentUser: json['is_liked_by_current_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'user_profile_image': userProfileImage,
      'is_user_verified': isUserVerified,
      'caption': caption,
      'media_urls': mediaUrls,
      'type': type,
      'tags': tags,
      'location': location,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'views_count': viewsCount,
      'comments_enabled': commentsEnabled,
      'likes_visible': likesVisible,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'trending_score': trendingScore,
      'is_premium_content': isPremiumContent,
      'has_priority_in_trending': hasPriorityInTrending,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userProfileImage,
    bool? isUserVerified,
    String? caption,
    List<String>? mediaUrls,
    String? type,
    List<String>? tags,
    String? location,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    bool? commentsEnabled,
    bool? likesVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? trendingScore,
    bool? isPremiumContent,
    bool? hasPriorityInTrending,
    bool? isLikedByCurrentUser,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      isUserVerified: isUserVerified ?? this.isUserVerified,
      caption: caption ?? this.caption,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      likesVisible: likesVisible ?? this.likesVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trendingScore: trendingScore ?? this.trendingScore,
      isPremiumContent: isPremiumContent ?? this.isPremiumContent,
      hasPriorityInTrending: hasPriorityInTrending ?? this.hasPriorityInTrending,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}