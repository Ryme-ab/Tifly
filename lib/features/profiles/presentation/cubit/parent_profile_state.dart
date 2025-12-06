part of 'parent_profile_cubit.dart';

abstract class ParentProfileState {}

class ParentProfileInitial extends ParentProfileState {}

class ParentProfileLoading extends ParentProfileState {}

class ParentProfileLoaded extends ParentProfileState {
  final ParentProfileModel profile;

  ParentProfileLoaded(this.profile);
}

class ParentProfileError extends ParentProfileState {
  final String message;

  ParentProfileError(this.message);
}
