import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/empty_state.dart';

/// Downloaded items are tracked in a local Hive box named 'downloads'
/// (opened once in main.dart / a bootstrap step) so downloads persist
/// offline. This screen simply lists whatever the student has actually
/// downloaded — nothing here is pre-populated.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: FutureBuilder(
        future: Hive.isBoxOpen('downloads') ? Future.value(Hive.box('downloads')) : Hive.openBox('downloads'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final box = snapshot.data as Box;
          if (box.isEmpty) {
            return const EmptyState(
              icon: Icons.download_outlined,
              title: 'No downloads yet',
              subtitle: 'Download a video or PDF from a course to view it offline.',
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, i) {
              final item = box.getAt(i) as Map;
              return ListTile(
                leading: Icon(item['type'] == 'video' ? Icons.videocam_outlined : Icons.picture_as_pdf_outlined),
                title: Text(item['title'] ?? 'Downloaded item'),
                subtitle: Text(item['path'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
