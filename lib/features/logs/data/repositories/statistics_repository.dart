import 'package:tifli/features/logs/data/data_sources/statistics_data_source.dart';
import 'package:tifli/features/logs/data/models/statistics_model.dart';

class StatisticsRepository {
  final StatisticsDataSource dataSource;

  StatisticsRepository({required this.dataSource});

  Future<Statistics> getStatistics(String childId) =>
      dataSource.getStatistics(childId);
}
