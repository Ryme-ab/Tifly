import 'package:bloc/bloc.dart';
import '../../data/models/sleep.dart';
import '../../data/repositories/sleep_repository.dart';
import 'package:tifli/core/config/supabaseClient.dart';
class SleepCubit extends Cubit<List<SleepLog>> {
  final SleepRepository repository;

  SleepCubit(this.repository) : super([]);

  Future<void> loadSleepLogs(String childId) async {
    final logs = await repository.getSleepLogs(childId);
    emit(logs);
  }

  Future<void> addSleepLog(SleepLog log, String childId) async {
    await repository.addSleep(log);
    await loadSleepLogs(childId);
  }

  Future<void> deleteSleep(String id, String childId) async {
    await repository.deleteSleep(id);
    await loadSleepLogs(childId);
  }
}
