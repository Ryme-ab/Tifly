import 'package:bloc/bloc.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';
import '../../data/repositories/sleep_repository.dart';
import 'package:tifli/core/utils/user_context.dart';

class SleepCubit extends Cubit<List<SleepLog>> {
  final SleepRepository repository;

  SleepCubit(this.repository) : super([]);

  Future<void> loadSleepLogs(String childId) async {
    final logs = await repository.getSleepLogs(childId);
    emit(logs);
  }

  Future<void> addSleepLog({
    required String childId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
    required SleepLog sleepLog,
  }) async {
    try {
      // 🔐 Get logged-in user ID
      final userId = UserContext.getCurrentUserId();
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      // ❗ Check duplicate
      final isDuplicate = await repository.checkDuplicate(
        childId: childId,
        startTime: startTime,
        endTime: endTime,
      );

      if (isDuplicate) {
        throw Exception("This sleep log already exists!");
      }

      /* 
       // The passed 'sleepLog' parameter might have some data, but we are constructing a new one here based on arguments.
       // However, we should respect the 'quality' if it was passed in the sleepLog parameter, 
       // or we might need to rely on the 'notes' passed as argument.
       // The errors indicated 'notes' usage was wrong for SleepLog constructor (it expects 'description').
      */

      // 🆕 Create new sleep log object to add
      final logToAdd = SleepLog(
        id: '', // Supabase will generate ID
        childId: childId,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        quality: sleepLog.quality, // Use quality from the passed dummy object
        description: notes ?? '', // Map notes -> description
        createdAt: DateTime.now(),
      );

      await repository.addSleep(logToAdd);

      await loadSleepLogs(childId);
    } catch (e) {
      print("Error adding sleep log: $e");
      rethrow;
    }
  }

  Future<void> updateSleepLog(SleepLog log) async {
    try {
      await repository.updateSleep(log);
      await loadSleepLogs(log.childId);
    } catch (e) {
      print("Error updating sleep log: $e");
      rethrow;
    }
  }

  Future<void> deleteSleep(String id, String childId) async {
    await repository.deleteSleep(id);
    await loadSleepLogs(childId);
  }
}
