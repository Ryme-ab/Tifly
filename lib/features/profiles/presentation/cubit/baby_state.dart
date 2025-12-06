import '../../data/models/baby_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;
  ProfileLoaded(this.profile);
}

class ProfileUpdated extends ProfileState {
  final Map<String, dynamic> profile;
  ProfileUpdated(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// BabyState classes
abstract class BabyState {}

class BabyInitial extends BabyState {}

class BabyLoading extends BabyState {}

class BabyLoaded extends BabyState {
  final List<Baby> babies;
  BabyLoaded(this.babies);
}

class BabySuccess extends BabyState {
  final Baby baby;
  BabySuccess(this.baby);
}

class BabyError extends BabyState {
  final String message;
  BabyError(this.message);
}
