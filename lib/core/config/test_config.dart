/// Test Configuration
///
/// This file contains test IDs for backend testing.
/// To disable test mode, set [enableTestMode] to false.
///
/// IMPORTANT: Remove this file and all references when moving to production!
library;

class TestConfig {
  /// Enable or disable test mode
  /// Set to false to use actual logged-in user data
  static const bool enableTestMode = false;

  /// Test Parent ID
  static const String testParentId = '5f78f913-354a-45f2-805c-5f39bbc09aae';

  /// Test Child ID
  static const String testChildId = 'f44e5e23-182e-4b10-b818-3ee822dd0ff5';

  /// Get the current child ID (test or real)
  /// In production, this would come from auth/session management
  static String getCurrentChildId() {
    if (enableTestMode) {
      return testChildId;
    }
    // Placeholder for production logic
    throw UnimplementedError('Production child ID retrieval not implemented');
  }

  /// Get the current parent ID (test or real)
  /// In production, this would come from auth/session management
  static String getCurrentParentId() {
    if (enableTestMode) {
      return testParentId;
    }
    // Placeholder for production logic
    throw UnimplementedError('Production parent ID retrieval not implemented');
  }
}
