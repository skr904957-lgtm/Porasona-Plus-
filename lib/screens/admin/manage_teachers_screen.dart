import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/theme.dart';
import '../../widgets/empty_state.dart';

class ManageTeachersScreen extends StatelessWidget {
  const ManageTeachersScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Teacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('teachers').add({
                'name': nameCtrl.text.trim(),
                'subject': subjectCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'createdAt': DateTime.now().millisecondsSinceEpoch,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Teachers')),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context), child: const Icon(Icons.add)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.school_outlined,
              title: 'No teachers added yet',
              subtitle: 'Tap + to add your first teacher.',
            );
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.secondary, child: Icon(Icons.person, color: AppColors.primary)),
                title: Text(data['name'] ?? ''),
                subtitle: Text('${data['subject'] ?? ''} • ${data['email'] ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => docs[i].reference.delete(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
