import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/posts_controller.dart';

class FilterTabs extends StatelessWidget {
  const FilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final PostsController postsController = Get.find<PostsController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _buildModernTab(
              'الأحدث',
              Icons.access_time_rounded,
              'trending',
              postsController.currentFilter.value == 'trending',
              postsController,
            ),
            _buildModernTab(
              'الأكثر شعبية',
              Icons.trending_up_rounded,
              'popular',
              postsController.currentFilter.value == 'popular',
              postsController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTab(
    String title,
    IconData icon,
    String filter,
    bool isSelected,
    PostsController controller,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    isSelected
                        ? Colors.white
                        : Get.theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : Get.theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
