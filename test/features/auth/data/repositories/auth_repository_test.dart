import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:tifli/features/auth/data/repositories/auth_repository.dart';

// Generate mocks for dependencies
@GenerateMocks([AuthRemoteDataSource, AuthResponse, User, Session])
import 'auth_repository_test.mocks.dart';

void main() {
  /// Group all tests related to AuthRepository
  group('AuthRepository', () {
    late AuthRepository repository;
    late MockAuthRemoteDataSource mockRemoteDataSource;

    /// Setup before each test
    /// This ensures each test starts with fresh mock objects
    setUp(() {
      mockRemoteDataSource = MockAuthRemoteDataSource();
      repository = AuthRepository(mockRemoteDataSource);
    });

    /// Test group for login functionality
    group('login', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('should return null when login is successful', () async {
        // Arrange: Set up mock response with a valid user
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        final mockSession = MockSession();

        // Configure mock user
        when(mockUser.id).thenReturn('test-user-id');
        when(mockUser.email).thenReturn(testEmail);
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockAuthResponse.session).thenReturn(mockSession);

        // Mock the remote data source login method
        when(mockRemoteDataSource.login(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);

        // Act: Call the repository login method
        final result = await repository.login(testEmail, testPassword);

        // Assert: Verify that null is returned (indicating success)
        expect(result, isNull);

        // Verify that the remote data source login was called exactly once
        verify(mockRemoteDataSource.login(testEmail, testPassword)).called(1);
        
        // Verify no other interactions occurred
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return error message when login fails with null user', () async {
        // Arrange: Set up mock response with null user
        final mockAuthResponse = MockAuthResponse();
        when(mockAuthResponse.user).thenReturn(null);
        when(mockAuthResponse.session).thenReturn(null);

        // Mock the remote data source login method
        when(mockRemoteDataSource.login(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);

        // Act: Call the repository login method
        final result = await repository.login(testEmail, testPassword);

        // Assert: Verify that error message is returned
        expect(result, 'Login failed.');

        // Verify that the remote data source login was called
        verify(mockRemoteDataSource.login(testEmail, testPassword)).called(1);
      });

      test('should return exception message when an exception occurs', () async {
        // Arrange: Set up the mock to throw an exception
        const exceptionMessage = 'Invalid credentials';
        when(mockRemoteDataSource.login(testEmail, testPassword))
            .thenThrow(AuthException(exceptionMessage));

        // Act: Call the repository login method
        final result = await repository.login(testEmail, testPassword);

        // Assert: Verify that the exception message is returned
        expect(result, contains(exceptionMessage));

        // Verify that the remote data source login was called
        verify(mockRemoteDataSource.login(testEmail, testPassword)).called(1);
      });

      test('should handle network errors gracefully', () async {
        // Arrange: Simulate a network error
        when(mockRemoteDataSource.login(testEmail, testPassword))
            .thenThrow(Exception('Network connection failed'));

        // Act: Call the repository login method
        final result = await repository.login(testEmail, testPassword);

        // Assert: Verify that an error message is returned
        expect(result, isNotNull);
        expect(result, contains('Exception'));

        // Verify that the remote data source login was called
        verify(mockRemoteDataSource.login(testEmail, testPassword)).called(1);
      });

      test('should handle empty credentials', () async {
        // Arrange: Set up mock to throw error for empty credentials
        when(mockRemoteDataSource.login('', ''))
            .thenThrow(AuthException('Email and password are required'));

        // Act: Call the repository login method with empty credentials
        final result = await repository.login('', '');

        // Assert: Verify that an error is returned
        expect(result, isNotNull);
        expect(result, contains('Email and password are required'));

        // Verify that the remote data source login was called
        verify(mockRemoteDataSource.login('', '')).called(1);
      });
    });

    /// Test group for signUp functionality
    group('signUp', () {
      const testEmail = 'newuser@example.com';
      const testPassword = 'newpassword123';

      test('should return null when signup is successful', () async {
        // Arrange: Set up mock response with a valid user
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        final mockSession = MockSession();

        // Configure mock user
        when(mockUser.id).thenReturn('new-user-id');
        when(mockUser.email).thenReturn(testEmail);
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockAuthResponse.session).thenReturn(mockSession);

        // Mock the remote data source signUp method
        when(mockRemoteDataSource.signUp(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);

        // Act: Call the repository signUp method
        final result = await repository.signUp(testEmail, testPassword);

        // Assert: Verify that null is returned (indicating success)
        expect(result, isNull);

        // Verify that the remote data source signUp was called exactly once
        verify(mockRemoteDataSource.signUp(testEmail, testPassword)).called(1);
        
        // Verify no other interactions occurred
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return error message when signup fails with null user', () async {
        // Arrange: Set up mock response with null user
        final mockAuthResponse = MockAuthResponse();
        when(mockAuthResponse.user).thenReturn(null);
        when(mockAuthResponse.session).thenReturn(null);

        // Mock the remote data source signUp method
        when(mockRemoteDataSource.signUp(testEmail, testPassword))
            .thenAnswer((_) async => mockAuthResponse);

        // Act: Call the repository signUp method
        final result = await repository.signUp(testEmail, testPassword);

        // Assert: Verify that error message is returned
        expect(result, 'Signup failed.');

        // Verify that the remote data source signUp was called
        verify(mockRemoteDataSource.signUp(testEmail, testPassword)).called(1);
      });

      test('should return exception message when user already exists', () async {
        // Arrange: Set up the mock to throw an exception
        const exceptionMessage = 'User already registered';
        when(mockRemoteDataSource.signUp(testEmail, testPassword))
            .thenThrow(AuthException(exceptionMessage));

        // Act: Call the repository signUp method
        final result = await repository.signUp(testEmail, testPassword);

        // Assert: Verify that the exception message is returned
        expect(result, contains(exceptionMessage));

        // Verify that the remote data source signUp was called
        verify(mockRemoteDataSource.signUp(testEmail, testPassword)).called(1);
      });

      test('should handle weak password error', () async {
        // Arrange: Set up mock to throw error for weak password
        when(mockRemoteDataSource.signUp(testEmail, '123'))
            .thenThrow(AuthException('Password must be at least 6 characters'));

        // Act: Call the repository signUp method with weak password
        final result = await repository.signUp(testEmail, '123');

        // Assert: Verify that an error is returned
        expect(result, isNotNull);
        expect(result, contains('Password must be at least 6 characters'));

        // Verify that the remote data source signUp was called
        verify(mockRemoteDataSource.signUp(testEmail, '123')).called(1);
      });

      test('should handle invalid email format', () async {
        // Arrange: Set up mock to throw error for invalid email
        const invalidEmail = 'invalid-email';
        when(mockRemoteDataSource.signUp(invalidEmail, testPassword))
            .thenThrow(AuthException('Invalid email format'));

        // Act: Call the repository signUp method with invalid email
        final result = await repository.signUp(invalidEmail, testPassword);

        // Assert: Verify that an error is returned
        expect(result, isNotNull);
        expect(result, contains('Invalid email format'));

        // Verify that the remote data source signUp was called
        verify(mockRemoteDataSource.signUp(invalidEmail, testPassword)).called(1);
      });
    });
  });
}
