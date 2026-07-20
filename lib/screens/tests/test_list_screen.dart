import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/routes.dart';
import '../../services/firestore_service.dart';
import '../../models/test_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_list.dart';

class TestListScreen extends StatelessWidget {
  final String testType;
  const TestListScreen({super.key, required this.testType});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final type = TestType.values.firstWhere((t) => t.name == testType, orElse: () => TestType.daily);

    return Scaffold(
      appBar: AppBar(title: const Text('Tests')),
      body: StreamBuilder<List<TestModel>>(
        stream: firestore.testsByType(type),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingList(count: 5, height: 90);
          final tests = snapshot.data!;
          if (tests.isEmpty) {
            return const EmptyState(
              icon: Icons.quiz_outlined,
              title: 'No tests published yet',
              subtitle: 'New tests created in the Admin Panel will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final t = tests[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${t.subject} • ${t.durationMinutes} min • ${t.totalMarks} marks\n${DateFormat('MMM d, h:mm a').format(t.scheduledAt)}'),
                  isThreeLine: true,
                  trailing: FilledButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.testAttempt, arguments: t.id),
                    child: const Text('Start'),
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
