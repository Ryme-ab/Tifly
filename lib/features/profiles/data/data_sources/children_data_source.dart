import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/child_model.dart';

class ChildrenDataSource {
  final SupabaseClient client;

  ChildrenDataSource({required SupabaseClient client}) : client = client;

  Future<List<ChildModel>> fetchChildren(String parentId) async {
    final response = await client
        .from('children')
        .select()
        .eq('parent_id', parentId);

    return (response as List<dynamic>)
        .map((child) => ChildModel.fromJson(child))
        .toList();
  }

  Future<void> deleteChild(String childId) async {
    await client.from('children').delete().eq('id', childId);
  }
}
