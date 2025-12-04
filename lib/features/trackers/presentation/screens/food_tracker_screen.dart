import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/widgets/calendar.dart';
import 'package:tifli/features/trackers/presentation/widgets/tracker_button.dart';
import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import '../cubit/meal_cubit.dart';
import 'package:tifli/core/config/supabaseClient.dart';

class FoodTrackerScreen extends StatefulWidget {
  const FoodTrackerScreen({super.key, this.showTracker = true});
  final bool showTracker;
  @override
  State<FoodTrackerScreen> createState() => _FoodTrackerScreenState();
}

class _FoodTrackerScreenState extends State<FoodTrackerScreen> {
  String _selectedFeeding = "Breast Milk";
  int _quantity = 14;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _notes = "";

  final List<String> _feedingOptions = [
    "Breast Milk",
    "Formula",
    "Solid Food",
    "Juice",
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFA41639),
              onPrimary: Colors.white,
              onSurface: Colors.black,
              onSurfaceVariant: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: const Color(0xFFA41639),
              dayPeriodTextColor: const Color(0xFFA41639),
              dialHandColor: const Color(0xFFA41639),
              dialBackgroundColor: const Color(0xFFF9ECEE),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _saveFoodTracker() {
    // Get the current date and time
    final now = DateTime.now();
    final mealTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Check for duplicate meal log before adding
    _checkForDuplicateAndSave(mealTime);
  }

  Future<void> _checkForDuplicateAndSave(DateTime mealTime) async {
    try {
      final client = SupabaseClientManager().client;

      // CHECK FOR DUPLICATE MEAL LOG
      final duplicateCheck = await client
          .from('meals')
          .select('id')
          .eq('child_id', '75ec0c30-58d0-4306-b225-007cd9997b0f')
          .eq('meal_time', mealTime.toIso8601String())
          .eq('meal_type', _selectedFeeding)
          .eq('amount', _quantity)
          .eq('items', _notes.isNotEmpty ? _notes : _selectedFeeding)
          .maybeSingle();

      // If a record is found, it means a duplicate exists
      if (duplicateCheck != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This meal log already exists!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // If no duplicate found, proceed with adding the meal
      if (!mounted) return;
      await context.read<MealCubit>().addMeal(
        mealTime: mealTime,
        mealType: _selectedFeeding,
        items: _notes.isNotEmpty ? _notes : _selectedFeeding,
        amount: _quantity,
        status: 'completed',
      );

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved: $_selectedFeeding - $_quantity ml'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      setState(() {
        _quantity = 14;
        _selectedTime = const TimeOfDay(hour: 8, minute: 30);
        _notes = "";
      });
    } catch (e) {
      // Even if duplicate check fails, still add the meal
      if (!mounted) return;
      await context.read<MealCubit>().addMeal(
        mealTime: mealTime,
        mealType: _selectedFeeding,
        items: _notes.isNotEmpty ? _notes : _selectedFeeding,
        amount: _quantity,
        status: 'completed',
      );

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved: $_selectedFeeding - $_quantity ml'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      setState(() {
        _quantity = 14;
        _selectedTime = const TimeOfDay(hour: 8, minute: 30);
        _notes = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF5),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Food Tracker',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/parent_placeholder.jpg',
              ),
            ),
          ),
        ],
      ),

      // --- Body ---
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Tracker Buttons Row ---
              if (widget.showTracker) ...[
                TrackerButtonsRow(currentPage: 'food'),
                const SizedBox(height: 20),
              ],

              const SmallWeekCalendar(),
              const SizedBox(height: 20),

              // --- Tracker Container ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBF8),
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
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(10),
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
                                    const Icon(
                                      Icons.local_drink,
                                      color: Colors.black54,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
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
                    const SizedBox(height: 20),

                    // Quantity and Time Row
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
                                    if (_quantity > 0) _quantity--;
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
                                onPressed: () {
                                  setState(() => _quantity++);
                                },
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
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      onChanged: (value) => _notes = value,
                    ),
                    const SizedBox(height: 30),

                    // Save Button - NOW WORKING!
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveFoodTracker,
                        icon: const Icon(Icons.fastfood, color: Colors.white),
                        label: const Text(
                          'Save Food Tracker',
                          style: TextStyle(
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

// --- TrackerButtonsRow widget ---
class TrackerButtonsRow extends StatelessWidget {
  final String currentPage;
  const TrackerButtonsRow({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- Food Tracker (Yellow) ---
        TrackerButton(
          icon: Icons.water_drop,
          borderColor: Colors.amber,
          activeColor: Colors.amber,
          isActive: currentPage == 'food',
          onTap: () {
            // Already on food page, do nothing or refresh
          },
        ),
        const SizedBox(width: 20),

        // --- Sleep Tracker (Blue) ---
        TrackerButton(
          icon: Icons.nightlight_round,
          borderColor: Colors.blue,
          activeColor: Colors.blue,
          isActive: currentPage == 'sleep',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SleepPage()),
            );
          },
        ),
        const SizedBox(width: 20),

        // --- Growth Tracker (Green) ---
        TrackerButton(
          icon: Icons.child_care,
          borderColor: Colors.green,
          activeColor: Colors.green,
          isActive: currentPage == 'growth',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GrowthPage()),
            );
          },
        ),
      ],
    );
  }
}
