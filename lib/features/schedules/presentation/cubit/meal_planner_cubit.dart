import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/planned_meal_model.dart';
import '../../data/repositories/meal_planner_repository.dart';
import '../../data/data_sources/meal_planner_data_source.dart';

// State Class
class MealPlannerState {
  final List<PlannedMeal> plannedMeals;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;

  MealPlannerState({
    this.plannedMeals = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  // Default selectedDate to today
  factory MealPlannerState.initial() {
    return MealPlannerState(selectedDate: DateTime.now());
  }

  MealPlannerState copyWith({
    List<PlannedMeal>? plannedMeals,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
  }) {
    return MealPlannerState(
      plannedMeals: plannedMeals ?? this.plannedMeals,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  // Get meals for a specific date
  List<PlannedMeal> getMealsForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return plannedMeals.where((meal) {
      final mealDate = DateTime(meal.date.year, meal.date.month, meal.date.day);
      return mealDate == normalizedDate;
    }).toList();
  }
}

// Cubit Class
class MealPlannerCubit extends Cubit<MealPlannerState> {
  final MealPlannerRepository _repository;

  MealPlannerCubit({MealPlannerRepository? repository})
    : _repository =
          repository ??
          MealPlannerRepository(
            dataSource: MealPlannerDataSource(),
          ),
      super(MealPlannerState.initial());

  // Load planned meals for a date range
  Future<void> loadPlannedMeals(
    String userId,
    String childId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final meals = await _repository.fetchPlannedMeals(
        userId,
        childId,
        startDate: startDate,
        endDate: endDate,
      );

      emit(state.copyWith(plannedMeals: meals, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load planned meals: ${e.toString()}',
        ),
      );
    }
  }

  // Load meals for a specific date
  Future<void> loadMealsForDate(
    String userId,
    String childId,
    DateTime date,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, selectedDate: date));

    try {
      final meals = await _repository.fetchPlannedMealsByDate(
        userId,
        childId,
        date,
      );

      emit(state.copyWith(plannedMeals: meals, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load meals for date: ${e.toString()}',
        ),
      );
    }
  }

  // Add a new planned meal
  Future<void> addPlannedMeal({
    required String userId,
    required String childId,
    required DateTime date,
    required String mealType,
    required String title,
    required String subtitle,
    String? ingredients,
    String? recipe,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final meal = PlannedMeal(
        id: '',
        userId: userId,
        childId: childId,
        date: date,
        mealType: mealType,
        title: title,
        subtitle: subtitle,
        isDone: false,
        ingredients: ingredients,
        recipe: recipe,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addPlannedMeal(meal);

      // Reload meals for the selected date
      await loadMealsForDate(userId, childId, state.selectedDate);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to add planned meal: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }

  // Update an existing planned meal
  Future<void> updatePlannedMeal({
    required String id,
    required String userId,
    required String childId,
    required DateTime date,
    required String mealType,
    required String title,
    required String subtitle,
    required bool isDone,
    String? ingredients,
    String? recipe,
    required DateTime createdAt,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final meal = PlannedMeal(
        id: id,
        userId: userId,
        childId: childId,
        date: date,
        mealType: mealType,
        title: title,
        subtitle: subtitle,
        isDone: isDone,
        ingredients: ingredients,
        recipe: recipe,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

      await _repository.updatePlannedMeal(meal, userId);

      // Reload meals
      await loadMealsForDate(userId, childId, state.selectedDate);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update planned meal: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }

  // Toggle meal done status
  Future<void> toggleMealDone(
    String id,
    String userId,
    String childId,
    bool currentStatus,
  ) async {
    try {
      final newStatus = !currentStatus;
      await _repository.toggleMealDone(id, userId, newStatus);

      // Update local state
      final updatedMeals = state.plannedMeals.map((meal) {
        if (meal.id == id) {
          return meal.copyWith(isDone: newStatus);
        }
        return meal;
      }).toList();

      emit(state.copyWith(plannedMeals: updatedMeals));
    } catch (e) {
      emit(
        state.copyWith(error: 'Failed to toggle meal status: ${e.toString()}'),
      );
    }
  }

  // Delete a planned meal
  Future<void> deletePlannedMeal(
    String id,
    String userId,
    String childId,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      await _repository.deletePlannedMeal(id, userId);

      // Reload meals
      await loadMealsForDate(userId, childId, state.selectedDate);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to delete planned meal: ${e.toString()}',
        ),
      );
    }
  }

  // Load meal statistics
  Future<void> loadMealStats(
    String userId,
    String childId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final stats = await _repository.getMealStats(
        userId,
        childId,
        startDate,
        endDate,
      );

      emit(state.copyWith(stats: stats));
    } catch (e) {
      print('Failed to load meal stats: $e');
    }
  }

  // Change selected date
  void changeSelectedDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  // Get meals for the currently selected date
  List<PlannedMeal> get mealsForSelectedDate {
    return state.getMealsForDate(state.selectedDate);
  }
}
