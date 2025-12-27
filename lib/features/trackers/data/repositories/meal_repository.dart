import 'package:tifli/core/config/supabase_client.dart';
import '../models/meal.dart';

class MealRepository {
  Future<List<Meal>> getMealLogs(String childId) async {
    try {
      final userId = SupabaseClientManager().client.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }
      final response = await SupabaseClientManager().client
          .from('meals')
          .select('*')
          .eq('child_id', childId)
          .eq('user_id', userId)
          .order('meal_time', ascending: false);
      final List<Meal> mealLogs = [];
      for (final item in response) {
        mealLogs.add(Meal.fromJson(item));
      }
      return mealLogs;
    } catch (e) {
      return [];
    }
  }

  Future<List<Meal>> filterMeals({
    required String childId,
    DateTime? date,
    String? time,
    String? category,
  }) async {
    try {
      final userId = SupabaseClientManager().client.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }
      final response = await SupabaseClientManager().client
          .from('meals')
          .select('*')
          .eq('child_id', childId)
          .eq('user_id', userId)
          .order('meal_time', ascending: false);
      final List<Meal> filteredMeals = [];
      for (final item in response) {
        final meal = Meal.fromJson(item);
        final matchesDate =
            date == null ||
            (meal.mealTime.year == date.year &&
                meal.mealTime.month == date.month &&
                meal.mealTime.day == date.day);
        final matchesTime =
            time == null ||
            meal.mealTime.toIso8601String().substring(11, 16) == time;
        final matchesCategory = category == null || meal.mealType == category;
        if (matchesDate && matchesTime && matchesCategory) {
          filteredMeals.add(meal);
        }
      }
      return filteredMeals;
    } catch (e) {
      return [];
    }
  }

  Future<Meal> addMeal(Meal meal) async {
    try {
      final insertData = meal.toInsertJson();

      final response = await SupabaseClientManager().client
          .from('meals')
          .insert(insertData)
          .select()
          .single();

      return Meal.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeal(String id) async {
    try {
      await SupabaseClientManager().client.from('meals').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, double>> getMealTypeStats(String childId) async {
    try {
      // Get user ID from auth
      final userId = SupabaseClientManager().client.auth.currentUser?.id;
      if (userId == null) {
        return {'Breast Milk': 0, 'Formula': 0, 'Solid Food': 0, 'Juice': 0};
      }

      final response = await SupabaseClientManager().client
          .from('meals')
          .select('meal_type')
          .eq('child_id', childId)
          .eq('user_id', userId)
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
      if (total == 0) {
        return {'Breast Milk': 0, 'Formula': 0, 'Solid Food': 0, 'Juice': 0};
      }

      return {
        'Breast Milk': (counts['Breast Milk']! / total) * 100,
        'Formula': (counts['Formula']! / total) * 100,
        'Solid Food': (counts['Solid Food']! / total) * 100,
        'Juice': (counts['Juice']! / total) * 100,
      };
    } catch (e) {
      return {'Breast Milk': 0, 'Formula': 0, 'Solid Food': 0, 'Juice': 0};
    }
  }

  Future<void> updateMeal(Meal meal) async {
    try {
      // Prepare data for update
      final updateData = meal.toInsertJson(); // Use same as addMeal

      // Execute update
      final userId = SupabaseClientManager().client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      await SupabaseClientManager().client
          .from('meals')
          .update(updateData)
          .eq('id', meal.id)
          .eq('child_id', meal.childId)
          .eq('user_id', userId);

    } catch (e) {
      rethrow;
    }
  }
}
