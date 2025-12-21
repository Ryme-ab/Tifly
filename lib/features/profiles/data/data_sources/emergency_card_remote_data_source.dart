import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/profiles/data/models/emergency_card_model.dart';

abstract class EmergencyCardRemoteDataSource {
  Future<EmergencyCardModel?> getEmergencyCard(String childId);
  Future<void> upsertEmergencyCard(EmergencyCardModel card);
}

class EmergencyCardRemoteDataSourceImpl implements EmergencyCardRemoteDataSource {
  final SupabaseClient client;

  EmergencyCardRemoteDataSourceImpl({required this.client});

  @override
  Future<EmergencyCardModel?> getEmergencyCard(String childId) async {
    try {
      final response = await client
          .from('emergency_cards')
          .select()
          .eq('child_id', childId)
          .maybeSingle();

      if (response == null) return null;

      // Map Supabase response to model
      // Supabase has id, child_id, data (JSONB), updated_at
      final Map<String, dynamic> data = response['data'];
      data['id'] = response['id'];
      data['child_id'] = response['child_id'];
      data['updated_at'] = response['updated_at'];
      data['sync_status'] = 'synced';

      return EmergencyCardModel.fromJson(data);
    } catch (e) {
      // In a real app, log error or rethrow
      return null;
    }
  }

  @override
  Future<void> upsertEmergencyCard(EmergencyCardModel card) async {
    final data = card.toJson();
    final id = data.remove('id');
    final childId = data.remove('child_id');
    final updatedAt = data.remove('updated_at');
    data.remove('sync_status'); // Don't store sync status in Supabase

    await client.from('emergency_cards').upsert({
      'id': id,
      'child_id': childId,
      'data': data,
      'updated_at': updatedAt,
    });
  }
}
