import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parent_profile_model.dart';

class ParentProfileDataSource {
  final SupabaseClient client;

  ParentProfileDataSource({required this.client});

  /// Fetch parent profile by user ID
  Future<ParentProfileModel> fetchProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return ParentProfileModel.fromJson(response);
  }

  /// Update parent profile
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await client.from('profiles').update(updates).eq('id', userId);
  }
}
