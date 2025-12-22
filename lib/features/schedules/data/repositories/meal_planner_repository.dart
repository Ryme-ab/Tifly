import '../data_sources/meal_planner_data_source.dart';
import '../models/planned_meal_model.dart';

class MealPlannerRepository {
  final MealPlannerDataSource dataSource;

  MealPlannerRepository({required this.dataSource});

  // Get all planned meals
  Future<List<PlannedMeal>> fetchPlannedMeals(
    String userId,
    String childId, {
    DateTime? startDate,
    DateTime? endDate,
  }) => dataSource.getPlannedMeals(
    userId,
    childId,
    startDate: startDate,
    endDate: endDate,
  );

  // Get planned meals by specific date
  Future<List<PlannedMeal>> fetchPlannedMealsByDate(
    String userId,
    String childId,
    DateTime date,
  ) => dataSource.getPlannedMealsByDate(userId, childId, date);

  // Add a new planned meal
  Future<PlannedMeal> addPlannedMeal(PlannedMeal meal) =>
      dataSource.addPlannedMeal(meal);

  // Update an existing planned meal
  Future<void> updatePlannedMeal(PlannedMeal meal, String userId) =>
      dataSource.updatePlannedMeal(meal, userId);

  // Toggle meal done status
  Future<void> toggleMealDone(String id, String userId, bool isDone) =>
      dataSource.toggleMealDone(id, userId, isDone);

  // Delete a planned meal
  Future<void> deletePlannedMeal(String id, String userId) =>
      dataSource.deletePlannedMeal(id, userId);

  // Get meal statistics
  Future<Map<String, dynamic>> getMealStats(
    String userId,
    String childId,
    DateTime startDate,
    DateTime endDate,
  ) => dataSource.getMealStats(userId, childId, startDate, endDate);
}
