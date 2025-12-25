import 'dart:collection';
import 'package:tifli/features/profiles/data/models/emergency_card_model.dart';

import 'emergency_card_local_data_source.dart';

class EmergencyCardLocalInMemoryDataSource implements EmergencyCardLocalDataSource {
  final Map<String, EmergencyCardModel> _store = HashMap();

  @override
  Future<EmergencyCardModel?> getEmergencyCard(String childId) async {
    for (final c in _store.values) {
      if (c.childId == childId) return c;
    }
    return null;
  }

  @override
  Future<List<EmergencyCardModel>> getPendingSyncCards() async {
    return _store.values.where((c) => c.syncStatus == 'pending').toList();
  }

  @override
  Future<void> saveEmergencyCard(EmergencyCardModel card) async {
    _store[card.id] = card;
  }

  @override
  Future<void> updateSyncStatus(String id, String status) async {
    final card = _store[id];
    if (card != null) {
      final updated = EmergencyCardModel.fromJson({...card.toJson(), 'sync_status': status});
      _store[id] = updated;
    }
  }
}
