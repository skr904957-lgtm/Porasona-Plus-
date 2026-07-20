import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final student = auth.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.secondary,
                  backgroundImage: (student?.photoUrl?.isNotEmpty ?? false) ? NetworkImage(student!.photoUrl!) : null,
                  child: (student?.photoUrl?.isNotEmpty ?? false)
                      ? null
                      : const Icon(Icons.person, size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(student?.name.isNotEmpty == true ? student!.name : 'Student',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(student?.email ?? '', style: const TextStyle(color: Colors.grey)),
                if (student?.isPremium == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(20)),
                      child: const Text('PREMIUM MEMBER', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Streak', value: '${student?.studyStreak ?? 0}')),
              const SizedBox(width: 12),
              Expanded(child: _StatBox(label: 'Points', value: '${student?.totalPoints ?? 0}')),
              const SizedBox(width: 12),
              Expanded(child: _StatBox(label: 'Courses', value: '${student?.purchasedCourseIds.length ?? 0}')),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileTile(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile)),
          _ProfileTile(icon: Icons.shopping_bag_outlined, label: 'My Purchased Courses', onTap: () => Navigator.pushNamed(context, AppRoutes.myPurchases)),
          _ProfileTile(icon: Icons.receipt_long_outlined, label: 'Payment History', onTap: () => Navigator.pushNamed(context, AppRoutes.paymentHistory)),
          _ProfileTile(icon: Icons.bookmark_border, label: 'Bookmarks', onTap: () => Navigator.pushNamed(context, AppRoutes.bookmarks)),
          _ProfileTile(icon: Icons.download_outlined, label: 'Downloads', onTap: () => Navigator.pushNamed(context, AppRoutes.downloads)),
          _ProfileTile(icon: Icons.leaderboard_outlined, label: 'Leaderboard', onTap: () => Navigator.pushNamed(context, AppRoutes.leaderboard)),
          _ProfileTile(icon: Icons.emoji_events_outlined, label: 'Achievement Badges', onTap: () => Navigator.pushNamed(context, AppRoutes.achievements)),
          _ProfileTile(icon: Icons.settings_outlined, label: 'Settings', onTap: () => Navigator.pushNamed(context, AppRoutes.settings)),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.logout,
            label: 'Log Out',
            color: AppColors.error,
            onTap: () async {
              await auth.logout();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
