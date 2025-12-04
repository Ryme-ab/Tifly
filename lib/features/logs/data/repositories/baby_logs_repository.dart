import 'package:tifli/features/logs/data/data_sources/baby_logs_data_source.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';

class BabyLogsRepository {
  final BabyLogsDataSource dataSource;

  BabyLogsRepository({required this.dataSource});

  Future<List<BabyLog>> getAllLogs(String childId) => 
      dataSource.getAllLogs(childId);

  Future<List<BabyLog>> getLogsByType(String childId, LogType type) => 
      dataSource.getLogsByType(childId, type);
}
