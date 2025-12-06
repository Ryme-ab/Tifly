import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/parent_profile_model.dart';
import '../../data/repositories/parent_profile_repository.dart';

part 'parent_profile_state.dart';

class ParentProfileCubit extends Cubit<ParentProfileState> {
  final ParentProfileRepository repository;

  ParentProfileCubit(this.repository) : super(ParentProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(ParentProfileLoading());
    try {
      final profile = await repository.getProfile(userId);
      emit(ParentProfileLoaded(profile));
    } catch (e) {
      emit(ParentProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    if (state is ParentProfileLoaded) {
      final currentProfile = (state as ParentProfileLoaded).profile;
      emit(ParentProfileLoading());
      try {
        await repository.updateProfile(userId, updates);
        // Reload the profile to get updated data
        await loadProfile(userId);
      } catch (e) {
        emit(ParentProfileError('Failed to update profile: ${e.toString()}'));
        // Restore previous state
        emit(ParentProfileLoaded(currentProfile));
      }
    }
  }
}
