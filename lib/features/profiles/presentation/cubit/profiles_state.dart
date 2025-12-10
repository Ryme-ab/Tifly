import '../../data/models/profiles_model.dart';

abstract class ProfilesState {}

class ProfilesInitial extends ProfilesState {}

class ProfilesLoading extends ProfilesState {}

class ProfilesLoaded extends ProfilesState {
  final UserProfileModel profile;
  ProfilesLoaded(this.profile);
}

class ProfilesError extends ProfilesState {
  final String message;
  ProfilesError(this.message);
}
