import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:tifli/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:tifli/features/auth/data/repositories/auth_repository.dart';
import 'package:tifli/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:tifli/features/auth/presentation/cubit/auth_state.dart';
import 'package:tifli/core/services/notification_service.dart';

// Generate mocks for integration testing
@GenerateMocks([
  AuthRemoteDataSource,
  AuthResponse,
  User,
  Session,
  SupabaseClient,
  GoTrueClient,
  NotificationService,
])
import 'auth_integration_test.mocks.dart';

/// Integration tests for the complete authentication flow
/// These tests verify that all components work together correctly
/// from data source → repository → cubit
void main() {
  group('Auth Integration Tests', () {
    late MockAuthRemoteDataSource mockDataSource;
    late AuthRepository repository;
    late AuthCubit cubit;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    late MockNotificationService mockNotificationService;

    /// Setup before each test
    /// This creates the full authentication stack with all mocked dependencies
    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      repository = AuthRepository(mockDataSource);
      
      // Mock Supabase client and auth
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
      
      // Mock NotificationService
      mockNotificationService = MockNotificationService();
      when(mockNotificationService.initFCM(userId: anyNamed('userId')))
          .thenAnswer((_) async => {});
      
      // Create cubit with mocked dependencies
      cubit = AuthCubit(
        repository,
        supabaseClient: mockSupabaseClient,
        notificationService: mockNotificationService,
      );
    });

    /// Cleanup after each test
    tearDown(() {
      cubit.close();
    });

    /// Integration test group for complete login flow
    group('Complete Login Flow', () {
      const testEmail = 'integration@test.com';
      const testPassword = 'testpassword123';

      test('should successfully complete login flow from cubit to data source', () async {
        // Arrange: Set up the complete mock chain
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        final mockSession = MockSession();

        // Configure mock objects to simulate successful login
        when(mockUser.id).thenReturn('integration-user-id');
        when(mockUser.email).thenReturn(testEmail);
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockAuthResponse.session).thenReturn(mockSession);

        // Mock the data source login
        when(mockDataSource.login(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);
        
        // Mock Supabase auth current user
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);

        // Act: Trigger login from the cubit level
        await cubit.login(testEmail, testPassword);

        // Assert: Verify the final state
        expect(cubit.state, isA<AuthSuccess>());

        // Verify the entire call chain
        verify(mockDataSource.login(testEmail, testPassword)).called(1);
        verify(mockGoTrueClient.currentUser).called(1);
        verify(mockNotificationService.initFCM(userId: 'integration-user-id')).called(1);
      });

      test('should handle login failure throughout the entire stack', () async {
        // Arrange: Set up the mock to simulate failure
        when(mockDataSource.login(testEmail, testPassword))
            .thenThrow(AuthException('Invalid login credentials'));

        // Act: Trigger login from the cubit level
        await cubit.login(testEmail, testPassword);

        // Assert: Verify error state is reached
        expect(cubit.state, isA<AuthError>());
        expect((cubit.state as AuthError).message, contains('Invalid login'));

        // Verify the call was made
        verify(mockDataSource.login(testEmail, testPassword)).called(1);
      });

      test('should transition through loading state during login', () async {
        // Arrange: Set up successful login response
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user-id');
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockDataSource.login(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);

        // Track state changes
        final states = <AuthState>[];
        cubit.stream.listen(states.add);

        // Act: Trigger login
        await cubit.login(testEmail, testPassword);

        // Allow time for stream to emit states
        await Future.delayed(Duration(milliseconds: 100));

        // Assert: Verify state transitions
        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], isA<AuthLoading>());
        expect(states.last, isA<AuthSuccess>());
      });

      test('should properly handle repository error propagation to cubit', () async {
        // Arrange: Mock a null user response (repository level failure)
        final mockAuthResponse = MockAuthResponse();
        when(mockAuthResponse.user).thenReturn(null);
        when(mockDataSource.login(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);

        // Act: Trigger login
        await cubit.login(testEmail, testPassword);

        // Assert: Verify error is propagated correctly
        expect(cubit.state, isA<AuthError>());
        expect((cubit.state as AuthError).message, 'Login failed.');

        // Verify the data source was called
        verify(mockDataSource.login(testEmail, testPassword)).called(1);
      });
    });

    /// Integration test group for complete signup flow
    group('Complete SignUp Flow', () {
      const testEmail = 'newsignup@test.com';
      const testPassword = 'newsignuppassword123';

      test('should successfully complete signup flow from cubit to data source', () async {
        // Arrange: Set up the complete mock chain for signup
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        final mockSession = MockSession();

        // Configure mock objects to simulate successful signup
        when(mockUser.id).thenReturn('new-integration-user-id');
        when(mockUser.email).thenReturn(testEmail);
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockAuthResponse.session).thenReturn(mockSession);

        // Mock the data source signUp
        when(mockDataSource.signUp(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);
        
        // Mock Supabase auth current user
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);

        // Act: Trigger signup from the cubit level
        await cubit.signUp(testEmail, testPassword);

        // Assert: Verify the final state
        expect(cubit.state, isA<AuthSuccess>());

        // Verify the entire call chain
        verify(mockDataSource.signUp(testEmail, testPassword)).called(1);
        verify(mockGoTrueClient.currentUser).called(1);
        verify(mockNotificationService.initFCM(userId: 'new-integration-user-id')).called(1);
      });

      test('should handle signup failure with existing user', () async {
        // Arrange: Set up the mock to simulate duplicate user
        when(mockDataSource.signUp(testEmail, testPassword))
            .thenThrow(AuthException('User already registered'));

        // Act: Trigger signup from the cubit level
        await cubit.signUp(testEmail, testPassword);

        // Assert: Verify error state is reached
        expect(cubit.state, isA<AuthError>());
        expect((cubit.state as AuthError).message, contains('already registered'));

        // Verify the call was made
        verify(mockDataSource.signUp(testEmail, testPassword)).called(1);
      });

      test('should transition through loading state during signup', () async {
        // Arrange: Set up successful signup response
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('new-user-id');
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockDataSource.signUp(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);

        // Track state changes
        final states = <AuthState>[];
        cubit.stream.listen(states.add);

        // Act: Trigger signup
        await cubit.signUp(testEmail, testPassword);

        // Allow time for stream to emit states
        await Future.delayed(Duration(milliseconds: 100));

        // Assert: Verify state transitions
        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], isA<AuthLoading>());
        expect(states.last, isA<AuthSuccess>());
      });

      test('should handle weak password error throughout the stack', () async {
        // Arrange: Mock weak password error
        when(mockDataSource.signUp(testEmail, '123'))
            .thenThrow(AuthException('Password must be at least 6 characters'));

        // Act: Trigger signup with weak password
        await cubit.signUp(testEmail, '123');

        // Assert: Verify error state with appropriate message
        expect(cubit.state, isA<AuthError>());
        expect((cubit.state as AuthError).message, contains('Password'));

        // Verify the data source was called
        verify(mockDataSource.signUp(testEmail, '123')).called(1);
      });
    });

    /// Integration test group for error scenarios
    group('Error Handling Integration', () {
      const testEmail = 'error@test.com';
      const testPassword = 'errorpassword123';

      test('should handle network errors consistently across all layers', () async {
        // Arrange: Simulate network error at data source level
        when(mockDataSource.login(testEmail, testPassword))
            .thenThrow(Exception('Network connection timeout'));

        // Act: Trigger login
        await cubit.login(testEmail, testPassword);

        // Assert: Verify error is properly propagated
        expect(cubit.state, isA<AuthError>());
        expect((cubit.state as AuthError).message, contains('Network'));

        // Verify the call was attempted
        verify(mockDataSource.login(testEmail, testPassword)).called(1);
      });

      test('should handle authentication service unavailable', () async {
        // Arrange: Simulate service unavailable
        when(mockDataSource.login(testEmail, testPassword))
            .thenThrow(Exception('Authentication service temporarily unavailable'));

        // Act: Trigger login
        await cubit.login(testEmail, testPassword);

        // Assert: Verify error state
        expect(cubit.state, isA<AuthError>());
        expect((cubit.state as AuthError).message, contains('temporarily unavailable'));
      });

      test('should handle invalid email format error', () async {
        // Arrange: Simulate invalid email error
        const invalidEmail = 'not-an-email';
        when(mockDataSource.signUp(invalidEmail, testPassword))
            .thenThrow(AuthException('Invalid email format'));

        // Act: Trigger signup with invalid email
        await cubit.signUp(invalidEmail, testPassword);

        // Assert: Verify error state
        expect(cubit.state, isA<AuthError>());
        expect((cubit.state as AuthError).message, contains('Invalid email'));
      });
    });

    /// Integration test group for state transitions
    group('State Management Integration', () {
      const testEmail = 'state@test.com';
      const testPassword = 'statepassword123';

      test('should maintain proper state through multiple operations', () async {
        // Arrange: Set up responses for multiple operations
        final successResponse = MockAuthResponse();
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user-id');
        when(successResponse.user).thenReturn(mockUser);

        when(mockDataSource.login(testEmail, testPassword))
            .thenAnswer((_) async => successResponse);
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);

        // Act: Perform multiple operations
        await cubit.login(testEmail, testPassword);
        expect(cubit.state, isA<AuthSuccess>());

        // Simulate another login with error
        when(mockDataSource.login(testEmail, 'wrongpass'))
            .thenThrow(AuthException('Invalid password'));
        await cubit.login(testEmail, 'wrongpass');

        // Assert: Verify final state
        expect(cubit.state, isA<AuthError>());
      });

      test('should reset to appropriate state after successful operation', () async {
        // Arrange: Set up successful response
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user-id');
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockDataSource.login(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);

        // Act: Perform login
        await cubit.login(testEmail, testPassword);

        // Assert: Verify final state is success (not loading)
        expect(cubit.state, isA<AuthSuccess>());
        expect(cubit.state, isNot(isA<AuthLoading>()));
      });
    });
  });
}
