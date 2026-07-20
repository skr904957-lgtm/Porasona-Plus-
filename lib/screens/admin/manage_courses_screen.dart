import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/course_model.dart';
import '../../widgets/empty_state.dart';

class ManageCoursesScreen extends StatelessWidget {
  const ManageCoursesScreen({super.key});

  void _showCourseForm(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final teacherCtrl = TextEditingController();
    final thumbnailCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '0');
    final discountCtrl = TextEditingController(text: '0');
    bool isPremium = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Course Title')),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 10),
                TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
                const SizedBox(height: 10),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 10),
                TextField(controller: teacherCtrl, decoration: const InputDecoration(labelText: 'Teacher Name')),
                const SizedBox(height: 10),
                TextField(controller: thumbnailCtrl, decoration: const InputDecoration(labelText: 'Thumbnail Image URL (from Storage)')),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Premium Course'),
                  value: isPremium,
                  onChanged: (v) => setState(() => isPremium = v),
                ),
                if (isPremium) ...[
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)')),
                  const SizedBox(height: 10),
                  TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount Price (₹, optional)')),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final course = CourseModel(
                        id: const Uuid().v4(),
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        subject: subjectCtrl.text.trim(),
                        category: categoryCtrl.text.trim(),
                        teacherName: teacherCtrl.text.trim(),
                        thumbnailUrl: thumbnailCtrl.text.trim(),
                        isPremium: isPremium,
                        price: double.tryParse(priceCtrl.text) ?? 0,
                        discountPrice: double.tryParse(discountCtrl.text) ?? 0,
                        createdAt: DateTime.now(),
                      );
                      await FirestoreService().addCourse(course);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Publish Course'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Courses')),
      floatingActionButton: FloatingActionButton(onPressed: () => _showCourseForm(context), child: const Icon(Icons.add)),
      body: StreamBuilder<List<CourseModel>>(
        stream: firestore.courses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final courses = snapshot.data!;
          if (courses.isEmpty) {
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No courses yet',
              subtitle: 'Tap + to publish your first course.',
            );
          }
          return ListView.separated(
            itemCount: courses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = courses[i];
              return ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.secondary, child: Icon(Icons.menu_book, color: AppColors.primary)),
                title: Text(c.title),
                subtitle: Text('${c.subject} • ${c.isPremium ? '₹${c.effectivePrice.toStringAsFixed(0)}' : 'FREE'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => firestore.deleteCourse(c.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
