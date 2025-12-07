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
      final loggedInUser = await repository.signUp(user);
      emit(AuthSuccess(loggedInUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String pwd) async {
    try {
      emit(AuthLoading());
      final loggedInUser = await repository.signIn(email, pwd);
      emit(AuthSuccess(loggedInUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await repository.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
