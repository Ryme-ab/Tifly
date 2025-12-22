import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';
import 'package:tifli/core/constants/app_sizes.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/core/utils/user_context.dart';
import '../cubit/meal_planner_cubit.dart';
import '../../data/models/planned_meal_model.dart';

class MealPlannerScreenV2 extends StatefulWidget {
  const MealPlannerScreenV2({super.key});

  @override
  _MealPlannerScreenV2State createState() => _MealPlannerScreenV2State();
}

class _MealPlannerScreenV2State extends State<MealPlannerScreenV2> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMeals();
    });
  }

  void _loadMeals() {
    final userId = UserContext.getCurrentUserId();
    final childId = context.read<ChildSelectionCubit>().selectedChildId;

    if (userId != null && childId != null) {
      // Load meals for a week range
      final startOfWeek = _startOfWeek;
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      context.read<MealPlannerCubit>().loadPlannedMeals(
        userId,
        childId,
        startDate: startOfWeek,
        endDate: endOfWeek,
      );
    }
  }

  // Normalize date (strip time)
  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // Toggle checked meal
  void _toggleChecked(PlannedMeal meal) async {
    final userId = UserContext.getCurrentUserId();
    final childId = context.read<ChildSelectionCubit>().selectedChildId;

    if (userId != null && childId != null) {
      await context.read<MealPlannerCubit>().toggleMealDone(
        meal.id,
        userId,
        childId,
        meal.isDone,
      );
    }
  }

  // Add or edit meal
  Future<void> _showAddOrEdit({PlannedMeal? meal}) async {
    final userId = UserContext.getCurrentUserId();
    final childId = context.read<ChildSelectionCubit>().selectedChildId;

    if (userId == null || childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child first')),
      );
      return;
    }

    String title = meal?.title ?? '';
    String subtitle = meal?.subtitle ?? '';
    String mealType = meal?.mealType ?? 'breakfast';
    String ingredients = meal?.ingredients ?? '';
    String recipe = meal?.recipe ?? '';

    final titleController = TextEditingController(text: title);
    final subtitleController = TextEditingController(text: subtitle);
    final ingredientsController = TextEditingController(text: ingredients);
    final recipeController = TextEditingController(text: recipe);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(ctx).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radius),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal == null ? 'Add Meal' : 'Edit Meal',
                        style: AppFonts.heading1,
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Meal Type Selector
                      Text(
                        'Meal Type',
                        style: AppFonts.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Wrap(
                        spacing: 8,
                        children: ['breakfast', 'lunch', 'dinner', 'snack'].map(
                          (type) {
                            final isSelected = mealType == type;
                            return ChoiceChip(
                              label: Text(type.toUpperCase()),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  mealType = type;
                                });
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                              ),
                            );
                          },
                        ).toList(),
                      ),
                      const SizedBox(height: AppSizes.md),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Meal title (e.g., Oatmeal Cereal)',
                          labelText: 'Title',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: AppSizes.sm),

                      TextField(
                        controller: subtitleController,
                        decoration: const InputDecoration(
                          hintText: 'Description',
                          labelText: 'Subtitle',
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      TextField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          hintText: 'List ingredients (optional)',
                          labelText: 'Ingredients',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSizes.sm),

                      TextField(
                        controller: recipeController,
                        decoration: const InputDecoration(
                          hintText: 'Recipe instructions (optional)',
                          labelText: 'Recipe',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSizes.md),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          ElevatedButton(
                            onPressed: () async {
                              final t = titleController.text.trim();
                              final s = subtitleController.text.trim();
                              if (t.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a meal title'),
                                  ),
                                );
                                return;
                              }

                              try {
                                if (meal == null) {
                                  // Add new meal
                                  await context
                                      .read<MealPlannerCubit>()
                                      .addPlannedMeal(
                                        userId: userId,
                                        childId: childId,
                                        date: _selectedDate,
                                        mealType: mealType,
                                        title: t,
                                        subtitle: s,
                                        ingredients: ingredientsController.text
                                            .trim(),
                                        recipe: recipeController.text.trim(),
                                      );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Meal added successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  // Update existing meal
                                  await context
                                      .read<MealPlannerCubit>()
                                      .updatePlannedMeal(
                                        id: meal.id,
                                        userId: userId,
                                        childId: childId,
                                        date: _selectedDate,
                                        mealType: mealType,
                                        title: t,
                                        subtitle: s,
                                        isDone: meal.isDone,
                                        ingredients: ingredientsController.text
                                            .trim(),
                                        recipe: recipeController.text.trim(),
                                        createdAt: meal.createdAt,
                                      );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Meal updated successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }

                                Navigator.pop(ctx);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteMeal(PlannedMeal meal) async {
    final userId = UserContext.getCurrentUserId();
    final childId = context.read<ChildSelectionCubit>().selectedChildId;

    if (userId != null && childId != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Meal'),
          content: Text('Are you sure you want to delete "${meal.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await context.read<MealPlannerCubit>().deletePlannedMeal(
          meal.id,
          userId,
          childId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOptions(PlannedMeal meal) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddOrEdit(meal: meal);
                },
              ),
              ListTile(
                leading: Icon(
                  meal.isDone ? Icons.close : Icons.check,
                  color: AppColors.primary,
                ),
                title: Text(meal.isDone ? 'Mark as Not Done' : 'Mark as Done'),
                onTap: () {
                  Navigator.pop(ctx);
                  _toggleChecked(meal);
                },
              ),
              if (meal.recipe != null && meal.recipe!.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                  ),
                  title: const Text('View Recipe'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showRecipeDetails(meal);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMeal(meal);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecipeDetails(PlannedMeal meal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(meal.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (meal.subtitle.isNotEmpty) ...[
                Text(
                  meal.subtitle,
                  style: AppFonts.body.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],
              if (meal.ingredients != null && meal.ingredients!.isNotEmpty) ...[
                Text(
                  'Ingredients:',
                  style: AppFonts.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(meal.ingredients!),
                const SizedBox(height: AppSizes.md),
              ],
              if (meal.recipe != null && meal.recipe!.isNotEmpty) ...[
                Text(
                  'Recipe:',
                  style: AppFonts.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(meal.recipe!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // --- Calendar logic ---

  DateTime get _startOfWeek =>
      _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));

  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
    _loadMeals();
  }

  void _goToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
    _loadMeals();
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDate = day;
    });

    final userId = UserContext.getCurrentUserId();
    final childId = context.read<ChildSelectionCubit>().selectedChildId;

    if (userId != null && childId != null) {
      context.read<MealPlannerCubit>().loadMealsForDate(userId, childId, day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, MMM d').format(_selectedDate);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.backgroundLight,
        appBar: const CustomAppBar(title: 'Meal Planner'),
        body: BlocConsumer<MealPlannerCubit, MealPlannerState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Get meals for selected date
            final mealsForDate = state.getMealsForDate(_selectedDate);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateStrip(dateLabel),
                    const SizedBox(height: AppSizes.md),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Planned Meals',
                          style: AppFonts.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (mealsForDate.isNotEmpty)
                          Text(
                            '${mealsForDate.where((m) => m.isDone).length}/${mealsForDate.length} done',
                            style: AppFonts.body.copyWith(
                              color: AppColors.textPrimaryLight,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),

                    Expanded(
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : mealsForDate.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant,
                                    size: 64,
                                    color: AppColors.textPrimaryLight
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: AppSizes.md),
                                  Text(
                                    'No meals planned for this day',
                                    style: AppFonts.body.copyWith(
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddOrEdit(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add First Meal'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: mealsForDate.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: AppSizes.md),
                              itemBuilder: (context, index) {
                                final meal = mealsForDate[index];
                                return MealCardV2(
                                  meal: meal,
                                  onCheck: () => _toggleChecked(meal),
                                  onMore: () => _showOptions(meal),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOrEdit(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDateStrip(String dateLabel) {
    final startOfWeek = _startOfWeek;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousWeek,
              ),
              Text(dateLabel, style: AppFonts.body),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextWeek,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = startOfWeek.add(Duration(days: index));
              final label = DateFormat('E').format(day); // Sun, Mon, etc.
              final isSelected =
                  _normalizeDate(day) == _normalizeDate(_selectedDate);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    onTap: () => _selectDay(day),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        label,
                        style: AppFonts.body.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class MealCardV2 extends StatelessWidget {
  final PlannedMeal meal;
  final VoidCallback? onCheck;
  final VoidCallback? onMore;

  const MealCardV2({super.key, required this.meal, this.onCheck, this.onMore});

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.fastfood;
    }
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: meal.isDone
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Meal Type Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getMealTypeColor(meal.mealType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              _getMealTypeIcon(meal.mealType),
              color: _getMealTypeColor(meal.mealType),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Meal Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      meal.mealType.toUpperCase(),
                      style: AppFonts.body.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _getMealTypeColor(meal.mealType),
                      ),
                    ),
                    if (meal.isDone) ...[
                      const SizedBox(width: AppSizes.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  meal.title,
                  style: AppFonts.body.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: meal.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (meal.subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    meal.subtitle,
                    style: AppFonts.body.copyWith(
                      color: AppColors.textPrimaryLight,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),

          // Check button
          GestureDetector(
            onTap: onCheck,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: meal.isDone
                    ? AppColors.primary
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(
                  color: meal.isDone
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: meal.isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: AppSizes.xs),

          // More options button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.more_horiz, color: AppColors.primary, size: 20),
              padding: EdgeInsets.zero,
              onPressed: onMore,
            ),
          ),
        ],
      ),
    );
  }
}
