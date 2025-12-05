import 'package:supabase_flutter/supabase_flutter.dart';

/// Global utility class for accessing user context from Supabase Auth
class UserContext {
  /// Get the current authenticated user's ID
  /// Returns null if no user is authenticated
  static String? getCurrentUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  /// Check if a user is currently authenticated
  static bool isAuthenticated() {
    return Supabase.instance.client.auth.currentUser != null;
  }

  /// Get the current user's email
  static String? getCurrentUserEmail() {
    return Supabase.instance.client.auth.currentUser?.email;
  }

  /// Validate that a user is authenticated, throw error if not
  static String validateAuthenticated() {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('No user is currently authenticated');
    }
    return userId;
  }
}
