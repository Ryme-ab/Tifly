import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static final SupabaseClientManager _instance =
      SupabaseClientManager._internal();

  factory SupabaseClientManager() => _instance;

  SupabaseClientManager._internal();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://oxkarvwcfcssbebiqamc.supabase.co',
      anonKey: 'YOUR_PUBLISHABLE_KEY_HERE', // Replace with your public key
    );
  }
}
