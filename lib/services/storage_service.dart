import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Uploads and retrieves real files (PDFs, videos, notes, images) in Firebase Storage.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required File file,
    required String folder,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref().child('$folder/$fileName');
    final task = ref.putFile(file);

    if (onProgress != null) {
      task.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    final snapshot = await task;
    return snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(String downloadUrl) async {
    final ref = _storage.refFromURL(downloadUrl);
    await ref.delete();
  }
}
