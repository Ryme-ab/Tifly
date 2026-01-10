import 'package:bloc/bloc.dart';
import 'package:tifli/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:tifli/core/services/notification_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    final result = await repository.login(email, password);

    if (result == null) {
      // ✅ Get Supabase userId
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;

      if (userId != null) {
        // ✅ Save FCM token for this user
        await NotificationService.instance.initFCM(userId: userId);
      }

      emit(AuthSuccess());
    } else {
      emit(AuthError(result));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());

    final result = await repository.signUp(email, password);

    if (result == null) {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;

      if (userId != null) {
        await NotificationService.instance.initFCM(userId: userId);
      }

      emit(AuthSuccess());
    } else {
      emit(AuthError(result));
    }
  }
}
