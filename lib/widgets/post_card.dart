import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get.dart';
import '../models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onView;
  final VoidCallback? onUserTap;
  final bool showMoreOptions;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onView,
    this.onUserTap,
    this.showMoreOptions = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _hasViewed = false;

  @override
  void initState() {
    super.initState();
    // Mark as viewed after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_hasViewed && mounted) {
        _hasViewed = true;
        widget.onView();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كان المنشور نصي فقط
    final isTextOnly = widget.post.type == 'text' || widget.post.mediaUrls.isEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: isTextOnly ? _buildTextOnlyPost() : _buildMediaPost(),
    );
  }

  // تصميم للمنشورات النصية فقط
  Widget _buildTextOnlyPost() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(),
        
        // النص الرئيسي مع تصميم محسن
        if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
          _buildTextContent(),
        
        // الأزرار في الأسفل
        _buildBottomSection(),
      ],
    );
  }

  // تصميم للمنشورات مع الوسائط - تصميم متناغم خرافي
  Widget _buildMediaPost() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          // تصميم متناغم للصورة مع النص والأزرار
          _buildIntegratedMediaContent(),
        ],
      ),
    );
  }

  // التصميم المتناغم الخرافي للصورة مع النص والأزرار
  Widget _buildIntegratedMediaContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // الصورة/الفيديو
            _buildMediaContent(),
            
            // الجزء السفلي المتناغم مع النص والأزرار
            _buildCurvedBottomSection(),
          ],
        ),
      ),
    );
  }

  // محتوى الوسائط بدون حواف منفصلة
  Widget _buildMediaContent() {
    if (widget.post.mediaUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: widget.post.mediaUrls.length == 1
          ? _buildSingleMediaContent(widget.post.mediaUrls.first)
          : _buildMediaCarouselContent(),
    );
  }

  Widget _buildSingleMediaContent(String mediaUrl) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(mediaUrl, 0),
      child: _buildImageWidget(mediaUrl),
    );
  }

  Widget _buildMediaCarouselContent() {
    return PageView.builder(
      itemCount: widget.post.mediaUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(widget.post.mediaUrls[index], index),
          child: _buildImageWidget(widget.post.mediaUrls[index]),
        );
      },
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.contains('placeholder') || imageUrl.contains('via.placeholder')) {
      return Container(
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'صورة تجريبية',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 8),
            Text(
              'فشل في تحميل الصورة',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الجزء السفلي المنحني المتناغم
  Widget _buildCurvedBottomSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade50,
          ],
        ),
      ),
      child: Column(
        children: [
          // منحنى علوي للتناغم
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          
          // النص إذا كان موجود
          if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
            _buildIntegratedCaption(),
          
          // الأزرار
          _buildIntegratedActions(),
          
          // معاينة التعليقات والوقت
          _buildIntegratedFooter(),
        ],
      ),
    );
  }

  // النص المتناغم
  Widget _buildIntegratedCaption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // النص
          Text(
            widget.post.caption!,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          // التاجز
          if (widget.post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.post.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // الأزرار المتناغمة
  Widget _buildIntegratedActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Like button
          _buildActionButton(
            icon: widget.post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
            color: widget.post.isLikedByCurrentUser ? Colors.red : null,
            count: widget.post.likesCount,
            onTap: widget.onLike,
            isActive: widget.post.isLikedByCurrentUser,
          ),
          
          const SizedBox(width: 12),
          
          // Comment button
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            count: widget.post.commentsCount,
            onTap: widget.onComment,
          ),
          
          const SizedBox(width: 12),
          
          // Share button
          _buildActionButton(
            icon: Icons.send_outlined,
            onTap: widget.onShare,
          ),
          
          const Spacer(),
          
          // Save button
          _buildActionButton(
            icon: Icons.bookmark_border,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // زر عمل مخصص
  Widget _buildActionButton({
    required IconData icon,
    Color? color,
    int? count,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? (color ?? Colors.blue).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: color ?? Theme.of(context).iconTheme.color,
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // الفوتر المتناغم
  Widget _buildIntegratedFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معاينة التعليقات
          if (widget.post.commentsCount > 0)
            GestureDetector(
              onTap: widget.onComment,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${'view_all_comments'.tr} ${widget.post.commentsCount}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          
          // الوقت والمشاهدات
          Row(
            children: [
              Text(
                timeago.format(widget.post.createdAt, locale: 'ar'),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              if (widget.post.viewsCount > 0) ...[
                const SizedBox(width: 16),
                Text(
                  '${widget.post.viewsCount} ${'views'.tr}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl, int initialIndex) {
    // TODO: Implement full screen image view
  }
  Widget _buildTextContent() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade50,
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // النص مع تنسيق جميل
          Text(
            widget.post.caption!,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          // التاجز إذا كانت موجودة
          if (widget.post.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.post.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // قسم الأسفل للمنشورات النصية
  Widget _buildBottomSection() {
    return Column(
      children: [
        const SizedBox(height: 12),
        
        // الأزرار للمنشورات النصية
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Like button
              _buildActionButton(
                icon: widget.post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                color: widget.post.isLikedByCurrentUser ? Colors.red : null,
                count: widget.post.likesCount,
                onTap: widget.onLike,
                isActive: widget.post.isLikedByCurrentUser,
              ),
              
              const SizedBox(width: 12),
              
              // Comment button
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                count: widget.post.commentsCount,
                onTap: widget.onComment,
              ),
              
              const SizedBox(width: 12),
              
              // Share button
              _buildActionButton(
                icon: Icons.send_outlined,
                onTap: widget.onShare,
              ),
              
              const Spacer(),
              
              // Save button
              _buildActionButton(
                icon: Icons.bookmark_border,
                onTap: () {},
              ),
            ],
          ),
        ),
        
        // معاينة التعليقات والوقت
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معاينة التعليقات
              if (widget.post.commentsCount > 0)
                GestureDetector(
                  onTap: widget.onComment,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${'view_all_comments'.tr} ${widget.post.commentsCount}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              
              // الوقت والمشاهدات
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      timeago.format(widget.post.createdAt, locale: 'ar'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (widget.post.viewsCount > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${widget.post.viewsCount} ${'views'.tr}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Profile image
          GestureDetector(
            onTap: widget.onUserTap ?? () {
              Get.snackbar(
                'قريباً',
                'سيتم إضافة صفحة الملف الشخصي قريباً',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundImage: widget.post.userProfileImage != null
                  ? CachedNetworkImageProvider(widget.post.userProfileImage!)
                  : null,
              child: widget.post.userProfileImage == null
                  ? Text(widget.post.username[0].toUpperCase())
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          
          // Username and location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onUserTap ?? () {
                        Get.snackbar(
                          'قريباً',
                          'سيتم إضافة صفحة الملف الشخصي قريباً',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        widget.post.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    if (widget.post.isUserVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                if (widget.post.location != null && widget.post.location!.isNotEmpty)
                  Text(
                    widget.post.location!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          
          // More options
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: const Icon(Icons.more_vert),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: Text('copy_link'.tr),
              onTap: () {
                Navigator.pop(context);
                // TODO: Copy link
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: Text('report_post'.tr),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report post
              },
            ),
            if (widget.post.userId == 'current_user_id') // TODO: Check actual user
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('delete_post'.tr, style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Delete post
                },
              ),
          ],
        ),
      ),
    );
  }
}