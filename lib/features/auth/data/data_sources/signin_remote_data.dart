
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSource(this.supabase);

  // 🔹 SIGN UP USER (Auth + Profiles Insert)
  Future<User?> signUp(UserModel user) async {
    try {
      // Create user in Supabase auth
      final response = await supabase.auth.signUp(
        email: user.email,
        password: user.pwd,
      );

      final createdUser = response.user;

      if (createdUser == null) {
        throw Exception("Could not create user.");
      }

      // Insert into profiles table
      await supabase.from('profiles').insert({
        'id': createdUser.id,
        'full_name': user.fullName,
        'email': user.email,
        'phone': user.phone,
        'pwd': user.pwd, // (⚠ Ideally: hash on server side)
      });

      return createdUser;
    } catch (e) {
      throw Exception("Sign up failed: $e");
    }
  }

  // 🔹 SIGN IN USER
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // 🔹 SIGN OUT
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception("Logout failed: $e");
    }
  }

  // 🔹 GET CURRENT USER
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  
}
