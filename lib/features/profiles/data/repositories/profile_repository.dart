import '../data_sources/profile_remote_data_source.dart';
import '../models/profile_parent.dart';

class ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepository(this.remote);

  Future<ProfileParent?> getProfile(String userId) async {
    return await remote.fetchProfile(userId);
  }

  Future<ProfileParent> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    return await remote.updateProfile(userId, data);
  }
}
