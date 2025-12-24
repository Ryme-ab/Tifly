import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/widgets/calendar.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/features/trackers/presentation/widgets/tracker_button.dart';
import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import '../cubit/meal_cubit.dart';
import 'package:tifli/features/trackers/data/models/meal.dart';
import 'package:tifli/features/navigation/app_router.dart';
import 'package:tifli/widgets/custom_app_bar.dart'; // Ensure consistent AppBar

class FoodTrackerScreen extends StatefulWidget {
  final bool showTracker;
  final Meal? existingEntry; // Optional entry for editing

  const FoodTrackerScreen({
    super.key,
    this.showTracker = true,
    this.existingEntry,
  });

  @override
  State<FoodTrackerScreen> createState() => _FoodTrackerScreenState();
}

class _FoodTrackerScreenState extends State<FoodTrackerScreen> {
  late String _selectedFeeding;
  late int _quantity;
  late TimeOfDay _selectedTime;
  late String _notes;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _feedingOptions = [
    "Breast Milk",
    "Formula",
    "Solid Food",
    "Juice",
  ];

  @override
  void initState() {
    super.initState();

    // If editing, pre-fill the form
    if (widget.existingEntry != null) {
      _selectedFeeding = widget.existingEntry!.mealType;
      if (!_feedingOptions.contains(_selectedFeeding)) {
         // If the loaded value isn't in our list, add it temporarily so it displays correctly
         _feedingOptions.add(_selectedFeeding);
      }
      
      _quantity = widget.existingEntry!.amount;
      _selectedTime = TimeOfDay.fromDateTime(widget.existingEntry!.mealTime);
      _notes = widget.existingEntry!.items;
      _notesController.text = _notes;
    } else {
      _selectedFeeding = _feedingOptions.first;
      _quantity = 120; // Default reasonable amount
      _selectedTime = const TimeOfDay(hour: 8, minute: 30);
      _notes = "";
      _notesController.text = "";
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFA41639),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Color(0xFFA41639),
              dayPeriodTextColor: Color(0xFFA41639),
              dialHandColor: Color(0xFFA41639),
              dialBackgroundColor: Color(0xFFF9ECEE),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _saveFoodTracker() async {
    // 1. Validation
    // Notes validation (Mandatory as per SleepPage and User Request)
    if (_notesController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notes field cannot be empty! Please add notes."), backgroundColor: Colors.orange));
       return; 
    }

    final now = DateTime.now();
    final mealTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Get selected child ID
    final childState = context.read<ChildSelectionCubit>().state;
    if (childState is! ChildSelected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a baby first"), backgroundColor: Colors.orange),
      );
      return;
    }
    final childId = childState.childId;

    _notes = _notesController.text.trim();

    // 2. Duplicate Check using Supabase directly (Standard Pattern)
    final client = SupabaseClientManager().client;
    
    try {
      final duplicateCheckQuery = client
          .from('meals')
          .select('id')
          .eq('child_id', childId)
          .eq('meal_time', mealTime.toIso8601String()) // Exact time match
          .eq('meal_type', _selectedFeeding)
          .eq('items', _notes) // Check notes/items as well for consistency
          .maybeSingle();

      final duplicateCheck = await duplicateCheckQuery;

      if (duplicateCheck != null) {
          // If we are editing, and the found ID is the SAME as current, it's fine.
          // If it's different ID, then it's a conflict.
          if (widget.existingEntry == null || duplicateCheck['id'].toString() != widget.existingEntry!.id) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This meal log already exists!"),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
      }

      final userId = UserContext.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not authenticated"), backgroundColor: Colors.orange),
        );
        return;
      }

      if (widget.existingEntry != null) {
        // --- EDIT MODE ---
        final updatedMeal = Meal(
            id: widget.existingEntry!.id,
            childId: childId, // maintain or update childId? Usually maintain but form uses current selection. SleepPage uses current selection.
            userId: userId,
            mealTime: mealTime,
            mealType: _selectedFeeding,
            items: _notes.isNotEmpty ? _notes : _selectedFeeding,
            amount: _quantity,
            status: 'completed', 
            createdAt: widget.existingEntry!.createdAt,
        );

        await context.read<MealCubit>().updateMeal(
          id: widget.existingEntry!.id,
          childId: childId,
          mealTime: mealTime,
          mealType: _selectedFeeding,
          items: _notes.isNotEmpty ? _notes : _selectedFeeding,
          amount: _quantity,
          status: 'completed',
        );

        if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meal log updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedMeal); // Return updated object
        
      } else {
        // --- ADD MODE ---
        // SleepPage creates object then calls Cubit. MealCubit.addMeal takes params.
        await context.read<MealCubit>().addMeal(
          childId: childId,
          mealTime: mealTime,
          mealType: _selectedFeeding,
          items: _notes.isNotEmpty ? _notes : _selectedFeeding,
          amount: _quantity,
          status: 'completed',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meal logged successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        // Standard navigation: Replacing current with Logs screen
        Navigator.pushReplacementNamed(context, AppRoutes.feedingLogs);
      }
      
      // Clear form (if staying)
      _notesController.clear();
      // setState defaults... (not needed if navigating away)

    } catch (e) {
      print("ERROR logging meal: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to log meal."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(116, 255, 243, 224), // Matched SleepPage background
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: widget.existingEntry != null
            ? 'Edit Feeding Log'
            : 'Add Feeding Data',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTracker) ...[
                const TrackerButtonsRow(currentPage: 'food'),
                const SizedBox(height: 20),
              ],
              const SmallWeekCalendar(), // Using same widget as SleepPage
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(91, 255, 243, 224),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feeding Type
                    const Text(
                      "Feeding Name",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300), // Lighter border
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFeeding,
                          isExpanded: true,
                          items: _feedingOptions
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.local_drink, // Could vary icon based on type if needed
                                        color: Colors.black54,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(option),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedFeeding = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quantity and Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Quantity (ml)",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Text(
                          "Time",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Quantity Counter
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9ECEE),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Color(0xFFA41639),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_quantity > 0) _quantity -= 10;
                                  });
                                },
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Color(0xFFA41639),
                                ),
                                onPressed: () => setState(() => _quantity += 10),
                              ),
                            ],
                          ),
                        ),
                        // Time Picker
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9ECEE),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _formatTime(_selectedTime),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Notes
                    const Text(
                      'Notes',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveFoodTracker,
                        icon: const Icon(Icons.fastfood, color: Colors.white),
                        label: Text(
                          widget.existingEntry != null
                              ? 'Update Meal'
                              : 'Log Food',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA41639),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// TrackerButtonsRow
class TrackerButtonsRow extends StatelessWidget {
  final String currentPage;
  const TrackerButtonsRow({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TrackerButton(
          icon: Icons.water_drop,
          borderColor: Colors.amber,
          activeColor: Colors.amber,
          isActive: currentPage == 'food',
          onTap: () {},
        ),
        const SizedBox(width: 20),
        TrackerButton(
          icon: Icons.nightlight_round,
          borderColor: Colors.blue,
          activeColor: Colors.blue,
          isActive: currentPage == 'sleep',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SleepPage()),
            );
          },
        ),
        const SizedBox(width: 20),
        TrackerButton(
          icon: Icons.child_care,
          borderColor: Colors.green,
          activeColor: Colors.green,
          isActive: currentPage == 'growth',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GrowthPage()),
            );
          },
        ),
      ],
    );
  }
}
