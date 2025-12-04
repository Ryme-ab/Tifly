import 'package:tifli/features/logs/data/data_sources/medication_log_data_source.dart';
import 'package:tifli/features/logs/data/models/medication_log_model.dart';

class MedicationRepository {
  final MedicationDataSource dataSource;

  MedicationRepository({required this.dataSource});

  Future<List<Medication>> getMedicines(String babyId) =>
      dataSource.getMedicines(babyId);

  Future<Medication> addMedicine(Medication med) => dataSource.addMedicine(med);

  Future<Medication> updateMedicine(String id, Medication med) =>
      dataSource.updateMedicine(id, med);

  Future<void> deleteMedicine(String id) => dataSource.deleteMedicine(id);
}
