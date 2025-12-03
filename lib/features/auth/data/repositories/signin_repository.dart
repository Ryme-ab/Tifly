import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient client;

  AuthRepository(this.client);

  /// Sign up user using Supabase Auth + profiles table
  Future<User?> signUp(UserModel user) async {
    final response = await client.auth.signUp(
      email: user.email,
      password: user.pwd,
    );

    if (response.user != null) {
      // Insert additional info into profiles table
      await client.from('profiles').insert({
        'id': response.user!.id,
        'full_name': user.fullName,
        'phone': user.phone,
        'email': user.email,
        'pwd': user.pwd,
        'role': user.role,
      });
    }

    return response.user;
  }

  /// Optional: Login
  Future<User?> signIn(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }
}
