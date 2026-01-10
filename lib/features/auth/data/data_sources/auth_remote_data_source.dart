//sql beh nconicnty
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for authentication operations
/// This class handles direct communication with Supabase authentication APIs
class AuthRemoteDataSource {
  // SupabaseClient instance for making auth requests
  final SupabaseClient client;

  /// Constructor with dependency injection for testability
  /// In production, pass Supabase.instance.client
  /// In tests, pass a mock SupabaseClient
  AuthRemoteDataSource({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  /// Authenticates a user with email and password
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// 
  /// Returns: AuthResponse containing user data and session if successful
  /// Throws: AuthException if authentication fails
  Future<AuthResponse> login(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Registers a new user with email and password
  /// 
  /// Parameters:
  /// - [email]: New user's email address
  /// - [password]: New user's password
  /// 
  /// Returns: AuthResponse containing user data and session if successful
  /// Throws: AuthException if signup fails (e.g., user already exists)
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }
}
