import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/test_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class TestAttemptScreen extends StatefulWidget {
  final String testId;
  const TestAttemptScreen({super.key, required this.testId});

  @override
  State<TestAttemptScreen> createState() => _TestAttemptScreenState();
}

class _TestAttemptScreenState extends State<TestAttemptScreen> {
  final _firestore = FirestoreService();
  List<QuestionModel> _questions = [];
  final Map<String, int> _answers = {};
  bool _loading = true;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final testDoc = await FirebaseFirestore.instance.collection('tests').doc(widget.testId).get();
    if (!testDoc.exists) {
      setState(() => _loading = false);
      return;
    }
    final test = TestModel.fromMap(testDoc.id, testDoc.data()!);
    final questions = <QuestionModel>[];
    for (final qId in test.questionIds) {
      final qDoc = await FirebaseFirestore.instance.collection('questions').doc(qId).get();
      if (qDoc.exists) {
        questions.add(QuestionModel.fromMap(qDoc.id, qDoc.data()!));
      }
    }
    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    int score = 0;
    for (final q in _questions) {
      if (_answers[q.id] == q.correctOptionIndex) score++;
    }
    if (auth.firebaseUser != null) {
      await _firestore.submitTestResult(
        studentUid: auth.firebaseUser!.uid,
        testId: widget.testId,
        score: score,
        totalMarks: _questions.length,
      );
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.testResult, arguments: {'score': score, 'total': _questions.length});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('This test has no questions yet.')),
      );
    }

    final q = _questions[_current];
    return Scaffold(
      appBar: AppBar(title: Text('Question ${_current + 1} of ${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ...List.generate(q.options.length, (i) {
              final selected = _answers[q.id] == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _answers[q.id] = i),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.secondary : Colors.white,
                      border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(q.options[i]),
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              children: [
                if (_current > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _current--),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_current > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_current < _questions.length - 1) {
                        setState(() => _current++);
                      } else {
                        _submit();
                      }
                    },
                    child: Text(_current < _questions.length - 1 ? 'Next' : 'Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
