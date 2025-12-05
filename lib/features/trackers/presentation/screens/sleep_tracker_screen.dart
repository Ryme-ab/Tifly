import 'package:flutter/material.dart';
import 'package:tifli/widgets/calendar.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/features/trackers/presentation/widgets/tracker_button.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/trackers/presentation/cubit/sleep_cubit.dart';
import 'package:tifli/features/trackers/data/models/sleep.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:tifli/features/navigation/app_router.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key, this.showTracker = true});
  final bool showTracker;
  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  TimeOfDay? startTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay? endTime = const TimeOfDay(hour: 8, minute: 30);
  final notesController = TextEditingController();
  String? selectedQuality; // Will store: 'not_good', 'good', or 'excellent'

  // Quality options
  final List<Map<String, dynamic>> qualityOptions = [
    {'value': 'not_good', 'label': 'Not Good', 'color': Colors.black},
    {'value': 'good', 'label': 'Good', 'color': Colors.black54},
    {'value': 'excellent', 'label': 'Excellent', 'color': Colors.black87},
  ];

  Future<void> logSleep() async {
    final client = SupabaseClientManager().client;

    if (notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notes field cannot be empty! Please add notes."),
        ),
      );
      return;
    }

    // Quality validation (optional but recommended)
    if (selectedQuality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select sleep quality."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (startTime == null || endTime == null) return;

    final now = DateTime.now();

    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime!.hour,
      endTime!.minute,
    );

    final notes = notesController.text.trim();
    final quality = selectedQuality!; // We know it's not null due to validation

    try {
      // Get selected child ID from ChildSelectionCubit
      final childState = context.read<ChildSelectionCubit>().state;
      if (childState is! ChildSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a baby first"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      final selectedChildId = childState.childId;

      //  CHECK FOR DUPLICATE SLEEP LOG
      final duplicateCheck = await client
          .from('sleep')
          .select('id')
          .eq('child_id', selectedChildId)
          .eq('start_time', startDateTime.toIso8601String())
          .eq('end_time', endDateTime.toIso8601String())
          .eq('descp', notes)
          //.eq('quality', quality)
          .maybeSingle();

      // If a record is found, it means a duplicate exists
      if (duplicateCheck != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This sleep log already exists!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // If no duplicate found, proceed with insertion
      final userId = UserContext.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not authenticated"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      final sleepLog = SleepLog(
        id: '',
        userId: userId,
        childId: selectedChildId,
        startTime: startDateTime,
        endTime: endDateTime,
        quality: quality,
        notes: notes,
      );

      await context.read<SleepCubit>().addSleepLog(
        sleepLog: sleepLog,
        childId: selectedChildId,
        startTime: startDateTime,
        endTime: endDateTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sleep logged successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      notesController.clear();
      setState(() {
        selectedQuality = null;
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.sleepingLogs);
      }
    } catch (e) {
      print("ERROR logging sleep: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to log sleep."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FBFE),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Add Trackers',
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTracker) ...[
                TrackerButtonsRow(),
                const SizedBox(height: 20),
              ],
              SmallWeekCalendar(),
              const SizedBox(height: 20),

              // --- Sleep Tracker Container ---
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
                    TimePickerRow(
                      onStartChanged: (value) => startTime = value,
                      onEndChanged: (value) => endTime = value,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Notes',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add sleep notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- NEW: Quality Dropdown ---
                    const Text(
                      'Sleep Quality',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedQuality,
                          isExpanded: true,
                          hint: const Text(
                            'Select sleep quality',
                            style: TextStyle(color: Colors.grey),
                          ),
                          items: qualityOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: option['color'],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(option['label']),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedQuality = newValue;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- Log Sleep Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: logSleep,
                        icon: const Icon(
                          Icons.nightlight_round,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Log Sleep Time',
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

class TrackerButtonsRow extends StatelessWidget {
  const TrackerButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TrackerButton(
          icon: Icons.water_drop,
          borderColor: Colors.amber,
          activeColor: Colors.amber,
          isActive: false,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const FoodTrackerScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        TrackerButton(
          icon: Icons.nightlight_round,
          borderColor: Colors.blue,
          activeColor: Colors.blue,
          isActive: true,
          onTap: () {},
        ),
        const SizedBox(width: 20),
        TrackerButton(
          icon: Icons.child_care,
          borderColor: Colors.green,
          activeColor: Colors.green,
          isActive: false,
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

class TimePickerRow extends StatefulWidget {
  final Function(TimeOfDay) onStartChanged;
  final Function(TimeOfDay) onEndChanged;

  const TimePickerRow({
    super.key,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  State<TimePickerRow> createState() => _TimePickerRowState();
}

class _TimePickerRowState extends State<TimePickerRow> {
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay endTime = const TimeOfDay(hour: 8, minute: 30);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeColumn("Start time", startTime, () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: startTime,
          );
          if (picked != null) {
            setState(() => startTime = picked);
            widget.onStartChanged(picked);
          }
        }),
        _buildTimeColumn("End time", endTime, () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: endTime,
          );
          if (picked != null) {
            setState(() => endTime = picked);
            widget.onEndChanged(picked);
          }
        }),
      ],
    );
  }

  Widget _buildTimeColumn(String label, TimeOfDay time, VoidCallback onTap) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9ECEE),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
