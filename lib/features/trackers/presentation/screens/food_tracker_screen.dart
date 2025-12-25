// lib/features/trackers/presentation/screens/food_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/widgets/calendar.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import '../cubit/meal_cubit.dart';
import 'sleep_tracker_screen.dart';
import 'growth_tracker_screen.dart';

import 'package:tifli/features/trackers/data/models/meal.dart';
import '../widgets/tracker_button.dart';

class FoodTrackerScreen extends StatefulWidget {
  final bool showTracker;
  final Meal? existingEntry;

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
  late DateTime _selectedDate;
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

    if (widget.existingEntry != null) {
      _selectedFeeding = widget.existingEntry!.mealType;
      if (!_feedingOptions.contains(_selectedFeeding)) _feedingOptions.add(_selectedFeeding);
      _quantity = widget.existingEntry!.amount;
      _selectedTime = TimeOfDay(hour: widget.existingEntry!.mealTime.hour, minute: widget.existingEntry!.mealTime.minute);
      _notes = widget.existingEntry!.items;
      _selectedDate = DateTime(
        widget.existingEntry!.mealTime.year,
        widget.existingEntry!.mealTime.month,
        widget.existingEntry!.mealTime.day,
      );
    } else {
      _selectedFeeding = _feedingOptions.first;
      _quantity = 120; // Default reasonable amount
      _selectedTime = const TimeOfDay(hour: 8, minute: 30);
      _notes = "";
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _saveFoodTracker() async {
    final mealTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Get selected child ID
    final childState = context.read<ChildSelectionCubit>().state;
    if (childState is! ChildSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a baby first"), backgroundColor: Colors.orange),
      );
      return;
    }
    final childId = childState.childId;

    try {
      if (widget.existingEntry != null) {
        // Update existing meal
        await context.read<MealCubit>().updateMeal(
          id: widget.existingEntry!.id,
          childId: childId,
          mealTime: mealTime,
          mealType: _selectedFeeding,
          items: _notes.isNotEmpty ? _notes : _selectedFeeding,
          amount: _quantity,
          status: 'completed',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Meal updated successfully"), backgroundColor: Colors.green),
        );
      } else {
        // Add new meal
        await context.read<MealCubit>().addMeal(
          childId: childId,
          mealTime: mealTime,
          mealType: _selectedFeeding,
          items: _notes.isNotEmpty ? _notes : _selectedFeeding,
          amount: _quantity,
          status: 'completed',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Meal added successfully"), backgroundColor: Colors.green),
        );
      }

      // ✅ Refresh parent list immediately
      context.read<MealCubit>().loadMeals(childId);

      if (!mounted) return;
      Navigator.pop(context, true); // return true to parent
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(116, 255, 243, 224), // Matched SleepPage background
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          widget.existingEntry != null ? "Edit Food Tracker" : "Food Tracker",
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
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

              SmallWeekCalendar(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(91, 255, 243, 224),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Feeding Name", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300), // Lighter border
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedFeeding,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _feedingOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_drink, color: Colors.black54, size: 20),
                                    const SizedBox(width: 8),
                                    Text(option),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedFeeding = val!),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Quantity (ml)", style: TextStyle(fontSize: 14, color: Colors.black54)),
                        Text("Time", style: TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9ECEE),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Color(0xFFA41639)),
                                onPressed: () {
                                  setState(() {
                                    if (_quantity > 0) _quantity -= 10;
                                  });
                                },
                              ),
                              Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Color(0xFFA41639)),
                                onPressed: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9ECEE),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(_formatTime(_selectedTime), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text('Notes', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any notes...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveFoodTracker,
                        icon: const Icon(Icons.fastfood, color: Colors.white),
                        label: Text(widget.existingEntry != null ? 'Update Meal' : 'Save Meal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA41639),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

// Tracker buttons row
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SleepPage()));
          },
        ),
        const SizedBox(width: 20),
        TrackerButton(
          icon: Icons.child_care,
          borderColor: Colors.green,
          activeColor: Colors.green,
          isActive: currentPage == 'growth',
          onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GrowthPage()));
          },
        ),
      ],
    );
  }
}
