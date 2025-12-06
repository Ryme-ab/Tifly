import '../data_sources/parent_profile_data_source.dart';
import '../models/parent_profile_model.dart';

class ParentProfileRepository {
  final ParentProfileDataSource dataSource;

  ParentProfileRepository({required this.dataSource});

  Future<ParentProfileModel> getProfile(String userId) {
    return dataSource.fetchProfile(userId);
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> updates) {
    return dataSource.updateProfile(userId, updates);
  }
}
