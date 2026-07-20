import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/live_class_model.dart';
import '../../widgets/empty_state.dart';

class LiveClassManageScreen extends StatelessWidget {
  const LiveClassManageScreen({super.key});

  void _showForm(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final teacherCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '60');
    DateTime scheduledAt = DateTime.now().add(const Duration(hours: 1));

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
                const Text('Schedule Live Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Class Title')),
                const SizedBox(height: 10),
                TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
                const SizedBox(height: 10),
                TextField(controller: teacherCtrl, decoration: const InputDecoration(labelText: 'Teacher Name')),
                const SizedBox(height: 10),
                TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'Meeting URL (Zoom/Meet)')),
                const SizedBox(height: 10),
                TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (minutes)')),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Scheduled: ${DateFormat('MMM d, y • h:mm a').format(scheduledAt)}'),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx, initialDate: scheduledAt,
                      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null) return;
                    if (!ctx.mounted) return;
                    final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(scheduledAt));
                    if (time == null) return;
                    setState(() {
                      scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final liveClass = LiveClassModel(
                        id: const Uuid().v4(),
                        title: titleCtrl.text.trim(),
                        subject: subjectCtrl.text.trim(),
                        teacherName: teacherCtrl.text.trim(),
                        scheduledAt: scheduledAt,
                        meetingUrl: urlCtrl.text.trim(),
                        durationMinutes: int.tryParse(durationCtrl.text) ?? 60,
                      );
                      await FirestoreService().addLiveClass(liveClass);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Schedule Class'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Live Classes')),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(context), child: const Icon(Icons.add)),
      body: StreamBuilder<List<LiveClassModel>>(
        stream: firestore.liveClasses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final classes = snapshot.data!;
          if (classes.isEmpty) {
            return const EmptyState(icon: Icons.videocam_off_outlined, title: 'No live classes scheduled', subtitle: 'Tap + to schedule one.');
          }
          return ListView.separated(
            itemCount: classes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final lc = classes[i];
              return ListTile(
                leading: const Icon(Icons.videocam, color: AppColors.primary),
                title: Text(lc.title),
                subtitle: Text('${lc.subject} • ${DateFormat('MMM d, h:mm a').format(lc.scheduledAt)}'),
              );
            },
          );
        },
      ),
    );
  }
}
