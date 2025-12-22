import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class MealPlannerDatabaseHelper {
  static final MealPlannerDatabaseHelper _instance =
      MealPlannerDatabaseHelper._internal();
  factory MealPlannerDatabaseHelper() => _instance;

  static Database? _database;

  MealPlannerDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb) {
      // Desktop platforms (Windows/Linux) need FFI
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      // Android/iOS use default sqflite, no FFI needed
      
      final databasesPath = await databaseFactory.getDatabasesPath();
      final path = join(databasesPath, 'meal_planner.db');

      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    }

    // Web platform - SQLite not supported
    throw UnsupportedError(
      'SQLite database is not supported on web. '
      'Please run the app on mobile or desktop platform, or implement a web-compatible storage solution.'
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE planned_meals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        child_id TEXT NOT NULL,
        date TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT,
        is_done INTEGER DEFAULT 0,
        ingredients TEXT,
        recipe TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_planned_meals_user_id 
      ON planned_meals(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_planned_meals_child_id 
      ON planned_meals(child_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_planned_meals_date 
      ON planned_meals(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_planned_meals_user_child_date 
      ON planned_meals(user_id, child_id, date)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed in future
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Clear all data (useful for testing or logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('planned_meals');
  }
}
