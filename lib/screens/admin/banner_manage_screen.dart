import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/theme.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';

class BannerManageScreen extends StatefulWidget {
  const BannerManageScreen({super.key});

  @override
  State<BannerManageScreen> createState() => _BannerManageScreenState();
}

class _BannerManageScreenState extends State<BannerManageScreen> {
  final _storage = StorageService();
  bool _uploading = false;

  Future<void> _addBanner() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.path == null) return;
    setState(() => _uploading = true);
    final file = File(result.files.single.path!);
    final url = await _storage.uploadFile(
      file: file,
      folder: 'banners',
      fileName: '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}',
    );
    await FirebaseFirestore.instance.collection('banners').add({
      'imageUrl': url,
      'order': DateTime.now().millisecondsSinceEpoch,
    });
    if (mounted) setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homepage Banners')),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploading ? null : _addBanner,
        child: _uploading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.add_photo_alternate_outlined),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('banners').orderBy('order').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const EmptyState(icon: Icons.image_outlined, title: 'No banners uploaded yet', subtitle: 'Tap + to add a homepage banner.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 7,
                      child: Image.network(data['imageUrl'] ?? '', fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.secondary)),
                    ),
                    Positioned(
                      top: 6, right: 6,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(icon: const Icon(Icons.delete, color: Colors.white, size: 18), onPressed: () => docs[i].reference.delete()),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
