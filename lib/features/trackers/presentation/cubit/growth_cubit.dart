import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';
import '../../data/repositories/growth_repository.dart';
import 'package:tifli/core/utils/user_context.dart';

class GrowthCubit extends Cubit<List<GrowthLog>> {
  final GrowthRepository repository;

  GrowthCubit(this.repository) : super([]);

  Future<void> loadGrowthLogs(String childId) async {
    final logs = await repository.getGrowthLogs(childId);
    emit(logs);
  }

  Future<void> addGrowthLog({
    required String childId,
    required DateTime date,
    required double height,
    required double weight,
    required double headCircumference,
    String? notes,
  }) async {
    try {
      // Get user ID from auth
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check for duplicate
      final isDuplicate = await repository.checkDuplicate(
        childId: childId,
        date: date,
        height: height,
        weight: weight,
        headCircumference: headCircumference,
      );

      if (isDuplicate) {
        throw Exception("This growth log already exists!");
      }

      // Generate a valid UUID for the growth log
      const uuid = Uuid();
      final logId = uuid.v4();

      // Create new growth log with valid UUID
      final growthLog = GrowthLog(
        id: logId,
        childId: childId,
        userId: userId,
        date: date,
        height: height,
        weight: weight,
        headCircumference: headCircumference,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await repository.addGrowth(growthLog);
      await loadGrowthLogs(childId);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _getUserId() async {
    // Import and use UserContext
    return UserContext.getCurrentUserId();
  }

  Future<void> deleteGrowth(String id, String childId) async {
    await repository.deleteGrowth(id);
    await loadGrowthLogs(childId);
  }

  Future<void> updateGrowthLog(GrowthLog updatedLog) async {
    try {
      // User must exist
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      // Ensure the log belongs to this user
      if (updatedLog.userId != userId) {
        throw Exception("You cannot edit a log that doesn't belong to you.");
      }

      await repository.updateGrowth(updatedLog);

      // Refresh logs
      await loadGrowthLogs(updatedLog.childId);
    } catch (e) {
      rethrow;
    }
  }
}