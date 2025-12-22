import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:tifli/core/utils/database_helper.dart';
import 'package:tifli/features/profiles/data/models/emergency_card_model.dart';

abstract class EmergencyCardLocalDataSource {
  Future<EmergencyCardModel?> getEmergencyCard(String childId);
  Future<void> saveEmergencyCard(EmergencyCardModel card);
  Future<List<EmergencyCardModel>> getPendingSyncCards();
  Future<void> updateSyncStatus(String id, String status);
}

class EmergencyCardLocalDataSourceImpl implements EmergencyCardLocalDataSource {
  final DatabaseHelper dbHelper;

  EmergencyCardLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<EmergencyCardModel?> getEmergencyCard(String childId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'emergency_cards_local',
      where: 'child_id = ?',
      whereArgs: [childId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final Map<String, dynamic> data = jsonDecode(map['data_json']);
    
    // Merge database fields into the JSON for model creation
    data['id'] = map['id'];
    data['child_id'] = map['child_id'];
    data['updated_at'] = DateTime.fromMillisecondsSinceEpoch(map['updated_at']).toIso8601String();
    data['sync_status'] = map['sync_status'];

    return EmergencyCardModel.fromJson(data);
  }

  @override
  Future<void> saveEmergencyCard(EmergencyCardModel card) async {
    final db = await dbHelper.database;
    final data = card.toJson();
    
    // Extract metadata fields for the database table
    final id = data.remove('id');
    final childId = data.remove('child_id');
    final updatedAt = DateTime.parse(data.remove('updated_at')).millisecondsSinceEpoch;
    final syncStatus = data.remove('sync_status');

    await db.insert(
      'emergency_cards_local',
      {
        'id': id,
        'child_id': childId,
        'data_json': jsonEncode(data),
        'updated_at': updatedAt,
        'sync_status': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<EmergencyCardModel>> getPendingSyncCards() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'emergency_cards_local',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );

    return maps.map((map) {
      final Map<String, dynamic> data = jsonDecode(map['data_json']);
      data['id'] = map['id'];
      data['child_id'] = map['child_id'];
      data['updated_at'] = DateTime.fromMillisecondsSinceEpoch(map['updated_at']).toIso8601String();
      data['sync_status'] = map['sync_status'];
      return EmergencyCardModel.fromJson(data);
    }).toList();
  }

  @override
  Future<void> updateSyncStatus(String id, String status) async {
    final db = await dbHelper.database;
    await db.update(
      'emergency_cards_local',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
