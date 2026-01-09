import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Needed for read
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tifli/core/state/child_selection_cubit.dart'; // Import ChildSelectionCubit

class MedicineSchedulePage extends StatefulWidget {
  const MedicineSchedulePage({super.key});

  @override
  State<MedicineSchedulePage> createState() => _MedicineSchedulePageState();
}

class _MedicineSchedulePageState extends State<MedicineSchedulePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int dosageAmount = 1;
  String dosageUnit = 'Pill';

  String intakeType = 'Once a day';
  List<TimeOfDay> times = [const TimeOfDay(hour: 8, minute: 0)];

  int durationValue = 7;
  String durationUnit = 'Days';

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await notifications.initialize(settings);
  }

  DateTime _calculateEndDate() {
    final now = DateTime.now();
    switch (durationUnit) {
      case 'Weeks':
        return now.add(Duration(days: durationValue * 7));
      case 'Months':
        return DateTime(now.year, now.month + durationValue, now.day);
      default:
        return now.add(Duration(days: durationValue));
    }
  }

  Future<void> _scheduleNotifications(String medicineName) async {
    final start = DateTime.now();
    final end = _calculateEndDate();

    for (final time in times) {
      // Create a DateTime for the first occurrence at this specific time
      DateTime current = DateTime(
        start.year,
        start.month,
        start.day,
        time.hour,
        time.minute,
      );

      // If the time for today has already passed, start from tomorrow
      if (current.isBefore(DateTime.now())) {
        current = current.add(const Duration(days: 1));
      }

      while (current.isBefore(end)) {
        // Generate a unique ID: mixture of time and medicine name hash
        // We use masking to ensure it fits in positive 32-bit integer range
        final uniqueId =
            (current.millisecondsSinceEpoch ~/ 1000 + medicineName.hashCode) &
            0x7FFFFFFF;

        try {
          await notifications.zonedSchedule(
            uniqueId,
            'Medicine Reminder',
            'Time to take $medicineName',
            tz.TZDateTime.from(current, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'medicine_channel',
                'Medicine Reminders',
                channelDescription: 'Reminders for medicine schedules',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
        }

        current = current.add(const Duration(days: 1));
      }
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    if (times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one time')),
      );
      return;
    }

    final endDate = _calculateEndDate();

    final List<String> formattedTimes = times
        .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
        .toList();

    // Get baby_id from ChildSelectionCubit
    final childState = context.read<ChildSelectionCubit>().state;
    String? childId;
    if (childState is ChildSelected) {
      childId = childState.childId;
    }

    if (childId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a baby first')),
      );
      return;
    }

    // Save to Supabase (Snake Case)
    try {
      await Supabase.instance.client.from('medicine_schedules').insert({
        'baby_id': childId,
        'medicine_name': _medicineController.text.trim(),
        'dosage_amount': dosageAmount,
        'dosage_unit': dosageUnit,
        'frequency': intakeType,
        'times': formattedTimes,
        'duration_value': durationValue,
        'duration_unit': durationUnit,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });
      debugPrint('Medicine schedule saved to Supabase');
    } catch (e) {
      debugPrint('Error saving to Supabase: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving to Supabase: $e')));
      // We continue to try saving to Firebase even if Supabase fails?
      // User requests both. Failsafe: return if primary fails?
      // Let's assume we want to try both independently or return on failure.
      // Returning on failure is safer for consistency.
      return;
    }

    // Save to Firestore (Camel Case)
    try {
      // Convert times (List<TimeOfDay>) to List<Timestamp> or Strings?
      // User example showed a Timestamp for 'times'.
      // We will create DateTimes for the times on the start date.
      final now = DateTime.now();
      final firestoreTimes = times.map((t) {
        final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
        return Timestamp.fromDate(dt);
      }).toList();

      await FirebaseFirestore.instance.collection('medicine_schedules').add({
        'child_uid': childId,
        'medicineName': _medicineController.text.trim(),
        'dosageAmount': dosageAmount,
        'dosageUnit': dosageUnit,
        'frequency': intakeType,
        'times': firestoreTimes, // List of Timestamps
        'durationValue': durationValue,
        'durationUnit': durationUnit,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endDate),
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Medicine schedule saved to Firebase');
    } catch (e) {
      debugPrint('Error saving to Firebase: $e');
      // Just log error, don't block UI since Supabase succeeded?
      // Or show snackbar.
    }

    await _scheduleNotifications(_medicineController.text.trim());

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget dropdown<T>({
      required T value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?> onChanged,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Schedule')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextFormField(
              controller: _medicineController,
              decoration: const InputDecoration(labelText: 'Medicine Name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 20),
            const Text('Dosage'),
            Row(
              children: [
                Expanded(
                  child: dropdown<String>(
                    value: dosageUnit,
                    items: const [
                      DropdownMenuItem(value: 'Pill', child: Text('Pill')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'Drop', child: Text('Drop')),
                    ],
                    onChanged: (v) => setState(() => dosageUnit = v!),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(
                    () =>
                        dosageAmount = dosageAmount > 1 ? dosageAmount - 1 : 1,
                  ),
                ),
                Text('$dosageAmount'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => dosageAmount++),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text('Frequency'),
            dropdown<String>(
              value: intakeType,
              items: const [
                DropdownMenuItem(
                  value: 'Once a day',
                  child: Text('Once a day'),
                ),
                DropdownMenuItem(
                  value: 'Twice a day',
                  child: Text('Twice a day'),
                ),
                DropdownMenuItem(
                  value: 'Three times a day',
                  child: Text('Three times a day'),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  intakeType = v!;
                  times = List.generate(
                    intakeType == 'Once a day'
                        ? 1
                        : intakeType == 'Twice a day'
                        ? 2
                        : 3,
                    (_) => const TimeOfDay(hour: 8, minute: 0),
                  );
                });
              },
            ),

            const SizedBox(height: 20),
            const Text('Times'),
            ...times.asMap().entries.map((entry) {
              final index = entry.key;
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(times[index].format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: times[index],
                  );
                  if (picked != null) {
                    setState(() => times[index] = picked);
                  }
                },
              );
            }),

            const SizedBox(height: 20),
            const Text('Duration'),
            Row(
              children: [
                Expanded(
                  child: dropdown<String>(
                    value: durationUnit,
                    items: const [
                      DropdownMenuItem(value: 'Days', child: Text('Days')),
                      DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                      DropdownMenuItem(value: 'Months', child: Text('Months')),
                    ],
                    onChanged: (v) => setState(() => durationUnit = v!),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(
                    () => durationValue = durationValue > 1
                        ? durationValue - 1
                        : 1,
                  ),
                ),
                Text('$durationValue'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => durationValue++),
                ),
              ],
            ),

            const SizedBox(height: 20),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveSchedule,
              child: const Text('Save Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
