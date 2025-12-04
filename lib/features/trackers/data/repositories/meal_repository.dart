import 'package:tifli/core/config/supabaseClient.dart';
import '../models/meal.dart';

class MealRepository {
  Future<List<Meal>> getMealLogs(String childId) async {
    try {
      print('🔍 Fetching meals for child: $childId');

      final response = await SupabaseClientManager().client
          .from('meals')
          .select('*')
          .eq('child_id', childId)
          .order('meal_time', ascending: false);

      print('✅ Found ${response.length} meals in database');

      final List<Meal> mealLogs = [];
      for (final item in response) {
        mealLogs.add(Meal.fromJson(item));
      }
      return mealLogs;
    } catch (e) {
      print('❌ Error fetching meal logs: $e');
      return [];
    }
  }

  Future<Meal> addMeal(Meal meal) async {
    try {
      print('➕ Adding meal to database...');
      print('   Child ID: ${meal.childId}');
      print('   Meal Type: ${meal.mealType}');
      print('   Amount: ${meal.amount}ml');
      print('   Time: ${meal.mealTime}');

      final insertData = meal.toInsertJson();
      print('   Insert data: $insertData');

      final response = await SupabaseClientManager().client
          .from('meals')
          .insert(insertData)
          .select()
          .single();

      print('✅ Meal added successfully! ID: ${response['id']}');
      return Meal.fromJson(response);
    } catch (e) {
      print('❌ Error adding meal: $e');
      rethrow;
    }
  }

  Future<void> deleteMeal(String id) async {
    try {
      await SupabaseClientManager().client.from('meals').delete().eq('id', id);
      print('🗑️ Meal deleted: $id');
    } catch (e) {
      print('❌ Error deleting meal: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> getMealTypeStats(String childId) async {
    try {
      final response = await SupabaseClientManager().client
          .from('meals')
          .select('meal_type')
          .eq('child_id', childId)
          .not('meal_type', 'is', null);

      final Map<String, int> counts = {
        'Breast Milk': 0,
        'Formula': 0,
        'Solid Food': 0,
        'Juice': 0,
      };

      for (final item in response) {
        final type = (item['meal_type'] as String).toLowerCase();
        if (type.contains('breast')) {
          counts['Breast Milk'] = counts['Breast Milk']! + 1;
        } else if (type.contains('formula')) {
          counts['Formula'] = counts['Formula']! + 1;
        } else if (type.contains('solid')) {
          counts['Solid Food'] = counts['Solid Food']! + 1;
        } else if (type.contains('juice')) {
          counts['Juice'] = counts['Juice']! + 1;
        }
      }

      final total = response.length;
      if (total == 0)
        return {'Breast Milk': 0, 'Formula': 0, 'Solid Food': 0, 'Juice': 0};

      return {
        'Breast Milk': (counts['Breast Milk']! / total) * 100,
        'Formula': (counts['Formula']! / total) * 100,
        'Solid Food': (counts['Solid Food']! / total) * 100,
        'Juice': (counts['Juice']! / total) * 100,
      };
    } catch (e) {
      print('❌ Error getting meal stats: $e');
      return {'Breast Milk': 0, 'Formula': 0, 'Solid Food': 0, 'Juice': 0};
    }
  }
}
