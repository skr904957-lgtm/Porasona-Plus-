import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../services/storage_service.dart';
import '../../models/test_model.dart';
import '../../widgets/empty_state.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  final _storage = StorageService();

  void _showAddQuestionDialog({required bool descriptive}) {
    final questionCtrl = TextEditingController();
    final optionCtrls = List.generate(4, (_) => TextEditingController());
    int correctIndex = 0;
    String? testId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(descriptive ? 'Add Descriptive Question' : 'Add MCQ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('tests').snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Attach to Test'),
                      items: docs.map((d) => DropdownMenuItem(value: d.id, child: Text((d.data() as Map)['title'] ?? d.id))).toList(),
                      onChanged: (v) => testId = v,
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: questionCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Question Text')),
                if (!descriptive) ...[
                  const SizedBox(height: 10),
                  ...List.generate(4, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Radio<int>(value: i, groupValue: correctIndex, onChanged: (v) => setState(() => correctIndex = v!)),
                            Expanded(child: TextField(controller: optionCtrls[i], decoration: InputDecoration(labelText: 'Option ${i + 1}'))),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (questionCtrl.text.trim().isEmpty || testId == null) return;
                      final qId = const Uuid().v4();
                      await FirebaseFirestore.instance.collection('questions').doc(qId).set({
                        'questionText': questionCtrl.text.trim(),
                        'options': descriptive ? [] : optionCtrls.map((c) => c.text.trim()).toList(),
                        'correctOptionIndex': descriptive ? -1 : correctIndex,
                        'isDescriptive': descriptive,
                      });
                      await FirebaseFirestore.instance.collection('tests').doc(testId).update({
                        'questionIds': FieldValue.arrayUnion([qId]),
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Save Question'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadAnswerKey() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    final url = await _storage.uploadFile(
      file: file,
      folder: 'answer_keys',
      fileName: '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}',
    );
    await FirebaseFirestore.instance.collection('answer_keys').add({
      'url': url,
      'uploadedAt': DateTime.now().millisecondsSinceEpoch,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Answer key uploaded')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question Bank')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddQuestionDialog(descriptive: false),
                    icon: const Icon(Icons.check_box_outlined),
                    label: const Text('Add MCQ'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddQuestionDialog(descriptive: true),
                    icon: const Icon(Icons.subject),
                    label: const Text('Descriptive'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _uploadAnswerKey,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Answer Key (PDF)'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('questions').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const EmptyState(icon: Icons.help_outline, title: 'No questions added yet');
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(data['isDescriptive'] == true ? Icons.subject : Icons.check_box_outlined, color: AppColors.primary),
                      title: Text(data['questionText'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => docs[i].reference.delete()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
