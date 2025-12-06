import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/child_model.dart';

class ChildrenDataSource {
  final SupabaseClient client;

  ChildrenDataSource({required SupabaseClient client}) : client = client;

  Future<List<ChildModel>> fetchChildren(String parentId) async {
    final response = await client
        .from('children')
        .select()
        .eq('parent_id', parentId);

    return (response as List<dynamic>)
        .map((child) => ChildModel.fromJson(child))
        .toList();
  }

  Future<void> deleteChild(String childId) async {
    await client.from('children').delete().eq('id', childId);
  }

  Future<void> updateChild({
    required String childId,
    required String firstName,
    required DateTime birthDate,
    String? gender,
    String? notes,
    dynamic imageFile,
  }) async {
    String? imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      try {
        final fileName =
            'child_${childId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await imageFile.readAsBytes();

        await client.storage
            .from('profiles')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        imageUrl = client.storage.from('profiles').getPublicUrl(fileName);
      } catch (e) {
        // Continue without image if upload fails
        print('Image upload failed: $e');
      }
    }

    // Update child data
    final updateData = {
      'first_name': firstName,
      'birth_date': birthDate.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (notes != null) 'notes': notes,
      if (imageUrl != null) 'profile_image': imageUrl,
    };

    await client.from('children').update(updateData).eq('id', childId);
  }
}
