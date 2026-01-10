<!-- Quick Start – Authentication Tests (Tifly)

This document explains how to run and understand the authentication tests used in the Tifly mobile application. These tests ensure that the authentication feature behaves correctly and remains reliable as the project evolves.

Getting Started

Make sure you are located in the root directory of the Tifly project before running any commands.

1. Install dependencies
cd C:\Users\DELL\Desktop\Tifli\Tifly
flutter pub get


This command installs all required packages for both the application and the test environment.

2. Generate mock files

Some tests rely on mocked dependencies (repositories, data sources). These mocks are generated using build_runner.

flutter pub run build_runner build --delete-conflicting-outputs


Run this command whenever interfaces change or new mocks are added.

3. Run authentication tests
flutter test test/features/auth/

Test Status

All authentication tests are currently passing.

Total tests: 33 / 33

Data source tests: 6

Repository tests: 10

Cubit tests: 9

Integration (error-path) tests: 8

This confirms that the authentication feature is stable across all layers of the application.

Test Structure

The test folder follows the same clean architecture structure used in the application code.

test/features/auth/
├── data/
│   ├── data_sources/
│   │   ├── auth_remote_data_source_test.dart
│   │   └── auth_remote_data_source_test.mocks.dart
│   └── repositories/
│       ├── auth_repository_test.dart
│       └── auth_repository_test.mocks.dart
├── presentation/
│   └── cubit/
│       ├── auth_cubit_test.dart
│       └── auth_cubit_test.mocks.dart
├── integration/
│   ├── auth_integration_test.dart
│   └── auth_integration_test.mocks.dart
├── helpers/
│   └── auth_test_helpers.dart
├── README.md
└── TEST_RESULTS.md


Each layer is tested independently to maintain clear separation of concerns.

Running Tests Selectively

You can run tests for a specific layer or a single file if needed.

Run tests by layer
flutter test test/features/auth/data/data_sources/
flutter test test/features/auth/data/repositories/
flutter test test/features/auth/presentation/cubit/
flutter test test/features/auth/integration/

Run a single test file
flutter test test/features/auth/data/repositories/auth_repository_test.dart

Run with detailed output
flutter test test/features/auth/ --reporter=expanded

Generate coverage report
flutter test test/features/auth/ --coverage

Understanding Test Output
Successful run
00:01 +33: All tests passed!

Failed test example
00:01 +32 -1: AuthRepository login should return null when login is successful
Expected: null
Actual: 'Login failed.'


This usually indicates a mismatch between the implementation and the test expectations.

What Is Tested
AuthRemoteDataSource

Tests direct interaction with the authentication backend:

Login success and failure

Sign-up success and failure

Network and API error handling

AuthRepository

Tests business logic and error handling:

Successful operations

Failure scenarios with clear error messages

Exception handling

Edge cases such as invalid or empty input

AuthCubit

Tests state management behavior:

Initial state verification

Loading to success transitions

Loading to error transitions

Correct propagation of error messages

Integration Tests

Tests how different layers work together:

End-to-end error handling

Cross-layer error propagation

State consistency across the authentication flow

Development Workflow
Adding a new authentication feature

Write the test first

Implement the feature

Run the authentication tests

Verify test coverage

Modifying existing code

Run the related test group

Regenerate mocks if interfaces changed

Run the full test suite to prevent regressions

Troubleshooting
Mock generation issues
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

Tests failing after changes

Ensure tests reflect the updated logic

Check mock behavior

Regenerate mocks when necessary

Testing Principles Applied

Isolation: Each test runs independently

Mocking: External dependencies are mocked

Coverage: All critical paths are tested

Clarity: Tests are readable and easy to understand

Maintainability: Tests mirror the application structure

Before Committing Code

All tests pass locally

New features include corresponding tests

Mock files are up to date

Test coverage remains above 90 percent

Test names clearly describe expected behavior
 -->
