import '../data_sources/doctors_remote_data_source.dart';
import '../models/doctor_model.dart';

class DoctorsRepository {
  final DoctorsDataSource dataSource;

  DoctorsRepository({required this.dataSource});

  Future<List<Doctor>> fetchDoctors() => dataSource.getDoctors();

  Future<Doctor> fetchDoctorById(String id) => dataSource.getDoctorById(id);

  Future<Doctor> addDoctor(Doctor doctor) => dataSource.addDoctor(doctor);

  Future<void> updateDoctor(Doctor doctor) => dataSource.updateDoctor(doctor);

  Future<void> deleteDoctor(String id) => dataSource.deleteDoctor(id);
}
