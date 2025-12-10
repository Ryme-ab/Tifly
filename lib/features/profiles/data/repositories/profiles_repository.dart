import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profiles_model.dart';

class ProfilesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get the current logged-in user's ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Fetch the profile of the current user
  Future<UserProfileModel?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfileModel.fromJson(data);
    } catch (e) {
      // If profile doesn't exist, we might want to return a default or propagate error
      // dependent on how your table is set up.
      // For now, let's assume it should exist or return null.
      return null;
    }
  }

  /// Update the profile
  Future<void> updateProfile(UserProfileModel profile) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('No user logged in');

    await _client.from('profiles').upsert(profile.toJson());
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
