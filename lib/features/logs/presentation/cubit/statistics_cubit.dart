import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/logs/data/repositories/statistics_repository.dart';
import 'package:tifli/features/logs/presentation/cubit/statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository repo;
  String? currentChildId;

  StatisticsCubit({required StatisticsRepository repository})
    : repo = repository,
      super(StatisticsInitial());

  Future<void> loadStatistics(String childId) async {
    currentChildId = childId;
    emit(StatisticsLoading());
    try {
      final statistics = await repo.getStatistics(childId);
      emit(StatisticsLoaded(statistics));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  Future<void> refresh() async {
    if (currentChildId != null) {
      await loadStatistics(currentChildId!);
    }
  }
}
