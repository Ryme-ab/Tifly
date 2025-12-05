import 'package:bloc/bloc.dart';
import '../../data/models/sleep.dart';
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
    String? notes, required SleepLog sleepLog,
  }) async {
    try {
      // 🔐 Get logged-in user ID
      final userId = await UserContext.getCurrentUserId();
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

      // 🆕 Create new sleep log
      final sleepLog = SleepLog(
        id: '',
        childId: childId,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );

      await repository.addSleep(sleepLog);

      await loadSleepLogs(childId);
    } catch (e) {
      print("Error adding sleep log: $e");
      rethrow;
    }
  }

  Future<void> deleteSleep(String id, String childId) async {
    await repository.deleteSleep(id);
    await loadSleepLogs(childId);
  }
}
