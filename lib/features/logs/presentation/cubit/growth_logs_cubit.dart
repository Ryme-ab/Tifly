import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/logs/data/repositories/growth_logs_repository.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_state.dart';

class GrowthLogCubit extends Cubit<GrowthLogState> {
  final GrowthLogRepository repo;
  String? currentChildId;

  GrowthLogCubit({required GrowthLogRepository repository})
    : repo = repository,
      super(GrowthLogInitial());

  Future<void> loadLogs(String childId) async {
    currentChildId = childId;
    emit(GrowthLogLoading());
    try {
      final logs = await repo.getLogs(childId);
      emit(GrowthLogLoaded(logs));
    } catch (e) {
      emit(GrowthLogError(e.toString()));
    }
  }

  Future<void> addLog(GrowthLog log) async {
    try {
      await repo.addLog(log);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(GrowthLogError(e.toString()));
    }
  }

  Future<void> updateLog(String id, GrowthLog log) async {
    try {
      await repo.updateLog(id, log);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(GrowthLogError(e.toString()));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await repo.deleteLog(id);
      if (currentChildId != null) {
        await loadLogs(currentChildId!);
      }
    } catch (e) {
      emit(GrowthLogError(e.toString()));
    }
  }
}
