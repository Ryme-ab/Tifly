import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(ProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(ProfileLoading());
    try {
      final profile = await repository.getProfile(userId);

      if (profile == null) {
        emit(ProfileError("Profile not found in database"));
      } else {
        emit(ProfileLoaded(profile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    emit(ProfileLoading());
    try {
      final profile = await repository.updateProfile(userId, data);
      emit(ProfileUpdated(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
