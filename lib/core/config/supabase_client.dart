import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/core/config/api_config.dart';

class SupabaseClientManager {
  static final SupabaseClientManager _instance =
      SupabaseClientManager._internal();

  factory SupabaseClientManager() => _instance;

  SupabaseClientManager._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConfig.supabaseUrl,
      anonKey: ApiConfig.supabaseAnonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}
