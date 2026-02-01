import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:get/get.dart';

class MediaCarousel extends StatefulWidget {
  final List<String> mediaUrls;
  final String type;

  const MediaCarousel({
    super.key,
    required this.mediaUrls,
    required this.type,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.mediaUrls.length > 1) {
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.mediaUrls.length == 1) {
      return _buildSingleImage(widget.mediaUrls.first);
    }

    return _buildImageCarousel();
  }

  Widget _buildSingleImage(String imageUrl) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl, 0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildImageWidget(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.mediaUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showFullScreenImage(widget.mediaUrls[index], index),
                    child: _buildImageWidget(widget.mediaUrls[index]),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Dots indicator
        if (widget.mediaUrls.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.mediaUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == index
                        ? Colors.blue
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenImage(String imageUrl, int initialIndex) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: PageView.builder(
          controller: PageController(initialPage: initialIndex),
          itemCount: widget.mediaUrls.length,
          itemBuilder: (context, index) {
            return PhotoView(
              imageProvider: _getImageProvider(widget.mediaUrls[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              heroAttributes: PhotoViewHeroAttributes(tag: widget.mediaUrls[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    // Check if it's a placeholder URL
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

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.contains('placeholder') || imageUrl.contains('via.placeholder')) {
      // For placeholder URLs, use a default asset or network image
      return const AssetImage('assets/images/placeholder.png');
    }
    return CachedNetworkImageProvider(imageUrl);
  }
}