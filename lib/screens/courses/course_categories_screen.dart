import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../services/firestore_service.dart';
import '../../models/course_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_list.dart';

class CourseCategoriesScreen extends StatefulWidget {
  const CourseCategoriesScreen({super.key});

  @override
  State<CourseCategoriesScreen> createState() => _CourseCategoriesScreenState();
}

class _CourseCategoriesScreenState extends State<CourseCategoriesScreen> {
  final _firestore = FirestoreService();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestore.categories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    _CategoryChip(
                      label: 'All',
                      selected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    ...categories.map((c) => _CategoryChip(
                          label: c['name'] ?? '',
                          selected: _selectedCategory == c['name'],
                          onTap: () => setState(() => _selectedCategory = c['name']),
                        )),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CourseModel>>(
              stream: _firestore.courses(category: _selectedCategory),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LoadingList(count: 5, height: 100);
                final courses = snapshot.data!;
                if (courses.isEmpty) {
                  return const EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: 'No courses in this category yet',
                    subtitle: 'The admin can publish courses from the Admin Panel.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = courses[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          child: const Icon(Icons.menu_book, color: AppColors.primary),
                        ),
                        title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${c.subject} • ${c.teacherName}'),
                        trailing: c.isPremium
                            ? Text('₹${c.effectivePrice.toStringAsFixed(0)}',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                            : const Text('FREE', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.courseDetails, arguments: c.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      ),
    );
  }
}
