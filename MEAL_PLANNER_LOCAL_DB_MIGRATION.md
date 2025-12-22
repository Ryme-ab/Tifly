# Meal Planner: Local Database Migration

## Overview
The Meal Planner feature has been successfully migrated from Supabase cloud database to local SQLite database for offline-first capability.

## What Changed

### 1. Database Layer
**Before (Supabase):**
- Cloud-based PostgreSQL database
- Required internet connection
- Data stored on Supabase servers
- Real-time synchronization

**After (SQLite):**
- Local SQLite database
- Works completely offline
- Data stored on device
- Instant access, no network latency

### 2. Files Modified

#### Created:
- `lib/features/schedules/data/data_sources/meal_planner_local_database.dart`
  - SQLite database helper
  - Table creation and management
  - Database version control
  - Performance indexes

#### Updated:
- `lib/features/schedules/data/data_sources/meal_planner_data_source.dart`
  - Replaced Supabase client with SQLite operations
  - Changed from REST API calls to SQL queries
  - Updated to use `uuid` package for ID generation

- `lib/features/schedules/data/models/planned_meal_model.dart`
  - Updated `fromJson()` to handle both boolean and integer for `isDone`
  - SQLite stores booleans as integers (0 = false, 1 = true)

- `lib/features/schedules/presentation/cubit/meal_planner_cubit.dart`
  - Removed Supabase client dependency
  - Now initializes with local data source only

- `lib/main.dart`
  - Updated `MealPlannerCubit` initialization
  - Removed Supabase client parameter

- `pubspec.yaml`
  - Added `sqflite: ^2.3.0`
  - Added `path_provider: ^2.1.1`
  - Added `uuid: ^4.5.1`

## Technical Details

### Database Schema
```sql
CREATE TABLE planned_meals (
  id TEXT PRIMARY KEY,              -- UUID (generated locally)
  user_id TEXT NOT NULL,
  child_id TEXT NOT NULL,
  date TEXT NOT NULL,               -- Stored as ISO8601 date string
  meal_type TEXT NOT NULL,          -- 'breakfast', 'lunch', 'dinner', 'snack'
  title TEXT NOT NULL,
  subtitle TEXT,
  is_done INTEGER DEFAULT 0,        -- 0 = false, 1 = true
  ingredients TEXT,
  recipe TEXT,
  created_at TEXT NOT NULL,         -- ISO8601 timestamp
  updated_at TEXT NOT NULL          -- ISO8601 timestamp
);
```

### Performance Indexes
Four indexes created for optimized queries:
1. `idx_planned_meals_user_id` - User filtering
2. `idx_planned_meals_child_id` - Child filtering
3. `idx_planned_meals_date` - Date-based queries
4. `idx_planned_meals_user_child_date` - Composite for common queries

### CRUD Operations

#### Create
```dart
// Generate UUID locally
final uuid = const Uuid();
final id = uuid.v4();

// Insert into SQLite
await db.insert('planned_meals', {
  'id': id,
  'is_done': isDone ? 1 : 0,  // Convert bool to int
  // ... other fields
});
```

#### Read
```dart
// Query with WHERE clause
final maps = await db.query(
  'planned_meals',
  where: 'user_id = ? AND child_id = ? AND date = ?',
  whereArgs: [userId, childId, dateStr],
  orderBy: 'meal_type ASC',
);
```

#### Update
```dart
await db.update(
  'planned_meals',
  {
    'is_done': isDone ? 1 : 0,
    'updated_at': DateTime.now().toIso8601String(),
  },
  where: 'id = ? AND user_id = ?',
  whereArgs: [id, userId],
);
```

#### Delete
```dart
await db.delete(
  'planned_meals',
  where: 'id = ? AND user_id = ?',
  whereArgs: [id, userId],
);
```

## Benefits of Local Database

### ✅ Advantages
1. **Offline-First**: Works without internet connection
2. **Performance**: Instant data access, no network latency
3. **Privacy**: All data stays on device
4. **No Server Costs**: No database hosting fees
5. **Reliability**: Not affected by server downtime
6. **Speed**: Faster read/write operations

### ⚠️ Considerations
1. **No Cross-Device Sync**: Data doesn't sync between devices
2. **Local Storage Only**: Data lost if app is uninstalled (without backup)
3. **Single User Per Device**: No built-in multi-user support
4. **Manual Backups**: Would need to implement backup/restore manually

## Data Migration

### For Existing Users
If you have existing data in Supabase that needs to be migrated:

1. **Export from Supabase:**
```sql
SELECT * FROM planned_meals 
WHERE user_id = 'your-user-id'
ORDER BY date, meal_type;
```

2. **Import to SQLite:**
Use the app's data import feature (to be implemented) or manually insert records through the app interface.

## Testing the Migration

### Verification Steps:
1. ✅ Create a new meal → Check it saves to local DB
2. ✅ View meals by date → Verify query works correctly
3. ✅ Edit a meal → Confirm updates persist
4. ✅ Toggle done status → Verify boolean/integer conversion
5. ✅ Delete a meal → Ensure deletion works
6. ✅ Restart app → Verify data persists
7. ✅ Test offline → All operations work without internet

## Rollback Plan

If you need to revert to Supabase:

1. Keep the SQL schema file: `database/meal_planner_schema.sql`
2. Revert changes in:
   - `meal_planner_data_source.dart`
   - `meal_planner_cubit.dart`
   - `main.dart`
3. Remove local database dependencies from `pubspec.yaml`
4. Run `flutter pub get`

## Future Enhancements

Possible additions:
1. **Cloud Backup**: Optional backup to Supabase/Firebase
2. **Export/Import**: Export data as JSON for backup
3. **Multi-Device Sync**: Implement sync mechanism
4. **Data Migration Tool**: Automated migration from Supabase
5. **Encryption**: Encrypt sensitive meal data

---

**Migration Date**: December 2024
**Status**: ✅ Complete and Tested
**Breaking Changes**: None for UI, only backend storage changed
