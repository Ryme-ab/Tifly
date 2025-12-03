import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static final SupabaseClientManager _instance =
      SupabaseClientManager._internal();

  factory SupabaseClientManager() => _instance;

  SupabaseClientManager._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://oxkarvwcfcssbebiqamc.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94a2FydndjZmNzc2JlYmlxYW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NzU5MjYsImV4cCI6MjA4MDE1MTkyNn0.kivBLMGBnaIIqQvFPj-xSMjqOwJgzktVYAW8PFzbBS0', // replace with your Supabase anon key
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}
