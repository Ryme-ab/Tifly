import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/baby_model.dart';
import 'dart:io'; // <-- Add this at the top

class BabyRemoteDataSource {
  final SupabaseClient client;

  BabyRemoteDataSource(this.client);

  Future<Baby> addBaby(Baby baby) async {
    final response = await client
        .from('children')
        .insert(baby.toMap())
        .select()
        .single();
    return Baby.fromMap(response);
  }

  /// Upload image using BYTES only (works on web, mobile, desktop)
  Future<void> uploadProfileImageBytes(
    String babyId,
    List<int> bytes,
    String bucket,
  ) async {
    final fileName = "baby_${DateTime.now().millisecondsSinceEpoch}.jpg";

    // Convert to Uint8List
    final data = Uint8List.fromList(bytes);

    // Upload using uploadBinary (correct for supabase_flutter 1.x)
    await client.storage.from(bucket).uploadBinary(fileName, data);

    // Get public URL
    final publicUrl = client.storage.from(bucket).getPublicUrl(fileName);

    // Update baby record
    await client
        .from('children')
        .update({'profile_image': publicUrl})
        .eq('id', babyId);
  }

  /// THIS METHOD IS NOW SAFE:
  /// It converts a filePath → bytes and internally calls uploadProfileImageBytes
  Future<void> uploadProfileImage(
    String babyId,
    String filePath,
    String bucket,
  ) async {
    final fileBytes = await File(filePath).readAsBytes();
    return uploadProfileImageBytes(babyId, fileBytes, bucket);
  }

  Future<List<Baby>> fetchBabies() async {
    final response = await client.from('children').select();
    return (response as List).map((e) => Baby.fromMap(e)).toList();
  }
}
