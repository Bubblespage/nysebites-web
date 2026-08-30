import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Uploads image bytes to Firebase Storage and returns a download URL,
/// so Firestore docs store a short URL string instead of a raw base64
/// blob (which was blowing past Firestore's 1 MiB document limit).
class StorageUploader {
  static Future<String?> uploadBytes({
    required Uint8List? bytes,
    required String path,
  }) async {
    if (bytes == null || bytes.isEmpty) return null;

    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }
}