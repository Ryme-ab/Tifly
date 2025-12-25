import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';
import 'package:tifli/core/constants/app_sizes.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/features/trackers/data/models/meal.dart';
import 'package:tifli/features/trackers/presentation/cubit/meal_cubit.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class MealPlannerScreenV2 extends StatefulWidget {
  const MealPlannerScreenV2({super.key});

  @override
  _MealPlannerScreenV2State createState() => _MealPlannerScreenV2State();
}

class _MealPlannerScreenV2State extends State<MealPlannerScreenV2> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedChildId;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _selectedUserId = UserContext.getCurrentUserId();
    _selectedChildId = context.read<ChildSelectionCubit>().selectedChildId;
    
    if (_selectedChildId != null) {
      await _loadMealsForDate();
    }
  }

  Future<void> _loadMealsForDate() async {
    if (_selectedChildId == null) return;
    await context.read<MealCubit>().loadMealLogs(_selectedChildId!);
  }

  // Helper: get meals for current date from BLoC state
  List<Meal> _getMealsForSelectedDate(List<Meal> allMeals) {
    final normalized = _normalizeDate(_selectedDate);
    return allMeals.where((meal) {
      final mealDate = _normalizeDate(meal.mealTime);
      return mealDate.year == normalized.year &&
          mealDate.month == normalized.month &&
          mealDate.day == normalized.day;
    }).toList();
  }

  // Normalize date (strip time)
  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // Toggle meal status (pending/completed)
  Future<void> _toggleMealStatus(Meal meal) async {
    if (_selectedChildId == null || _selectedUserId == null) return;
    
    try {
      final newStatus = meal.status == 'completed' ? 'pending' : 'completed';
      
      await context.read<MealCubit>().updateMeal(
        id: meal.id,
        childId: _selectedChildId!,
        mealTime: meal.mealTime,
        mealType: meal.mealType,
        items: meal.items,
        amount: meal.amount,
        status: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 'completed' ? 'Meal marked as completed' : 'Meal marked as pending'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating meal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Delete meal
  Future<void> _deleteMeal(Meal meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
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

    if (confirmed == true && _selectedChildId != null) {
      try {
        await context.read<MealCubit>().deleteMeal(meal.id, _selectedChildId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal deleted'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting meal: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // Show options menu
  void _showOptions(Meal meal) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(ctx);
              _showAddOrEdit(meal: meal);
            },
          ),
          ListTile(
            leading: Icon(
              meal.status == 'completed' ? Icons.close : Icons.check,
            ),
            title: Text(meal.status == 'completed' ? 'Mark as Pending' : 'Mark as Done'),
            onTap: () {
              Navigator.pop(ctx);
              _toggleMealStatus(meal);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _deleteMeal(meal);
            },
          ),
        ],
      ),
    );
  }

  // Add or edit meal
  Future<void> _showAddOrEdit({Meal? meal}) async {
    if (_selectedChildId == null || _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child first'), backgroundColor: Colors.red),
      );
      return;
    }

    String title = meal?.items ?? '';
    String mealType = meal?.mealType ?? 'breakfast';
    int amount = meal?.amount ?? 120;
    TimeOfDay selectedTime = meal != null 
        ? TimeOfDay.fromDateTime(meal.mealTime)
        : TimeOfDay.now();

    final titleController = TextEditingController(text: title);
    final amountController = TextEditingController(text: amount.toString());

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
                      Center(
                        child: Text(
                          meal == null ? 'Add Meal' : 'Edit Meal',
                          style: AppFonts.heading1,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      
                      // Meal Type Dropdown
                      Text('Meal Type', style: AppFonts.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.sm),
                      DropdownButtonFormField<String>(
                        value: mealType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['breakfast', 'lunch', 'dinner', 'snack', 'milk'].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type[0].toUpperCase() + type.substring(1)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            mealType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      
                      // Food Items
                      Text('Food Items', style: AppFonts.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.sm),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Breast milk, Rice cereal, Apple sauce',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSizes.md),
                      
                      // Amount
                      Text('Amount (ml)', style: AppFonts.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.sm),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '120',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      
                      // Time Picker
                      Text('Time', style: AppFonts.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.sm),
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedTime.format(ctx)),
                              const Icon(Icons.access_time, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      
                      // Buttons
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
                              final items = titleController.text.trim();
                              final amountValue = int.tryParse(amountController.text.trim()) ?? 120;
                              
                              if (items.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text('Please enter food items')),
                                );
                                return;
                              }

                              Navigator.pop(ctx);

                              try {
                                final mealTime = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month,
                                  _selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );

                                if (meal == null) {
                                  // Add new meal
                                  await context.read<MealCubit>().addMeal(
                                    childId: _selectedChildId!,
                                    mealTime: mealTime,
                                    mealType: mealType,
                                    items: items,
                                    amount: amountValue,
                                    status: 'pending',
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Meal added successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } else {
                                  // Update existing meal
                                  await context.read<MealCubit>().updateMeal(
                                    id: meal.id,
                                    childId: _selectedChildId!,
                                    mealTime: mealTime,
                                    mealType: mealType,
                                    items: items,
                                    amount: amountValue,
                                    status: meal.status ?? 'pending',
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Meal updated successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
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

  // Date navigation
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadMealsForDate();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d, yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(
        title: 'Meal Planner',
      ),
      body: BlocBuilder<MealCubit, MealState>(
        builder: (context, state) {
          if (_selectedChildId == null) {
            return const Center(
              child: Text('Please select a child first'),
            );
          }

          final allMeals = state.mealLogs;
          final mealsForDate = _getMealsForSelectedDate(allMeals);

          return Column(
            children: [
              // Date Navigator
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeDate(-1),
                    ),
                    Text(dateLabel, style: AppFonts.heading2),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeDate(1),
                    ),
                  ],
                ),
              ),

              // Meals List
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : mealsForDate.isEmpty
                        ? Center(
                            child: Text(
                              'No meals planned for this day',
                              style: AppFonts.body.copyWith(
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSizes.md),
                            itemCount: mealsForDate.length,
                            itemBuilder: (context, index) {
                              final meal = mealsForDate[index];
                              return _MealCard(
                                meal: meal,
                                onCheck: () => _toggleMealStatus(meal),
                                onMore: () => _showOptions(meal),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEdit(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onCheck;
  final VoidCallback onMore;

  const _MealCard({
    required this.meal,
    required this.onCheck,
    required this.onMore,
  });

  Color _getMealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFF8E1);
      case 'lunch':
        return const Color(0xFFE8F5E9);
      case 'dinner':
        return const Color(0xFFE3F2FD);
      case 'snack':
        return const Color(0xFFFCE4EC);
      case 'milk':
        return const Color(0xFFE0F7FA);
      default:
        return Colors.grey.shade200;
    }
  }

  IconData _getMealTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      case 'milk':
        return Icons.local_drink;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = meal.status == 'completed';
    final timeStr = DateFormat('h:mm a').format(meal.mealTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _getMealTypeColor(meal.mealType),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.grey.shade300,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (_) => onCheck(),
              activeColor: Colors.green,
            ),
            Icon(
              _getMealTypeIcon(meal.mealType),
              color: Colors.grey.shade700,
            ),
          ],
        ),
        title: Text(
          meal.items,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${meal.mealType[0].toUpperCase()}${meal.mealType.substring(1)} • ${meal.amount}ml'),
            Text(timeStr, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DONE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: onMore,
            ),
          ],
        ),
      ),
    );
  }
}
