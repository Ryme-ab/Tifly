import 'package:tifli/features/auth/data/data_sources/auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepository(this.remote);

  Future<String?> login(String email, String password) async {
    try {
      final response = await remote.login(email, password);

      if (response.user != null) {
        return null; // success
      } else {
        return 'Login failed.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final response = await remote.signUp(email, password);

      if (response.user != null) {
        return null; // success
      } else {
        return "Signup failed.";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
