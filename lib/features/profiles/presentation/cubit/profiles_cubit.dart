import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/profiles_model.dart';
import '../../data/repositories/profiles_repository.dart';
import 'profiles_state.dart';

class ProfilesCubit extends Cubit<ProfilesState> {
  final ProfilesRepository _repository;

  ProfilesCubit(this._repository) : super(ProfilesInitial());

  Future<void> loadProfile() async {
    emit(ProfilesLoading());
    try {
      final profile = await _repository.getProfile();
      if (profile != null) {
        emit(ProfilesLoaded(profile));
      } else {
        // If profile is null (e.g. first login or error), maybe emit user details from auth if possible
        // For now, let's treat it as an empty profile or error
        emit(ProfilesError("Profile not found"));
      }
    } catch (e) {
      emit(ProfilesError("Failed to load profile: $e"));
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    final currentState = state;
    if (currentState is! ProfilesLoaded) return;

    final oldProfile = currentState.profile;
    final newProfile = UserProfileModel(
      id: oldProfile.id,
      fullName: fullName ?? oldProfile.fullName,
      email: email ?? oldProfile.email,
      phone: phone ?? oldProfile.phone,
      avatarUrl: oldProfile.avatarUrl,
    );

    emit(ProfilesLoading());
    try {
      await _repository.updateProfile(newProfile);
      emit(ProfilesLoaded(newProfile));
    } catch (e) {
      emit(ProfilesError("Failed to update profile: $e"));
      // Re-emit old profile on error
      emit(ProfilesLoaded(oldProfile)); 
    }
  }
  
  Future<void> signOut() async {
     try {
      await _repository.signOut();
      // You might want to navigate to login screen here or emit a state that listeners react to
    } catch (e) {
      emit(ProfilesError("Failed to sign out: $e"));
    }
  }
}
