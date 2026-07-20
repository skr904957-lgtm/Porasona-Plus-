import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app/theme.dart';
import '../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const CourseCard({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: course.thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: course.thumbnailUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.secondary),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.secondary,
                              child: const Icon(Icons.image_not_supported_outlined, color: AppColors.primary),
                            ),
                          )
                        : Container(
                            color: AppColors.secondary,
                            child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 36),
                          ),
                  ),
                  if (course.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('PREMIUM', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(course.subject, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    if (course.isPremium)
                      Row(
                        children: [
                          if (course.discountPrice > 0 && course.discountPrice < course.price) ...[
                            Text('₹${course.price.toStringAsFixed(0)}',
                                style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                            const SizedBox(width: 6),
                          ],
                          Text('₹${course.effectivePrice.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      )
                    else
                      const Text('FREE', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
