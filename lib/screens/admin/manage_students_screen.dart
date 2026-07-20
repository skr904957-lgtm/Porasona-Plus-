import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/student_model.dart';
import '../../widgets/empty_state.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: StreamBuilder<List<StudentModel>>(
        stream: firestore.allStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final students = snapshot.data!;
          if (students.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'No students registered yet',
              subtitle: 'Students will appear here as they sign up.',
            );
          }
          return ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = students[i];
              return ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.secondary, child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?')),
                title: Text(s.name.isNotEmpty ? s.name : 'Unnamed'),
                subtitle: Text('${s.email}\nClass: ${s.classGrade.isEmpty ? '-' : s.classGrade} • ${s.totalPoints} pts'),
                isThreeLine: true,
                trailing: s.isPremium ? const Icon(Icons.workspace_premium, color: Colors.amber) : null,
              );
            },
          );
        },
      ),
    );
  }
}
