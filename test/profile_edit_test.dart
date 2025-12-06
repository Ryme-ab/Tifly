import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';

void main() {
  test(
    'update profile by id (direct supabase client)',
    () async {
      // Use a plain Dart Supabase client to avoid Flutter plugin issues in test environment
      final url = 'https://oxkarvwcfcssbebiqamc.supabase.co';
      final anonKey =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94a2FydndjZmNzc2JlYmlxYW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NzU5MjYsImV4cCI6MjA4MDE1MTkyNn0.kivBLMGBnaIIqQvFPj-xSMjqOwJgzktVYAW8PFzbBS0';

      final client = SupabaseClient(url, anonKey);

      final id = '8c608294-5431-41b0-9ddc-d9cedaf5d109';
      final updateData = {
        'full_name': 'Automated Test Name',
        'phone': '+10000000000',
      };

      final res = await client
          .from('profiles')
          .update(updateData)
          .eq('id', id)
          .select()
          .maybeSingle();
      print('Update response: $res');

      expect(
        res,
        isNotNull,
        reason: 'Update returned null — check table or permissions',
      );
      expect((res as Map<String, dynamic>)['id'], equals(id));
      expect(res['full_name'], equals('Automated Test Name'));
      expect(res['phone'], equals('+10000000000'));
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
