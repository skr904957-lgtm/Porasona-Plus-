import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';

class TestResultScreen extends StatelessWidget {
  final int score;
  final int total;
  const TestResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((score / total) * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(percent >= 50 ? Icons.emoji_events : Icons.sentiment_neutral,
                size: 72, color: percent >= 50 ? Colors.amber.shade700 : Colors.grey),
            const SizedBox(height: 16),
            Text('$score / $total', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 6),
            Text('$percent% Score', style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home)),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
