import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';

class TestsHomeScreen extends StatelessWidget {
  const TestsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      {'title': 'Daily Online Test', 'type': 'daily', 'icon': Icons.today_outlined},
      {'title': 'Weekly Test', 'type': 'weekly', 'icon': Icons.calendar_view_week_outlined},
      {'title': 'Mock Test', 'type': 'mock', 'icon': Icons.assignment_outlined},
      {'title': 'Previous Year Questions', 'type': 'previousYear', 'icon': Icons.history_edu_outlined},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tests')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.05,
        ),
        itemCount: tiles.length,
        itemBuilder: (_, i) {
          final t = tiles[i];
          return Card(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.testList, arguments: t['type']),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(t['icon'] as IconData, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(t['title'] as String, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
