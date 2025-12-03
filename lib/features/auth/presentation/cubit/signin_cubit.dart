import 'package:flutter_bloc/flutter_bloc.dart';
import 'signin_state.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/signin_repository.dart';
import 'package:bloc/bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  Future<void> signUp(UserModel user) async {
    try {
      emit(AuthLoading());
      final result = await repository.signUp(user); // Returns Supabase.User
      if (result != null) {
        emit(AuthSuccess(user)); // <-- pass your UserModel
      } else {
        emit(AuthError("Sign up failed"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
