import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final uid = context.watch<AuthProvider>().firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: uid == null
          ? const EmptyState(title: 'Please log in to see notifications')
          : StreamBuilder<List<NotificationModel>>(
              stream: firestore.notifications(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.notifications_none,
                    title: 'No notifications yet',
                    subtitle: 'Announcements and updates will show up here.',
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = items[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        child: const Icon(Icons.campaign_outlined, color: AppColors.primary),
                      ),
                      title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(n.body),
                      trailing: Text(DateFormat('MMM d').format(n.sentAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    );
                  },
                );
              },
            ),
    );
  }
}
