import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/course_model.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: FutureBuilder<CourseModel?>(
        future: firestore.getCourse(courseId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final course = snapshot.data;
          if (course == null) {
            return const Center(child: Text('This course is no longer available.'));
          }

          final purchased = auth.student?.purchasedCourseIds.contains(course.id) ?? false;
          final locked = course.isPremium && !purchased;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: course.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: course.thumbnailUrl, fit: BoxFit.cover)
                      : Container(color: AppColors.secondary),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(course.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                          if (course.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(20)),
                              child: const Text('PREMIUM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${course.subject} • by ${course.teacherName}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Text(course.description),
                      const SizedBox(height: 20),
                      const Text('Course Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...course.videoIds.map((v) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(locked ? Icons.lock_outline : Icons.play_circle_outline, color: AppColors.primary),
                            title: const Text('Video Lesson'),
                            onTap: locked
                                ? () => Navigator.pushNamed(context, AppRoutes.checkout, arguments: course.id)
                                : () => Navigator.pushNamed(context, AppRoutes.videoPlayer,
                                    arguments: {'url': v, 'title': course.title}),
                          )),
                      ...course.pdfIds.map((p) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(locked ? Icons.lock_outline : Icons.picture_as_pdf_outlined, color: AppColors.primary),
                            title: const Text('Notes / PDF'),
                            onTap: locked
                                ? () => Navigator.pushNamed(context, AppRoutes.checkout, arguments: course.id)
                                : () => Navigator.pushNamed(context, AppRoutes.pdfViewer,
                                    arguments: {'url': p, 'title': course.title}),
                          )),
                      if (course.videoIds.isEmpty && course.pdfIds.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Content for this course will appear here once the admin uploads it.',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<CourseModel?>(
        future: firestore.getCourse(courseId),
        builder: (context, snapshot) {
          final course = snapshot.data;
          if (course == null || !course.isPremium) return const SizedBox.shrink();
          final purchased = auth.student?.purchasedCourseIds.contains(course.id) ?? false;
          if (purchased) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout, arguments: course.id),
                child: Text('Buy Now • ₹${course.effectivePrice.toStringAsFixed(0)}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
