import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/student_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_list.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final myUid = context.watch<AuthProvider>().firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<List<StudentModel>>(
        stream: firestore.leaderboard(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingList(count: 8, height: 60);
          final students = snapshot.data!;
          if (students.isEmpty) {
            return const EmptyState(
              icon: Icons.leaderboard_outlined,
              title: 'Leaderboard is empty',
              subtitle: 'Earn points by completing tests to appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: students.length,
            itemBuilder: (_, i) {
              final s = students[i];
              final isMe = s.uid == myUid;
              return Card(
                color: isMe ? AppColors.secondary : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: i < 3 ? Colors.amber.shade600 : AppColors.secondary,
                    child: Text('${i + 1}', style: TextStyle(color: i < 3 ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(s.name.isNotEmpty ? s.name : 'Student', style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text('${s.totalPoints} pts', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
