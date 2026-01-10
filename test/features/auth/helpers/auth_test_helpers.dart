/// Test Helpers and Utilities
/// This file contains common test utilities and helper functions
/// used across different test files in the authentication module

import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Creates a mock successful AuthResponse with a valid user and session
/// 
/// Parameters:
/// - [userId]: The ID to assign to the mock user (default: 'test-user-id')
/// - [userEmail]: The email to assign to the mock user (default: 'test@example.com')
/// 
/// Returns: A tuple-like map containing mockResponse, mockUser, and mockSession
Map<String, dynamic> createMockSuccessAuthResponse({
  String userId = 'test-user-id',
  String userEmail = 'test@example.com',
}) {
  // Note: This is a placeholder structure since we can't create actual mocks here
  // In real tests, these would be created using the @GenerateMocks annotation
  return {
    'userId': userId,
    'userEmail': userEmail,
    'hasUser': true,
    'hasSession': true,
  };
}

/// Creates a mock failed AuthResponse with null user and session
/// 
/// Returns: A tuple-like map indicating a failed authentication
Map<String, dynamic> createMockFailedAuthResponse() {
  return {
    'hasUser': false,
    'hasSession': false,
  };
}

/// Common test data for authentication tests
class AuthTestData {
  // Valid test credentials
  static const validEmail = 'test@example.com';
  static const validPassword = 'password123';
  
  // Invalid test credentials
  static const invalidEmail = 'invalid-email';
  static const weakPassword = '123';
  static const emptyEmail = '';
  static const emptyPassword = '';
  
  // User IDs
  static const testUserId = 'test-user-id-12345';
  static const newUserId = 'new-user-id-67890';
  
  // Error messages
  static const invalidCredentialsError = 'Invalid credentials';
  static const userExistsError = 'User already registered';
  static const weakPasswordError = 'Password must be at least 6 characters';
  static const invalidEmailError = 'Invalid email format';
  static const networkError = 'Network connection failed';
  static const loginFailedError = 'Login failed.';
  static const signupFailedError = 'Signup failed.';
}

/// Helper class for common test assertions
class AuthTestAssertions {
  /// Verifies that an error message contains expected keywords
  static bool errorContains(String? error, String keyword) {
    return error != null && error.toLowerCase().contains(keyword.toLowerCase());
  }
  
  /// Verifies that the result indicates success (null error)
  static bool isSuccess(String? result) {
    return result == null;
  }
  
  /// Verifies that the result indicates failure (non-null error)
  static bool isFailure(String? result) {
    return result != null;
  }
}

/// Mock verification helpers
class MockVerificationHelper {
  /// Verifies that a mock method was called exactly once with specific arguments
  static void verifyCalledOnce(Function verification) {
    // This is a placeholder - actual verification happens in tests
    // using mockito's verify() function
  }
  
  /// Verifies that no unexpected interactions occurred with a mock
  static void verifyNoOtherInteractions(Mock mock) {
    // This is a placeholder - actual verification happens in tests
    // using mockito's verifyNoMoreInteractions() function
  }
}

/// Async test helpers
class AsyncTestHelper {
  /// Creates a delayed future to simulate async operations
  /// Useful for testing loading states and state transitions
  static Future<T> delayedFuture<T>(T value, {Duration delay = const Duration(milliseconds: 100)}) {
    return Future.delayed(delay, () => value);
  }
  
  /// Creates a delayed exception to simulate async errors
  static Future<T> delayedError<T>(Exception error, {Duration delay = const Duration(milliseconds: 100)}) {
    return Future.delayed(delay, () => throw error);
  }
}

/// Constants for test configuration
class TestConfig {
  // Timeout durations
  static const defaultTimeout = Duration(seconds: 5);
  static const longTimeout = Duration(seconds: 10);
  
  // Retry configuration
  static const maxRetries = 3;
  static const retryDelay = Duration(milliseconds: 100);
  
  // State transition delays
  static const stateTransitionDelay = Duration(milliseconds: 50);
  static const streamEmitDelay = Duration(milliseconds: 100);
}
