import 'package:flutter/material.dart';
import 'package:tifli/widgets/calendar.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/features/trackers/presentation/widgets/tracker_button.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/trackers/presentation/cubit/sleep_cubit.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:tifli/features/navigation/app_router.dart';
import 'package:intl/intl.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key, this.showTracker = true, this.existingEntry});
  final bool showTracker;
  final SleepLog? existingEntry;
  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime selectedDate = DateTime.now(); // ✅ ADD THIS: Selected date state
  final notesController = TextEditingController();
  String? selectedQuality;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      startTime = TimeOfDay.fromDateTime(widget.existingEntry!.startTime);
      endTime = TimeOfDay.fromDateTime(widget.existingEntry!.endTime);
      selectedDate = DateTime(
        widget.existingEntry!.startTime.year,
        widget.existingEntry!.startTime.month,
        widget.existingEntry!.startTime.day,
      ); // ✅ Load existing date
      notesController.text = widget.existingEntry!.description;
      selectedQuality = widget.existingEntry!.quality;
      
      final bool qualityExists = qualityOptions.any((q) => q['value'] == selectedQuality);
      if (!qualityExists) {
        selectedQuality = null;
      }
    } else {
      startTime = const TimeOfDay(hour: 8, minute: 30);
      endTime = const TimeOfDay(hour: 8, minute: 30);
      selectedDate = DateTime.now(); // ✅ Default to today for new entries
    }
  }

  final List<Map<String, dynamic>> qualityOptions = [
    {'value': 'not_good', 'label': 'Not Good', 'color': Colors.black},
    {'value': 'good', 'label': 'Good', 'color': Colors.black54},
    {'value': 'excellent', 'label': 'Excellent', 'color': Colors.black87},
  ];

  // ✅ ADD THIS: Date picker function
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

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

    // ✅ FIXED: Use selectedDate instead of DateTime.now()
    final startDateTime = DateTime(
      selectedDate.year,   // ✅ Use selected date
      selectedDate.month,  // ✅ Use selected date
      selectedDate.day,    // ✅ Use selected date
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = DateTime(
      selectedDate.year,   // ✅ Use selected date
      selectedDate.month,  // ✅ Use selected date
      selectedDate.day,    // ✅ Use selected date
      endTime!.hour,
      endTime!.minute,
    );

    final notes = notesController.text.trim();
    final quality = selectedQuality!;

    try {
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

      final duplicateCheck = await client
          .from('sleep')
          .select('id')
          .eq('child_id', selectedChildId)
          .eq('start_time', startDateTime.toIso8601String())
          .eq('end_time', endDateTime.toIso8601String())
          .eq('descp', notes)
          .maybeSingle();

      if (duplicateCheck != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This sleep log already exists!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

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
      
      if (widget.existingEntry != null) {
        // UPDATE MODE
        final updatedLog = SleepLog(
          id: widget.existingEntry!.id,
          userId: userId,
          childId: widget.existingEntry!.childId,
          startTime: startDateTime,
          endTime: endDateTime,
          quality: quality,
          description: notes,
          createdAt: widget.existingEntry!.createdAt,
        );

        await context.read<SleepCubit>().updateSleepLog(updatedLog);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sleep log updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, updatedLog);
        }
      } else {
        // ADD MODE
        final sleepLog = SleepLog(
          id: '',
          userId: userId,
          childId: selectedChildId,
          startTime: startDateTime,
          endTime: endDateTime,
          quality: quality,
          description: notes,
          createdAt: DateTime.now(),
        );

        await context.read<SleepCubit>().addSleepLog(
          sleepLog: sleepLog,
          childId: selectedChildId,
          startTime: startDateTime,
          endTime: endDateTime,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sleep logged successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.sleepingLogs);
        }
      }

      notesController.clear();
      setState(() {
        selectedQuality = null;
        selectedDate = DateTime.now(); // ✅ Reset to today
      });
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
        title: Text(
          widget.existingEntry != null ? 'Edit Sleep Log' : 'Add Trackers',
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
              radius: 18,
              backgroundImage: AssetImage('assets/logo.png'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTracker) ...[
                const Text(
                  'Choose a tracker',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const TrackerButtonsRow(),
                const SizedBox(height: 30),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'When does your baby sleep?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✅ ADD THIS: Date Picker
                    const Text(
                      'Date',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9ECEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time Pickers
                    TimePickerRow(
                      initialStartTime: startTime,
                      initialEndTime: endTime,
                      onStartChanged: (time) {
                        setState(() => startTime = time);
                      },
                      onEndChanged: (time) {
                        setState(() => endTime = time);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Notes
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

                    // Quality Dropdown
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

                    // Log Sleep Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: logSleep,
                        icon: const Icon(
                          Icons.nightlight_round,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA41639),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        label: Text(
                          widget.existingEntry != null
                              ? 'Update Sleep Log'
                              : 'Log Sleep Time',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;

  const TimePickerRow({
    super.key,
    required this.onStartChanged,
    required this.onEndChanged,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  State<TimePickerRow> createState() => _TimePickerRowState();
}

class _TimePickerRowState extends State<TimePickerRow> {
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  @override
  void initState() {
    super.initState();
    startTime = widget.initialStartTime ?? const TimeOfDay(hour: 8, minute: 30);
    endTime = widget.initialEndTime ?? const TimeOfDay(hour: 8, minute: 30);
  }

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