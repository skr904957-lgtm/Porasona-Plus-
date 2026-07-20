import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import 'manage_students_screen.dart';
import 'manage_teachers_screen.dart';
import 'manage_courses_screen.dart';
import 'manage_categories_screen.dart';
import 'upload_content_screen.dart';
import 'live_class_manage_screen.dart';
import 'test_manage_screen.dart';
import 'question_bank_screen.dart';
import 'push_notifications_screen.dart';
import 'announcements_screen.dart';
import 'banner_manage_screen.dart';
import 'payments_manage_screen.dart';
import 'app_settings_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_AdminItem>[
      _AdminItem('Manage Students', Icons.people_outline, (_) => const ManageStudentsScreen()),
      _AdminItem('Manage Teachers', Icons.school_outlined, (_) => const ManageTeachersScreen()),
      _AdminItem('Manage Courses', Icons.menu_book_outlined, (_) => const ManageCoursesScreen()),
      _AdminItem('Manage Categories', Icons.category_outlined, (_) => const ManageCategoriesScreen()),
      _AdminItem('Upload Content', Icons.upload_file_outlined, (_) => const UploadContentScreen()),
      _AdminItem('Live Classes', Icons.videocam_outlined, (_) => const LiveClassManageScreen()),
      _AdminItem('Manage Tests', Icons.quiz_outlined, (_) => const TestManageScreen()),
      _AdminItem('Question Bank', Icons.help_outline, (_) => const QuestionBankScreen()),
      _AdminItem('Push Notifications', Icons.notifications_active_outlined, (_) => const PushNotificationsScreen()),
      _AdminItem('Announcements', Icons.campaign_outlined, (_) => const AnnouncementsScreen()),
      _AdminItem('Homepage Banners', Icons.image_outlined, (_) => const BannerManageScreen()),
      _AdminItem('Payments & Revenue', Icons.payments_outlined, (_) => const PaymentsManageScreen()),
      _AdminItem('App Settings', Icons.settings_outlined, (_) => const AppSettingsScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminLogin, (route) => false);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _StatsRow(),
          const SizedBox(height: 20),
          const Text('Manage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Card(
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: item.builder)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: AppColors.primary, size: 28),
                        const SizedBox(height: 10),
                        Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminItem {
  final String label;
  final IconData icon;
  final Widget Function(BuildContext) builder;
  _AdminItem(this.label, this.icon, this.builder);
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  Stream<int> _count(String collection) {
    return FirebaseFirestore.instance.collection(collection).snapshots().map((s) => s.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Students', stream: _count('students'), icon: Icons.people)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Courses', stream: _count('courses'), icon: Icons.menu_book)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Purchases', stream: _count('purchases'), icon: Icons.payments)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final Stream<int> stream;
  final IconData icon;
  const _StatCard({required this.label, required this.stream, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: stream,
              builder: (context, snapshot) => Text('${snapshot.data ?? 0}',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
