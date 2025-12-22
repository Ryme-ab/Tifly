import '../models/planned_meal_model.dart';
import 'meal_planner_local_database.dart';
import 'package:uuid/uuid.dart';

class MealPlannerDataSource {
  final MealPlannerDatabaseHelper _dbHelper;

  MealPlannerDataSource({MealPlannerDatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? MealPlannerDatabaseHelper();

  // Get all planned meals for a specific child and date range
  Future<List<PlannedMeal>> getPlannedMeals(
    String userId,
    String childId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🔍 Fetching planned meals for child: $childId');

      final db = await _dbHelper.database;
      
      String whereClause = 'user_id = ? AND child_id = ?';
      List<dynamic> whereArgs = [userId, childId];

      // Add date filters if provided
      if (startDate != null) {
        whereClause += ' AND date >= ?';
        whereArgs.add(startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        whereClause += ' AND date <= ?';
        whereArgs.add(endDate.toIso8601String().split('T')[0]);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'planned_meals',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date ASC, meal_type ASC',
      );

      print('✅ Found ${maps.length} planned meals');

      return maps.map((map) => PlannedMeal.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error fetching planned meals: $e');
      rethrow;
    }
  }

  // Get planned meals for a specific date
  Future<List<PlannedMeal>> getPlannedMealsByDate(
    String userId,
    String childId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      print('🔍 Fetching planned meals for date: $dateStr');

      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'planned_meals',
        where: 'user_id = ? AND child_id = ? AND date = ?',
        whereArgs: [userId, childId, dateStr],
        orderBy: 'meal_type ASC',
      );

      print('✅ Found ${maps.length} planned meals for $dateStr');

      return maps.map((map) => PlannedMeal.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error fetching planned meals by date: $e');
      rethrow;
    }
  }

  // Add a new planned meal
  Future<PlannedMeal> addPlannedMeal(PlannedMeal meal) async {
    try {
      print('➕ Adding planned meal: ${meal.title}');

      final db = await _dbHelper.database;
      
      // Generate a new ID
      final uuid = const Uuid();
      final id = uuid.v4();
      
      final mealWithId = meal.copyWith(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final insertData = {
        'id': mealWithId.id,
        'user_id': mealWithId.userId,
        'child_id': mealWithId.childId,
        'date': mealWithId.date.toIso8601String().split('T')[0],
        'meal_type': mealWithId.mealType,
        'title': mealWithId.title,
        'subtitle': mealWithId.subtitle,
        'is_done': mealWithId.isDone ? 1 : 0,
        'ingredients': mealWithId.ingredients,
        'recipe': mealWithId.recipe,
        'created_at': mealWithId.createdAt.toIso8601String(),
        'updated_at': mealWithId.updatedAt.toIso8601String(),
      };

      print('   Insert data: $insertData');

      await db.insert('planned_meals', insertData);

      print('✅ Planned meal added successfully! ID: $id');
      return mealWithId;
    } catch (e) {
      print('❌ Error adding planned meal: $e');
      rethrow;
    }
  }

  // Update an existing planned meal
  Future<void> updatePlannedMeal(PlannedMeal meal, String userId) async {
    try {
      print('✏️ Updating planned meal: ${meal.id}');

      final db = await _dbHelper.database;

      final updateData = {
        'user_id': meal.userId,
        'child_id': meal.childId,
        'date': meal.date.toIso8601String().split('T')[0],
        'meal_type': meal.mealType,
        'title': meal.title,
        'subtitle': meal.subtitle,
        'is_done': meal.isDone ? 1 : 0,
        'ingredients': meal.ingredients,
        'recipe': meal.recipe,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('   Update data: $updateData');

      await db.update(
        'planned_meals',
        updateData,
        where: 'id = ? AND user_id = ?',
        whereArgs: [meal.id, userId],
      );

      print('✅ Planned meal updated successfully!');
    } catch (e) {
      print('❌ Error updating planned meal: $e');
      rethrow;
    }
  }

  // Mark meal as done/undone
  Future<void> toggleMealDone(String id, String userId, bool isDone) async {
    try {
      print('✓ Toggling meal done status: $id -> $isDone');

      final db = await _dbHelper.database;

      await db.update(
        'planned_meals',
        {
          'is_done': isDone ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );

      print('✅ Meal done status updated!');
    } catch (e) {
      print('❌ Error toggling meal done: $e');
      rethrow;
    }
  }

  // Delete a planned meal
  Future<void> deletePlannedMeal(String id, String userId) async {
    try {
      print('🗑️ Deleting planned meal: $id');

      final db = await _dbHelper.database;

      await db.delete(
        'planned_meals',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );

      print('✅ Planned meal deleted successfully!');
    } catch (e) {
      print('❌ Error deleting planned meal: $e');
      rethrow;
    }
  }

  // Get meal statistics (e.g., completion rate)
  Future<Map<String, dynamic>> getMealStats(
    String userId,
    String childId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'planned_meals',
        columns: ['is_done'],
        where: 'user_id = ? AND child_id = ? AND date >= ? AND date <= ?',
        whereArgs: [userId, childId, startDateStr, endDateStr],
      );

      final total = maps.length;
      final completed = maps.where((m) => m['is_done'] == 1).length;
      final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

      return {
        'total': total,
        'completed': completed,
        'pending': total - completed,
        'completionRate': completionRate,
      };
    } catch (e) {
      print('❌ Error getting meal stats: $e');
      return {'total': 0, 'completed': 0, 'pending': 0, 'completionRate': 0.0};
    }
  }
}
