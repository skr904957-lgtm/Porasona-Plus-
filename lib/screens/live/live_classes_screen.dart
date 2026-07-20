import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/live_class_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_list.dart';

class LiveClassesScreen extends StatelessWidget {
  const LiveClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Live Classes')),
      body: StreamBuilder<List<LiveClassModel>>(
        stream: firestore.liveClasses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingList(count: 4, height: 100);
          final classes = snapshot.data!;
          if (classes.isEmpty) {
            return const EmptyState(
              icon: Icons.videocam_off_outlined,
              title: 'No live classes scheduled',
              subtitle: 'Your teachers will schedule live classes from the Admin Panel.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final lc = classes[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: lc.isLive ? Colors.red.shade50 : AppColors.secondary,
                    child: Icon(Icons.videocam, color: lc.isLive ? Colors.red : AppColors.primary),
                  ),
                  title: Text(lc.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${lc.subject} • ${lc.teacherName}\n${DateFormat('MMM d, h:mm a').format(lc.scheduledAt)}'),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lc.isLive ? Colors.red : AppColors.primary,
                    ),
                    onPressed: lc.meetingUrl.isEmpty
                        ? null
                        : () => launchUrl(Uri.parse(lc.meetingUrl), mode: LaunchMode.externalApplication),
                    child: Text(lc.isLive ? 'Join' : 'Details'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
