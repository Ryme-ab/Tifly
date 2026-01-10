import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tifli/features/auth/data/repositories/auth_repository.dart';
import 'package:tifli/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:tifli/features/auth/presentation/cubit/auth_state.dart';

// Generate mocks for AuthRepository
@GenerateMocks([AuthRepository])
import 'auth_cubit_test.mocks.dart';

void main() {
  /// Group all tests related to AuthCubit
  /// NOTE: These tests focus on the repository integration
  /// The Supabase instance and NotificationService interactions are tested in integration tests
  group('AuthCubit', () {
    late MockAuthRepository mockRepository;

    /// Setup before each test
    /// Initialize fresh mock objects for each test
    setUp(() {
      mockRepository = MockAuthRepository();
    });

    /// Test that the initial state is AuthInitial
    test('initial state should be AuthInitial', () {
      // Arrange & Act: Create a new instance of AuthCubit
      final cubit = AuthCubit(mockRepository);

      // Assert: Verify the initial state
      expect(cubit.state, isA<AuthInitial>());

      // Clean up
      cubit.close();
    });

    /// Test group for login functionality
    group('login', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when login fails',
        build: () {
          // Arrange: Mock failed login
          const errorMessage = 'Invalid credentials';
          when(mockRepository.login(testEmail, testPassword))
              .thenAnswer((_) async => errorMessage);
          return AuthCubit(mockRepository);
        },
        act: (cubit) => cubit.login(testEmail, testPassword),
        expect: () => [
          // Assert: Verify the state transitions
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            'Invalid credentials',
          ),
        ],
        verify: (_) {
          // Verify that repository login was called once
          verify(mockRepository.login(testEmail, testPassword)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when login throws exception',
        build: () {
          // Arrange: Mock login that throws exception
          when(mockRepository.login(testEmail, testPassword))
              .thenAnswer((_) async => 'Exception: Network error');
          return AuthCubit(mockRepository);
        },
        act: (cubit) => cubit.login(testEmail, testPassword),
        expect: () => [
          // Assert: Verify the state transitions
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Network error'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when login with empty credentials',
        build: () {
          // Arrange: Mock login with empty credentials
          when(mockRepository.login('', ''))
              .thenAnswer((_) async => 'Email and password are required');
          return AuthCubit(mockRepository);
        },
        act: (cubit) => cubit.login('', ''),
        expect: () => [
          // Assert: Verify the state transitions
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('required'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when user account is locked',
        build: () {
          // Arrange: Mock login with locked account
          const errorMessage = 'Account is temporarily locked';
          when(mockRepository.login(testEmail, testPassword))
              .thenAnswer((_) async => errorMessage);
          return AuthCubit(mockRepository);
        },
        act: (cubit) => cubit.login(testEmail, testPassword),
        expect: () => [
          // Assert: Verify the state transitions
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            'Account is temporarily locked',
          ),
        ],
      );
    });

    /// Test group for signUp functionality
    group('signUp', () {
      const testEmail = 'newuser@example.com';
      const testPassword = 'newpassword123';

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when signup fails',
        build: () {
          // Arrange: Mock failed signup
          const errorMessage = 'User already exists';
          when(mockRepository.signUp(testEmail, testPassword))
              .thenAnswer((_) async => errorMessage);
          return AuthCubit(mockRepository);
        },
        act: (cubit) => cubit.signUp(testEmail, testPassword),
        expect: () => [
          // Assert: Verify the state transitions
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            'User already exists',
          ),
        ],
        verify: (_) {
          // Verify that repository signUp was called once
          verify(mockRepository.signUp(testEmail, testPassword)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when password is too weak',
        build: () {
          // Arrange: Mock signup with weak password
          const errorMessage = 'Password must be at least 6 characters';
          when(mockRepository.signUp(testEmail, '123'))
              .thenAnswer((_) async => errorMessage);
          return AuthCubit(mockRepository);
        },
        act: (cubit) => cubit.signUp(testEmail, '123'),
        expect: () => [
          // Assert: Verify the state transitions
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Password'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when email format is invalid',
        build: () {
          // Arrange: Mock signup with invalid email
          const invalidEmail = 'invalid-email';
          const errorMessage = 'Invalid email format';
          when(mockRepository.signUp(invalidEmail, testPassword))
              .thenAnswer((_) async => errorMessage);
          return AuthCubit(mockRepository);
        },
        act: (cubit) => cubit.signUp('invalid-email', testPassword),
        expect: () => [
          // Assert: Verify the state transitions
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('email'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when network connection fails',
        build: () {
          // Arrange: Mock signup with network error
          const errorMessage = 'Exception: Network connection failed';
          when(mockRepository.signUp(testEmail, testPassword))
              .thenAnswer((_) async => errorMessage);
          return AuthCubit(mockRepository);
        },
        act: (cubit) => cubit.signUp(testEmail, testPassword),
        expect: () => [
          // Assert: Verify the state transitions
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Network'),
          ),
        ],
      );
    });

    /// Test that multiple operations with errors are handled correctly
    group('multiple operations', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      blocTest<AuthCubit, AuthState>(
        'handles consecutive failed login attempts correctly',
        build: () {
          // Arrange: Both logins fail
          when(mockRepository.login(testEmail, testPassword))
              .thenAnswer((_) async => 'Invalid credentials');
          return AuthCubit(mockRepository);
        },
        act: (cubit) async {
          await cubit.login(testEmail, testPassword);
          // Simulate another login attempt
          when(mockRepository.login(testEmail, 'wrongpassword'))
              .thenAnswer((_) async => 'Invalid credentials');
          await cubit.login(testEmail, 'wrongpassword');
        },
        expect: () => [
          // First login
          isA<AuthLoading>(),
          isA<AuthError>(),
          // Second login
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });
  });
}
