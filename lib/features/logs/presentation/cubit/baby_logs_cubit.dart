import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/logs/data/repositories/baby_logs_repository.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_state.dart';

class BabyLogsCubit extends Cubit<BabyLogsState> {
  final BabyLogsRepository repo;
  String? currentChildId;
  LogType? currentFilter;

  BabyLogsCubit({required BabyLogsRepository repository})
    : repo = repository,
      super(BabyLogsInitial());

  Future<void> loadAllLogs(String childId) async {
    currentChildId = childId;
    currentFilter = null;
    emit(BabyLogsLoading());
    try {
      final logs = await repo.getAllLogs(childId);
      emit(BabyLogsLoaded(logs));
    } catch (e) {
      emit(BabyLogsError(e.toString()));
    }
  }

  Future<void> loadLogsByType(String childId, LogType type) async {
    currentChildId = childId;
    currentFilter = type;
    emit(BabyLogsLoading());
    try {
      final logs = await repo.getLogsByType(childId, type);
      emit(BabyLogsLoaded(logs));
    } catch (e) {
      emit(BabyLogsError(e.toString()));
    }
  }

  Future<void> refresh() async {
    if (currentChildId != null) {
      if (currentFilter != null) {
        await loadLogsByType(currentChildId!, currentFilter!);
      } else {
        await loadAllLogs(currentChildId!);
      }
    }
  }
}
