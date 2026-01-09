# Authentication Tests Documentation

This directory contains comprehensive unit and integration tests for the authentication module of the Tifli application.

## Test Structure

```
test/
└── features/
    └── auth/
        ├── data/
        │   ├── data_sources/
        │   │   └── auth_remote_data_source_test.dart
        │   └── repositories/
        │       └── auth_repository_test.dart
        ├── presentation/
        │   └── cubit/
        │       └── auth_cubit_test.dart
        ├── integration/
        │   └── auth_integration_test.dart
        └── helpers/
            └── auth_test_helpers.dart
```

## Test Files Overview

### 1. Data Source Tests (`auth_remote_data_source_test.dart`)
Tests the `AuthRemoteDataSource` class which handles direct communication with Supabase authentication APIs.

**Covered Scenarios:**
- ✅ Successful login with valid credentials
- ✅ Login failure with invalid credentials
- ✅ Network error handling during login
- ✅ Successful user signup
- ✅ Signup failure for existing users
- ✅ Signup failure for weak passwords
- ✅ Invalid email format handling

### 2. Repository Tests (`auth_repository_test.dart`)
Tests the `AuthRepository` class which acts as an intermediary between data sources and business logic.

**Covered Scenarios:**
- ✅ Successful login returning null (success indicator)
- ✅ Login failure with null user
- ✅ Exception handling and error message propagation
- ✅ Network error handling
- ✅ Empty credentials validation
- ✅ Successful signup returning null
- ✅ Signup failure scenarios (existing user, weak password, invalid email)

### 3. Cubit Tests (`auth_cubit_test.dart`)
Tests the `AuthCubit` class which manages authentication state using the BLoC pattern.

**Covered Scenarios:**
- ✅ Initial state verification (AuthInitial)
- ✅ State transitions: [AuthLoading → AuthSuccess] for successful login
- ✅ State transitions: [AuthLoading → AuthError] for failed login
- ✅ Error message propagation through states
- ✅ Multiple consecutive authentication attempts
- ✅ All signup state transitions
- ✅ Edge cases (empty credentials, weak passwords, invalid emails)

### 4. Integration Tests (`auth_integration_test.dart`)
Tests the complete authentication flow from cubit through repository to data source.

**Covered Scenarios:**
- ✅ Complete login flow from top to bottom
- ✅ Complete signup flow from top to bottom
- ✅ State transitions during authentication
- ✅ Error propagation across all layers
- ✅ Network error handling across the stack
- ✅ Multiple sequential operations
- ✅ State management consistency

### 5. Test Helpers (`auth_test_helpers.dart`)
Utility functions and constants for testing.

**Features:**
- Mock response creators
- Common test data constants
- Test assertion helpers
- Async test utilities
- Test configuration constants

## Running the Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/features/auth/data/repositories/auth_repository_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Integration Tests Only
```bash
flutter test test/features/auth/integration/
```

### Generate Mock Files
```bash
flutter pub run build_runner build
```

## Test Dependencies

The following packages are required for testing:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4          # For creating mock objects
  build_runner: ^2.4.13    # For generating mock classes
  bloc_test: ^9.1.7        # For testing BLoC/Cubit classes
```

## Writing New Tests

### Step 1: Generate Mocks
Add the `@GenerateMocks` annotation above your test file:

```dart
@GenerateMocks([YourClass, Dependency1, Dependency2])
import 'your_test.mocks.dart';
```

### Step 2: Run Build Runner
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Write Tests
Use the standard test structure:

```dart
void main() {
  group('Description', () {
    late YourClass instance;
    late MockDependency mockDependency;
    
    setUp(() {
      mockDependency = MockDependency();
      instance = YourClass(mockDependency);
    });
    
    test('should do something', () async {
      // Arrange
      when(mockDependency.method()).thenAnswer((_) async => result);
      
      // Act
      final result = await instance.method();
      
      // Assert
      expect(result, expected);
      verify(mockDependency.method()).called(1);
    });
  });
}
```

## Test Coverage Goals

- ✅ Data Source Layer: 100% coverage
- ✅ Repository Layer: 100% coverage
- ✅ Cubit/Business Logic: 100% coverage
- ✅ Integration Tests: All critical paths covered

## Common Issues and Solutions

### Issue 1: Mock Generation Fails
**Solution:** Ensure all classes in `@GenerateMocks` are properly imported and accessible.

### Issue 2: Tests Fail with "Bad state: No element"
**Solution:** Check that you're properly mocking all method calls before executing the test.

### Issue 3: BLoC Tests Don't Capture All States
**Solution:** Add `await Future.delayed(Duration(milliseconds: 100))` before assertions to allow state emission.

## Best Practices

1. **Use Descriptive Test Names**: Test names should clearly describe what is being tested
2. **Follow AAA Pattern**: Arrange, Act, Assert
3. **Mock External Dependencies**: Never make real API calls in unit tests
4. **Test Edge Cases**: Include tests for error scenarios, null values, empty inputs
5. **Keep Tests Independent**: Each test should be able to run in isolation
6. **Use setUp and tearDown**: Initialize and clean up resources properly
7. **Comment Complex Logic**: Add comments explaining non-obvious test scenarios

## Continuous Integration

These tests are designed to run in CI/CD pipelines. Ensure your CI configuration includes:

```yaml
- flutter test --coverage
- flutter pub run build_runner build --delete-conflicting-outputs
```

## Maintenance

- Update tests when business logic changes
- Add new tests for new features
- Keep mock objects in sync with actual implementations
- Review and update test helpers regularly

## Contact

For questions about these tests, please refer to the main project documentation or contact the development team.
