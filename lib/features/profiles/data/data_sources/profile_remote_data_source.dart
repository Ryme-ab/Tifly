import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_parent.dart';

class ProfileRemoteDataSource {
  final SupabaseClient client;

  ProfileRemoteDataSource(this.client);

  Future<ProfileParent?> fetchProfile(String userId) async {
    final Map<String, dynamic>? res = await client
        .from('profiles')
        .select<Map<String, dynamic>>()
        .eq('id', userId)
        .maybeSingle(); // ✅ prevents crash if no row

    if (res == null) return null;

    return ProfileParent.fromMap(res);
  }

  Future<ProfileParent> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final Map<String, dynamic>? res = await client
        .from('profiles')
        .update(data)
        .eq('id', userId)
        .select<Map<String, dynamic>>()
        .maybeSingle();

    if (res == null) {
      throw Exception('Failed to update profile for id: $userId');
    }

    return ProfileParent.fromMap(res);
  }
}
