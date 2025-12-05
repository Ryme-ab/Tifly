import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedules_model.dart';

class ChecklistDataSource {
  final SupabaseClient client;

  ChecklistDataSource({required this.client});

  Future<List<ChecklistItem>> getChecklists(String userId, String childId) async {
    final data = await client
        .from('checklist')
        .select()
        .eq('user_id', userId)
        .eq('child_id', childId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => ChecklistItem.fromJson(e)).toList();
  }

  Future<ChecklistItem> addItem(ChecklistItem item) async {
    final response = await client
        .from('checklist')
        .insert(item.toJson())
        .select()
        .single();
    
    return ChecklistItem.fromJson(response);
  }

  Future<void> updateItem(ChecklistItem item, String userId) async {
    await client
        .from('checklist')
        .update(item.toJson())
        .eq('id', item.id)
        .eq('user_id', userId);
  }

  Future<void> deleteItem(String id, String userId) async {
    await client.from('checklist').delete().eq('id', id).eq('user_id', userId);
  }
}
