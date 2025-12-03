import 'package:bloc/bloc.dart';
import 'package:tifli/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    final result = await repository.login(email, password);

    if (result == null) {
      emit(AuthSuccess());
    } else {
      emit(AuthError(result));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());

    final result = await repository.signUp(email, password);

    if (result == null) {
      emit(AuthSuccess());
    } else {
      emit(AuthError(result));
    }
  }
}
