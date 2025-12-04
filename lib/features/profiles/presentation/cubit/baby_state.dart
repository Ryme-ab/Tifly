import '../../data/models/baby_model.dart';

abstract class BabyState {}

class BabyInitial extends BabyState {}

class BabyLoading extends BabyState {}

/// ✅ For fetching list of babies
class BabyLoaded extends BabyState {
  final List<Baby> babies;
  BabyLoaded(this.babies);
}

/// ✅ For successful image upload / update
class BabySuccess extends BabyState {
  final Baby baby;
  BabySuccess(this.baby);
}

class BabyError extends BabyState {
  final String message;
  BabyError(this.message);
}
