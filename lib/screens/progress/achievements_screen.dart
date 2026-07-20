import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';

class _Badge {
  final String title;
  final IconData icon;
  final bool unlocked;
  const _Badge(this.title, this.icon, this.unlocked);
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().student;
    final streak = student?.studyStreak ?? 0;
    final points = student?.totalPoints ?? 0;
    final purchased = student?.purchasedCourseIds.length ?? 0;

    final badges = [
      _Badge('7-Day Streak', Icons.local_fire_department, streak >= 7),
      _Badge('30-Day Streak', Icons.whatshot, streak >= 30),
      _Badge('100 Points', Icons.star, points >= 100),
      _Badge('500 Points', Icons.stars, points >= 500),
      _Badge('First Course', Icons.school, purchased >= 1),
      _Badge('5 Courses', Icons.workspace_premium, purchased >= 5),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Achievement Badges')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1,
        ),
        itemCount: badges.length,
        itemBuilder: (_, i) {
          final b = badges[i];
          return Card(
            color: b.unlocked ? null : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(b.icon, size: 40, color: b.unlocked ? AppColors.primary : Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text(b.title, textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600, color: b.unlocked ? Colors.black : Colors.grey)),
                  if (!b.unlocked) const Text('Locked', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
