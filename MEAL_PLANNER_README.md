# Meal Planner Feature

## Overview
The Meal Planner feature allows parents to plan, track, and manage meals for their babies. It includes full CRUD operations, mark as done functionality, and recipe management. **Now uses local SQLite database for offline-first capability.**

## Features Implemented

### 1. **Create Planned Meals**
- Add new meals with title, subtitle, meal type (breakfast, lunch, dinner, snack)
- Include optional ingredients and recipe instructions
- Select date for the meal
- Visual meal type indicators with different colors and icons

### 2. **Read/View Planned Meals**
- View meals by date with calendar navigation
- Weekly calendar view for easy date selection
- List view showing all meals for selected date
- Completion status indicator
- Visual differentiation for completed meals (strikethrough, "DONE" badge)

### 3. **Update Planned Meals**
- Edit meal details including title, subtitle, meal type
- Update ingredients and recipe
- Change meal date
- Mark meals as done/undone with toggle functionality

### 4. **Delete Planned Meals**
- Delete meals with confirmation dialog
- Prevents accidental deletions

### 5. **Additional Features**
- Recipe viewer in a dialog
- Ingredients and recipe display
- Progress tracking (shows X/Y done)
- Empty state with call-to-action
- Loading states for better UX
- Error handling with user feedback via SnackBars
- **Offline-first**: All data stored locally, works without internet

## Architecture

### Data Layer
```
lib/features/schedules/data/
├── models/
│   └── planned_meal_model.dart              # PlannedMeal data model
├── data_sources/
│   ├── meal_planner_data_source.dart        # Local database operations
│   └── meal_planner_local_database.dart     # SQLite database helper
└── repositories/
    └── meal_planner_repository.dart         # Repository pattern
```

### Presentation Layer
```
lib/features/schedules/presentation/
├── cubit/
│   └── meal_planner_cubit.dart              # State management (Bloc/Cubit)
└── screens/
    └── meal_planner_screen.dart             # UI implementation
```

## Data Model

### PlannedMeal
```dart
{
  id: String               // UUID (generated locally)
  userId: String           // User ID
  childId: String          // Child ID
  date: DateTime           // Meal date
  mealType: String         // 'breakfast', 'lunch', 'dinner', 'snack'
  title: String            // Meal title
  subtitle: String         // Description
  isDone: Boolean          // Completion status
  ingredients: String?     // Optional ingredients list
  recipe: String?          // Optional recipe instructions
  createdAt: DateTime      // Creation timestamp
  updatedAt: DateTime      // Last update timestamp
}
```

## Local Database Setup

### SQLite Database: `meal_planner.db`

The app automatically creates and manages a local SQLite database with the following structure:

### Table: `planned_meals`
```sql
CREATE TABLE planned_meals (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  child_id TEXT NOT NULL,
  date TEXT NOT NULL,
  meal_type TEXT NOT NULL,
  title TEXT NOT NULL,
  subtitle TEXT,
  is_done INTEGER DEFAULT 0,      -- 0 = false, 1 = true
  ingredients TEXT,
  recipe TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

### Indexes for Performance
The database includes optimized indexes:
- `idx_planned_meals_user_id` - Fast user lookups
- `idx_planned_meals_child_id` - Fast child lookups
- `idx_planned_meals_date` - Fast date-based queries
- `idx_planned_meals_user_child_date` - Composite index for common queries

### Data Storage Location
- **Android**: `/data/data/<package_name>/databases/meal_planner.db`
- **iOS**: `<app_documents_directory>/meal_planner.db`

No setup required - the database is created automatically on first use!

## State Management

### MealPlannerCubit
Manages all meal planner state and operations:

**State:**
- `plannedMeals`: List of all planned meals
- `stats`: Statistics (completion rate, etc.)
- `isLoading`: Loading indicator
- `error`: Error messages
- `selectedDate`: Currently selected date

**Actions:**
- `loadPlannedMeals()`: Load meals for date range
- `loadMealsForDate()`: Load meals for specific date
- `addPlannedMeal()`: Create new meal
- `updatePlannedMeal()`: Update existing meal
- `toggleMealDone()`: Mark meal as done/undone
- `deletePlannedMeal()`: Delete meal
- `loadMealStats()`: Get statistics
- `changeSelectedDate()`: Change selected date

## UI Components

### MealPlannerScreenV2
Main screen with:
- Weekly calendar navigation
- Date selection
- Meal list display
- Floating action button for adding meals

### MealCardV2
Custom card widget displaying:
- Meal type icon with color coding
- Meal title and subtitle
- Completion checkbox
- "DONE" badge for completed meals
- More options menu button

### Color Coding by Meal Type
- **Breakfast**: Orange (☀️ sun icon)
- **Lunch**: Green (🍽️ restaurant icon)
- **Dinner**: Blue (🍲 dinner icon)
- **Snack**: Purple (🍪 cookie icon)

## Usage

### Adding a New Meal
1. Tap the floating action button (+)
2. Select meal type (breakfast, lunch, dinner, snack)
3. Enter meal title (required)
4. Add subtitle/description (optional)
5. Add ingredients (optional)
6. Add recipe instructions (optional)
6. Tap "Save"

### Editing a Meal
1. Tap the more options button (⋯) on a meal card
2. Select "Edit"
3. Update meal details
4. Tap "Save"

### Marking Meal as Done
**Option 1:** Tap the checkbox on the meal card
**Option 2:** 
1. Tap more options button (⋯)
2. Select "Mark as Done" / "Mark as Not Done"

### Viewing Recipe
1. Tap more options button (⋯)
2. Select "View Recipe"
3. View ingredients and recipe instructions

### Deleting a Meal
1. Tap more options button (⋯)
2. Select "Delete"
3. Confirm deletion

### Navigating Dates
- Use left/right arrows to navigate weeks
- Tap any day in the week strip to select it
- Selected day is highlighted in primary color

## Dependencies Added

The feature uses existing dependencies:
- `flutter_bloc`: State management
- `supabase_flutter`: Database integration
- `intl`: Date formatting

## Integration with App

### BlocProvider Registration
Added to `main.dart`:
```dart
BlocProvider<MealPlannerCubit>(
  create: (_) => MealPlannerCubit(
    repository: MealPlannerRepository(
      dataSource: MealPlannerDataSource(client: supabase),
    ),
  ),
),
```

### Navigation
The screen is already integrated in the schedules menu:
```dart
Route: AppRoutes.mealPlanner = '/schedules/meal-planner'
```

## User Context Requirements

The feature requires:
1. **User Authentication**: Must be logged in (uses `UserContext.getCurrentUserId()`)
2. **Child Selection**: A child must be selected (uses `ChildSelectionCubit`)

## Error Handling

The feature includes comprehensive error handling:
- Network errors are caught and displayed via SnackBar
- Loading states prevent multiple operations
- Validation for required fields
- Confirmation dialogs for destructive actions

## Future Enhancements

Potential improvements:
1. **Meal Templates**: Save favorite meals as templates
2. **Nutrition Information**: Track nutritional values
3. **Shopping List**: Generate shopping list from ingredients
4. **Meal History**: View past meals and reuse them
5. **Notifications**: Remind parents about upcoming meals
6. **Meal Photos**: Add photos to meals
7. **Sharing**: Share meal plans with caregivers
8. **Bulk Operations**: Copy meals to multiple days
9. **Search/Filter**: Search meals by name or ingredients
10. **Statistics**: Weekly/monthly completion rates

## Testing

### Manual Testing Checklist
- [ ] Create a new meal
- [ ] Edit an existing meal
- [ ] Delete a meal
- [ ] Mark meal as done
- [ ] Mark meal as not done
- [ ] View recipe details
- [ ] Navigate between dates
- [ ] View meals for different days
- [ ] Test with no internet connection (offline mode)
- [ ] Test with no meals planned
- [ ] Test with multiple meals
- [ ] Test persistence across app restarts

## Troubleshooting

### Common Issues

**Issue: Meals not loading**
- Check if user is authenticated
- Check if child is selected
- Verify database file permissions
- Check logs for SQLite errors

**Issue: Cannot create meals**
- Verify all required fields are filled
- Check device storage space
- Verify database initialization

**Issue: Compilation errors**
- Run `flutter pub get`
- Run `flutter clean` then `flutter pub get`
- Verify all dependencies in pubspec.yaml
- Check all imports are correct

## Dependencies

The following packages are required and included in `pubspec.yaml`:
```yaml
dependencies:
  sqflite: ^2.3.0           # Local SQLite database
  path_provider: ^2.1.1     # Access to file system paths
  uuid: ^4.5.1              # Generate unique IDs
  flutter_bloc: ^9.1.1      # State management
```

## Support

For issues or questions about this feature:
1. Check the error messages in SnackBars
2. Review console logs (extensive logging included)
3. Verify local database initialization
4. Check device storage permissions

---

**Implementation Date**: December 2024
**Version**: 2.0.0 (Local Database)
**Status**: ✅ Complete - Now using local SQLite database
