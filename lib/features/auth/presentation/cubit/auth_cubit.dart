import 'package:bloc/bloc.dart';
import 'package:tifli/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:tifli/core/services/notification_service.dart';

/// Cubit for managing authentication state
/// Uses dependency injection for testability
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final SupabaseClient? _supabaseClient;
  final NotificationService? _notificationService;

  /// Constructor with optional dependencies for testing
  /// In production, dependencies default to singleton instances
  /// In tests, mock dependencies can be injected
  AuthCubit(
    this.repository, {
    SupabaseClient? supabaseClient,
    NotificationService? notificationService,
  })  : _supabaseClient = supabaseClient,
        _notificationService = notificationService,
        super(AuthInitial());

  /// Get the Supabase client (real or mock)
  SupabaseClient get _client => _supabaseClient ?? Supabase.instance.client;

  /// Get the notification service (real or mock)
  NotificationService get _notifService =>
      _notificationService ?? NotificationService.instance;

  /// Handles user login
  /// Emits AuthLoading, then AuthSuccess or AuthError
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    final result = await repository.login(email, password);

    if (result == null) {
      // ✅ Get Supabase userId
      final user = _client.auth.currentUser;
      final userId = user?.id;

      if (userId != null) {
        // ✅ Save FCM token for this user
        await _notifService.initFCM(userId: userId);
      }

      emit(AuthSuccess());
    } else {
      emit(AuthError(result));
    }
  }

  /// Handles user signup
  /// Emits AuthLoading, then AuthSuccess or AuthError
  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());

    final result = await repository.signUp(email, password);

    if (result == null) {
      // ✅ Get Supabase userId after successful signup
      final user = _client.auth.currentUser;
      final userId = user?.id;

      if (userId != null) {
        // ✅ Initialize FCM for the new user
        await _notifService.initFCM(userId: userId);
      }

      emit(AuthSuccess());
    } else {
      emit(AuthError(result));
    }
  }
}
