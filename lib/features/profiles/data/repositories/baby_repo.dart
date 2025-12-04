import '../data_sources/baby_remote_data_source.dart';
import '../models/baby_model.dart';

class BabyRepository {
  final BabyRemoteDataSource remoteDataSource;

  BabyRepository(this.remoteDataSource);

  // ✅ ADD BABY
  Future<Baby> addBaby(Baby baby) {
    return remoteDataSource.addBaby(baby);
  }

  // ✅ FETCH ALL BABIES (THIS WAS MISSING)
  Future<List<Baby>> getBabies() {
    return remoteDataSource.fetchBabies();
  }

  // ✅ UPLOAD IMAGE (MOBILE)
  Future<void> uploadProfileImage(String babyId, String filePath) {
    return remoteDataSource.uploadProfileImage(
      babyId,
      filePath,
      'baby_profiles',
    );
  }

  // ✅ UPLOAD IMAGE (WEB)
  Future<void> uploadProfileImageBytes(
    String babyId,
    List<int> bytes,
    String bucket,
  ) {
    return remoteDataSource.uploadProfileImageBytes(babyId, bytes, bucket);
  }
}
