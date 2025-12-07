import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gallery_item.dart';

class GalleryRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<GalleryItem>> fetchGallery(String childId) async {
    try {
      final response = await supabase
          .from('gallery')
          .select()
          .eq('child_id', childId);

      return (response as List)
          .map((json) => GalleryItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching gallery: $e');
      return [];
    }
  }

  Future<String> uploadImage(File file) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      print('=== IMAGE UPLOAD START ===');
      print('File name: $fileName');
      print('File size: ${await file.length()} bytes');
      print('File path: ${file.path}');

      final fileBytes = await file.readAsBytes();
      final storage = supabase.storage.from('gallery_media');

      print('Uploading binary data to gallery_media bucket...');

      // Use uploadBinary with explicit content type
      final response = await storage.uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );

      print('Upload response: $response');
      print('Image uploaded successfully');

      final url = storage.getPublicUrl(fileName);
      print('Public URL: $url');
      print('=== IMAGE UPLOAD END ===');
      return url;
    } catch (e) {
      print('=== IMAGE UPLOAD ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<GalleryItem> insertMemory({
    required String childId,
    required String uploadedBy,
    required String title,
    required DateTime pictureDate,
    required File imageFile,
  }) async {
    try {
      if (childId.isEmpty) {
        throw Exception('Cannot add memory: childId is empty');
      }
      // If uploadedBy is empty, default to current authenticated user
      final String uploader = (uploadedBy.isEmpty)
          ? (supabase.auth.currentUser?.id ?? '')
          : uploadedBy;
      if (uploader.isEmpty) {
        throw Exception(
          'Cannot add memory: no authenticated user (uploadedBy empty)',
        );
      }
      print('Starting memory insertion for child: $childId');
      print('File exists: ${imageFile.existsSync()}');
      print('File path: ${imageFile.path}');

      final remoteUrl = await uploadImage(imageFile);
      print('Image uploaded to: $remoteUrl');

      final data = {
        'child_id': childId,
        'uploaded_by': uploader,
        'file_path': remoteUrl,
        'media_type': 'image',
        'title': title,
        'picture_date': pictureDate.toIso8601String(),
      };

      print('Inserting record to database with data: $data');

      // Test the insert without select first
      final insertResult = await supabase.from('gallery').insert(data);
      print('Insert result: $insertResult');

      // Now fetch the inserted record
      final response = await supabase
          .from('gallery')
          .select()
          .eq('file_path', remoteUrl)
          .single();

      print('Database insertion successful: ${response['id']}');
      return GalleryItem.fromJson(response);
    } catch (e) {
      print('Error inserting memory: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<GalleryItem> updateMemory({
    required String id,
    String? title,
    DateTime? pictureDate,
    File? newImageFile,
  }) async {
    try {
      String? newUrl;
      if (newImageFile != null) {
        newUrl = await uploadImage(newImageFile);
      }

      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (pictureDate != null) {
        data['picture_date'] = pictureDate.toIso8601String();
      }
      if (newUrl != null) {
        data['file_path'] = newUrl;
        data['media_type'] = 'image';
      }

      final response = await supabase
          .from('gallery')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return GalleryItem.fromJson(response);
    } catch (e) {
      print('Error updating memory: $e');
      rethrow;
    }
  }

  Future<void> deleteMemory(GalleryItem item) async {
    try {
      // Delete DB row first
      await supabase.from('gallery').delete().eq('id', item.id);

      // Attempt to delete the storage object (best-effort)
      try {
        final uri = Uri.parse(item.filePath);
        final segments = uri.pathSegments;
        // public URL format usually ends with filename
        final fileName = segments.isNotEmpty ? segments.last : null;
        if (fileName != null && fileName.isNotEmpty) {
          final storage = supabase.storage.from('gallery_media');
          await storage.remove([fileName]);
        }
      } catch (e) {
        // Ignore storage delete issues; row already removed
        print('Warning: failed to remove storage object: $e');
      }
    } catch (e) {
      print('Error deleting memory: $e');
      rethrow;
    }
  }
}
