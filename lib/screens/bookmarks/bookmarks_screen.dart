import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/course_model.dart';
import '../../widgets/course_card.dart';
import '../../widgets/empty_state.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final bookmarkedIds = context.watch<AuthProvider>().student?.bookmarkedCourseIds ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: StreamBuilder<List<CourseModel>>(
        stream: firestore.courses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final courses = snapshot.data!.where((c) => bookmarkedIds.contains(c.id)).toList();
          if (courses.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No bookmarks yet',
              subtitle: 'Tap the bookmark icon on a course to save it here.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemCount: courses.length,
            itemBuilder: (_, i) => CourseCard(
              course: courses[i],
              onTap: () => Navigator.pushNamed(context, AppRoutes.courseDetails, arguments: courses[i].id),
            ),
          );
        },
      ),
    );
  }
}
