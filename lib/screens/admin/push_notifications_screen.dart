import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/firestore_service.dart';

/// Sends an in-app notification to every student (written to each
/// students/{uid}/notifications subcollection) and, in production, should
/// also trigger a Firebase Cloud Function that reads students' fcmToken
/// fields and calls the FCM Admin SDK to deliver a real push notification.
/// This client only writes the Firestore side — actual push delivery must
/// happen server-side since the FCM server key can never live in the app.
class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  State<PushNotificationsScreen> createState() => _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await FirestoreService().broadcastNotification(title: _titleCtrl.text.trim(), body: _bodyCtrl.text.trim());
    if (mounted) {
      setState(() => _sending = false);
      _titleCtrl.clear();
      _bodyCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent to all students')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Broadcast to all students', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Writes to every student\'s notification inbox. Connect a Cloud Function to also deliver a device push via FCM.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 14),
            TextField(controller: _bodyCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Message')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Send Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
