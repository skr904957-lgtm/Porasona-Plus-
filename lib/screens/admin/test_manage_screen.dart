import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/test_model.dart';
import '../../widgets/empty_state.dart';

class TestManageScreen extends StatefulWidget {
  const TestManageScreen({super.key});

  @override
  State<TestManageScreen> createState() => _TestManageScreenState();
}

class _TestManageScreenState extends State<TestManageScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _types = TestType.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
  }

  void _showForm(BuildContext context, TestType type) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '30');
    final marksCtrl = TextEditingController(text: '100');
    DateTime scheduledAt = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create ${type.name} Test', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Test Title')),
              const SizedBox(height: 10),
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
              const SizedBox(height: 10),
              TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (minutes)')),
              const SizedBox(height: 10),
              TextField(controller: marksCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Marks')),
              const SizedBox(height: 16),
              const Text('Tip: add questions to this test from the Question Bank tab after creating it.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final test = TestModel(
                      id: const Uuid().v4(),
                      title: titleCtrl.text.trim(),
                      type: type,
                      subject: subjectCtrl.text.trim(),
                      durationMinutes: int.tryParse(durationCtrl.text) ?? 30,
                      totalMarks: int.tryParse(marksCtrl.text) ?? 100,
                      scheduledAt: scheduledAt,
                    );
                    await FirestoreService().addTest(test);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Create Test'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tests'),
        bottom: TabBar(controller: _tabController, isScrollable: true, indicatorColor: Colors.white, tabs: _types.map((t) => Tab(text: t.name)).toList()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, _types[_tabController.index]),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _types.map((type) {
          return StreamBuilder<List<TestModel>>(
            stream: firestore.testsByType(type),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final tests = snapshot.data!;
              if (tests.isEmpty) {
                return const EmptyState(icon: Icons.quiz_outlined, title: 'No tests yet', subtitle: 'Tap + to create one.');
              }
              return ListView.separated(
                itemCount: tests.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final t = tests[i];
                  return ListTile(
                    leading: const Icon(Icons.quiz_outlined, color: AppColors.primary),
                    title: Text(t.title),
                    subtitle: Text('${t.subject} • ${t.questionIds.length} questions • ${DateFormat('MMM d').format(t.scheduledAt)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => FirebaseFirestore.instance.collection('tests').doc(t.id).delete(),
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
