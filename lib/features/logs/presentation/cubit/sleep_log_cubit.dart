import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/logs/data/repositories/sleep_log_repository.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_state.dart';

class SleepLogCubit extends Cubit<SleepLogState> {
  final SleepLogRepository repo;
  String? currentChildId;

  SleepLogCubit({required SleepLogRepository repository}) 
      : repo = repository, 
        super(SleepLogInitial());

  Future<void> loadLogs(String childId) async {
    currentChildId = childId;
    emit(SleepLogLoading());
    try {
      final logs = await repo.getLogs(childId);
      emit(SleepLogLoaded(logs));
    } catch (e) {
      emit(SleepLogError(e.toString()));
    }
  }

  Future<void> addLog(SleepLog log) async {
    try {
      await repo.addLog(log);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(SleepLogError(e.toString()));
    }
  }

  Future<void> updateLog(String id, SleepLog log) async {
    try {
      await repo.updateLog(id, log);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(SleepLogError(e.toString()));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await repo.deleteLog(id);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(SleepLogError(e.toString()));
    }
  }
}
