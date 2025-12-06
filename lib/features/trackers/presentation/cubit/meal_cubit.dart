import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/meal.dart';
import '../../data/repositories/meal_repository.dart';
import 'package:tifli/core/utils/user_context.dart';

// State Class
class MealState {
  final List<Meal> mealLogs;
  final Map<String, double> mealTypeStats;
  final bool isLoading;
  final String? error;

  const MealState({
    this.mealLogs = const [],
    this.mealTypeStats = const {},
    this.isLoading = false,
    this.error,
  });

  MealState copyWith({
    List<Meal>? mealLogs,
    Map<String, double>? mealTypeStats,
    bool? isLoading,
    String? error,
  }) {
    return MealState(
      mealLogs: mealLogs ?? this.mealLogs,
      mealTypeStats: mealTypeStats ?? this.mealTypeStats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MealCubit extends Cubit<MealState> {
  final MealRepository _repository;

  MealCubit() : _repository = MealRepository(), super(const MealState());

  Future<void> loadMealLogs(String childId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final logs = await _repository.getMealLogs(childId);
      final stats = await _repository.getMealTypeStats(childId);
      emit(
        state.copyWith(mealLogs: logs, mealTypeStats: stats, isLoading: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load meal logs: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> addMeal({
    required String childId,
    required DateTime mealTime,
    required String mealType,
    required String items,
    required int amount,
    String status = 'completed',
  }) async {
    try {
      // Get user ID from context
      final userId = UserContext.getCurrentUserId();
      if (userId == null) {
        emit(state.copyWith(error: 'User not authenticated'));
        throw Exception('User not authenticated');
      }

      final meal = Meal(
        id: '',
        childId: childId,
        userId: userId,
        mealTime: mealTime,
        mealType: mealType,
        items: items,
        amount: amount,
        status: status,
        createdAt: DateTime.now(),
      );

      await _repository.addMeal(meal);
      await loadMealLogs(childId); // Reload to show new data
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add meal: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> deleteMeal(String id, String childId) async {
    try {
      await _repository.deleteMeal(id);
      await loadMealLogs(childId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete meal: ${e.toString()}'));
    }
  }

  double getTodayTotal() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return state.mealLogs
        .where((meal) => meal.mealTime.isAfter(todayStart))
        .fold(0.0, (sum, meal) => sum + meal.amount);
  }

  double getWeeklyTotal() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));

    return state.mealLogs
        .where((meal) => meal.mealTime.isAfter(weekStart))
        .fold(0.0, (sum, meal) => sum + meal.amount);
  }

  Future<void> updateMeal({
    required String id,
    required String childId,
    required DateTime mealTime,
    required String mealType,
    required String items,
    required int amount,
    String status = 'completed',
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Get user ID
      final userId = UserContext.getCurrentUserId();
      if (userId == null) {
        emit(state.copyWith(isLoading: false, error: 'User not authenticated'));
        return;
      }

      // Construct updated Meal object
      final updatedMeal = Meal(
        id: id,
        childId: childId,
        userId: userId,
        mealTime: mealTime,
        mealType: mealType,
        items: items,
        amount: amount,
        status: status,
        createdAt:
            DateTime.now(), // optional: keep original createdAt if needed
      );

      // Call repository
      await _repository.updateMeal(updatedMeal);

      // Reload meals
      await loadMealLogs(childId);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update meal: ${e.toString()}',
        ),
      );
    }
  }
}
