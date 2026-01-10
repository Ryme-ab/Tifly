import 'package:tifli/features/schedules/data/data_sources/medicine_schedule_data_source.dart';
import 'package:tifli/features/schedules/data/models/medicine_model.dart';

class MedicineScheduleRepository {
  final MedicineScheduleDataSource dataSource;

  MedicineScheduleRepository({required this.dataSource});

  Future<List<MedicineSchedule>> getSchedules(String babyId) async {
    return await dataSource.getSchedules(babyId);
  }

  Future<void> deleteSchedule(String id) async {
    await dataSource.deleteSchedule(id);
  }
}
