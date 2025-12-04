import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/logs/data/repositories/feeding_logs_repo.dart';
import 'package:tifli/features/logs/data/models/logs_model.dart';
import 'package:tifli/features/logs/presentation/cubit/feeding_logs_state.dart';

class FeedingLogCubit extends Cubit<FeedingLogState> {
  final FeedingLogRepository repo;
  String? currentChildId;

  FeedingLogCubit({required FeedingLogRepository repository}) : repo = repository, super(FeedingLogInitial());

  Future<void> loadLogs(String childId) async {
    currentChildId = childId;
    emit(FeedingLogLoading());
    try {
      final logs = await repo.getLogs(childId);
      emit(FeedingLogLoaded(logs));
    } catch (e) {
      emit(FeedingLogError(e.toString()));
    }
  }

  Future<void> addLog(FeedingLog log) async {
    try {
      await repo.addLog(log);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(FeedingLogError(e.toString()));
    }
  }

  Future<void> updateLog(String id, FeedingLog log) async {
    try {
      await repo.updateLog(id, log);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(FeedingLogError(e.toString()));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await repo.deleteLog(id);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(FeedingLogError(e.toString()));
    }
  }
}
