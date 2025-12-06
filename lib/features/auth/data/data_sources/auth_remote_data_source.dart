//sql beh nconicnty
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient client = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(
    String email,
    String password, {
    String? fullName,
    String? phone,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
      },
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
