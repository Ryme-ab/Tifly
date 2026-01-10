import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/auth/data/data_sources/auth_remote_data_source.dart';

// Generate mocks for SupabaseClient, GoTrueClient, and AuthResponse
@GenerateMocks([SupabaseClient, GoTrueClient, AuthResponse, User, Session])
import 'auth_remote_data_source_test.mocks.dart';

void main() {
  /// Group all tests related to AuthRemoteDataSource
  group('AuthRemoteDataSource', () {
    late AuthRemoteDataSource dataSource;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;

    /// Setup before each test
    /// This initializes fresh mock objects for each test to ensure test isolation
    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      
      // Mock the auth property to return our mock GoTrueClient
      when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
      
      // Inject the mock client into the data source
      dataSource = AuthRemoteDataSource(client: mockSupabaseClient);
    });

    /// Test group for login functionality
    group('login', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('should return AuthResponse when login is successful', () async {
        // Arrange: Set up the test data and mock behavior
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        final mockSession = MockSession();

        // Mock the user and session in the response
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockAuthResponse.session).thenReturn(mockSession);
        when(mockUser.id).thenReturn('test-user-id');
        when(mockUser.email).thenReturn(testEmail);

        // Mock the signInWithPassword method
        when(mockGoTrueClient.signInWithPassword(
          email: testEmail,
          password: testPassword,
        )).thenAnswer((_) async => mockAuthResponse);

        // Act: Call the method we're testing
        final result = await dataSource.login(testEmail, testPassword);

        // Assert: Verify the results
        expect(result, isA<AuthResponse>());
        expect(result.user, isNotNull);
        expect(result.user?.email, testEmail);

        // Verify that signInWithPassword was called with correct parameters
        verify(mockGoTrueClient.signInWithPassword(
          email: testEmail,
          password: testPassword,
        )).called(1);
      });

      test('should throw exception when login fails', () async {
        // Arrange: Set up the mock to throw an exception
        when(mockGoTrueClient.signInWithPassword(
          email: testEmail,
          password: testPassword,
        )).thenThrow(AuthException('Invalid credentials'));

        // Act & Assert: Verify that the exception is thrown
        expect(
          () => dataSource.login(testEmail, testPassword),
          throwsA(isA<AuthException>()),
        );
      });

      test('should handle network errors gracefully', () async {
        // Arrange: Simulate a network error
        when(mockGoTrueClient.signInWithPassword(
          email: testEmail,
          password: testPassword,
        )).thenThrow(Exception('Network error'));

        // Act & Assert: Verify proper error handling
        expect(
          () => dataSource.login(testEmail, testPassword),
          throwsException,
        );
      });
    });

    /// Test group for signUp functionality
    group('signUp', () {
      const testEmail = 'newuser@example.com';
      const testPassword = 'newpassword123';

      test('should return AuthResponse when signup is successful', () async {
        // Arrange: Set up the test data and mock behavior
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        final mockSession = MockSession();

        // Mock the user and session in the response
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockAuthResponse.session).thenReturn(mockSession);
        when(mockUser.id).thenReturn('new-user-id');
        when(mockUser.email).thenReturn(testEmail);

        // Mock the signUp method
        when(mockGoTrueClient.signUp(
          email: testEmail,
          password: testPassword,
        )).thenAnswer((_) async => mockAuthResponse);

        // Act: Call the method we're testing
        final result = await dataSource.signUp(testEmail, testPassword);

        // Assert: Verify the results
        expect(result, isA<AuthResponse>());
        expect(result.user, isNotNull);
        expect(result.user?.email, testEmail);

        // Verify that signUp was called with correct parameters
        verify(mockGoTrueClient.signUp(
          email: testEmail,
          password: testPassword,
        )).called(1);
      });

      test('should throw exception when signup fails due to existing user', () async {
        // Arrange: Set up the mock to throw an exception for duplicate user
        when(mockGoTrueClient.signUp(
          email: testEmail,
          password: testPassword,
        )).thenThrow(AuthException('User already exists'));

        // Act & Assert: Verify that the exception is thrown
        expect(
          () => dataSource.signUp(testEmail, testPassword),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw exception when signup fails due to weak password', () async {
        // Arrange: Set up the mock to throw an exception for weak password
        when(mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: '123', // weak password
        )).thenThrow(AuthException('Password is too weak'));

        // Act & Assert: Verify that the exception is thrown
        expect(
          () => dataSource.signUp('test@example.com', '123'),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });
}
