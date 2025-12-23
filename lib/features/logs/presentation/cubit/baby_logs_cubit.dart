import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/logs/data/repositories/baby_logs_repository.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_state.dart';

class BabyLogsCubit extends Cubit<BabyLogsState> {
  final BabyLogsRepository repo;
  String? currentChildId;
  LogType? currentFilter;
  DateTime? currentDate;
  String? currentTime; // format "HH:mm"

  // ✅ Option 1: named parameter 'repository'
  BabyLogsCubit({required BabyLogsRepository repository})
      : repo = repository,
        super(BabyLogsInitial());

  // Load all logs for a child
  Future<void> loadAllLogs(String childId) async {
    currentChildId = childId;
    currentFilter = null;
    currentDate = null;
    currentTime = null;
    emit(BabyLogsLoading());
    try {
      final logs = await repo.getAllLogs(childId);
      emit(BabyLogsLoaded(logs));
    } catch (e) {
      emit(BabyLogsError(e.toString()));
    }
  }

  // Load logs by type only
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

  // Apply filter by type, date, and/or time
  Future<void> applyFilter({
    LogType? type,
    DateTime? date,
    String? time,
  }) async {
    if (currentChildId == null) return;
    currentFilter = type;
    currentDate = date;
    currentTime = time;

    emit(BabyLogsLoading());
    try {
      final logs = await repo.dataSource.getFilteredLogs(
        childId: currentChildId!,
        type: type,
        date: date,
        time: time,
      );
      emit(BabyLogsLoaded(logs));
    } catch (e) {
      emit(BabyLogsError(e.toString()));
    }
  }

  // Refresh logs with current filters
  Future<void> refresh() async {
    if (currentChildId != null) {
      await applyFilter(
        type: currentFilter,
        date: currentDate,
        time: currentTime,
      );
    }
  }
}
