import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

/// Helper to get current user id from Supabase auth
String? getCurrentUserId() => supabase.auth.currentUser?.id;
