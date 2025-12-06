import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_parent.dart';

class ProfileRemoteDataSource {
  final SupabaseClient client;

  ProfileRemoteDataSource(this.client);

  Future<ProfileParent?> fetchProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return ProfileParent.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<ProfileParent> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from('profiles')
          .update(data)
          .eq('id', userId)
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('Failed to update profile for id: $userId');
      }

      return ProfileParent.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
