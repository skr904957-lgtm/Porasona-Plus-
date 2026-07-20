import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/theme.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';
import '../../models/course_model.dart';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _storage = StorageService();
  final _firestore = FirestoreService();
  double _progress = 0;
  bool _uploading = false;
  CourseModel? _selectedCourse;

  final List<_ContentType> _types = const [
    _ContentType('PDF', 'pdfIds', ['pdf'], Icons.picture_as_pdf_outlined),
    _ContentType('Video', 'videoIds', ['mp4', 'mov', 'mkv'], Icons.videocam_outlined),
    _ContentType('Notes', 'pdfIds', ['pdf', 'doc', 'docx'], Icons.notes_outlined),
    _ContentType('Suggestions', 'pdfIds', ['pdf', 'doc', 'docx'], Icons.lightbulb_outline),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
  }

  Future<void> _pickAndUpload(_ContentType type) async {
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a course first')));
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type.extensions,
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    try {
      final url = await _storage.uploadFile(
        file: file,
        folder: type.label.toLowerCase(),
        fileName: fileName,
        onProgress: (p) => setState(() => _progress = p),
      );

      await FirebaseFirestore.instance.collection('courses').doc(_selectedCourse!.id).update({
        type.firestoreField: FieldValue.arrayUnion([url]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${type.label} uploaded successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Content'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: _types.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<List<CourseModel>>(
              stream: _firestore.courses(),
              builder: (context, snapshot) {
                final courses = snapshot.data ?? [];
                return DropdownButtonFormField<CourseModel>(
                  decoration: const InputDecoration(labelText: 'Select Course', border: OutlineInputBorder()),
                  items: courses.map((c) => DropdownMenuItem(value: c, child: Text(c.title))).toList(),
                  onChanged: (c) => setState(() => _selectedCourse = c),
                );
              },
            ),
          ),
          if (_uploading) LinearProgressIndicator(value: _progress),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _types.map((type) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.icon, size: 56, color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text('Upload ${type.label} for the selected course', textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _uploading ? null : () => _pickAndUpload(type),
                          icon: const Icon(Icons.upload_file),
                          label: Text('Choose ${type.label} File'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentType {
  final String label;
  final String firestoreField;
  final List<String> extensions;
  final IconData icon;
  const _ContentType(this.label, this.firestoreField, this.extensions, this.icon);
}
