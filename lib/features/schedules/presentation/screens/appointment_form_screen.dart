import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tifli/core/services/api_service.dart'; // Import ApiService
import 'package:tifli/features/schedules/data/models/appointment_model.dart';
import 'package:tifli/features/schedules/data/models/doctor_model.dart';
import 'package:tifli/features/schedules/presentation/cubit/appointments_cubit.dart';
import 'package:tifli/features/schedules/presentation/cubit/doctors_cubit.dart';
import 'package:tifli/features/schedules/presentation/screens/add_doctor_page.dart';
import 'package:tifli/features/schedules/presentation/screens/appointments_screen.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class AppointmentScreen extends StatefulWidget {
  final Appointment? appointment; 

  const AppointmentScreen({super.key, this.appointment});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  // Appointment info
  String? selectedDoctorId;
  String status = 'scheduled';
  DateTime? appointmentDate;
  TimeOfDay? appointmentTime;

  // Reminder
  bool reminderEnabled = true;
  int reminderMinutesBefore = 60;

  bool _isLoading = false;

  final List<String> statusOptions = [
    'scheduled',
    'completed',
    'cancelled',
    'missed',
  ];

  // Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Load doctors
    context.read<DoctorsCubit>().loadDoctors();

    // Initialize notifications and request permissions
    _initNotifications();

    // If editing, populate fields
    if (widget.appointment != null) {
      final apt = widget.appointment!;
      titleController.text = apt.title;
      descriptionController.text = apt.description ?? '';
      locationController.text = apt.location ?? '';
      hospitalNameController.text = apt.hospitalName ?? '';
      notesController.text = apt.notes ?? '';
      durationController.text = apt.durationMinutes?.toString() ?? '';
      selectedDoctorId = apt.doctorId;
      status = apt.status;
      appointmentDate = DateTime(
        apt.appointmentDate.year,
        apt.appointmentDate.month,
        apt.appointmentDate.day,
      );
      appointmentTime = TimeOfDay(
        hour: apt.appointmentDate.hour,
        minute: apt.appointmentDate.minute,
      );
      reminderEnabled = apt.reminderEnabled;
      reminderMinutesBefore = apt.reminderMinutesBefore ?? 60;
    }
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permission for Android 13+ (API 33+)
    final android = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      debugPrint('🔔 Notification permission granted: $granted');
    }
  }

  // Test notification to verify setup
  Future<void> _showTestNotification() async {
    debugPrint('🔔 Showing test notification...');
    try {
      await flutterLocalNotificationsPlugin.show(
        999999,
        'Test Notification',
        'If you see this, notifications are working!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_channel',
            'Appointment Reminders',
            channelDescription: 'Reminders for scheduled appointments',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      debugPrint('✅ Test notification sent');
    } catch (e) {
      debugPrint('❌ Failed to show test notification: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    hospitalNameController.dispose();
    notesController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: isEditing ? "Edit Appointment" : "New Appointment",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildTextField(
                "Title",
                titleController,
                validator: (v) => v!.isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 15),

              // Description
              _buildTextField(
                "Description (Optional)",
                descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: 15),

              // Doctor Selection
              _buildDoctorSelector(),
              const SizedBox(height: 15),

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker("Date", appointmentDate, (d) {
                      setState(() => appointmentDate = d);
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimePicker("Time", appointmentTime, (t) {
                      setState(() => appointmentTime = t);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Duration
              _buildTextField(
                "Duration (minutes, optional)",
                durationController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // Location
              _buildTextField("Location (Optional)", locationController),
              const SizedBox(height: 15),

              // Hospital Name
              _buildTextField(
                "Hospital Name (Optional)",
                hospitalNameController,
              ),
              const SizedBox(height: 15),

              // Status
              _buildDropdown(
                label: "Status",
                value: status,
                items: statusOptions,
                onChanged: (val) {
                  setState(() => status = val!);
                },
              ),
              const SizedBox(height: 20),

              // Reminder
              SwitchListTile(
                title: const Text("Enable Reminder"),
                value: reminderEnabled,
                onChanged: (val) {
                  setState(() => reminderEnabled = val);
                },
              ),
              if (reminderEnabled) ...[
                const SizedBox(height: 10),
                _buildTextField(
                  "Remind me (minutes before)",
                  TextEditingController(text: reminderMinutesBefore.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    reminderMinutesBefore = int.tryParse(val) ?? 60;
                  },
                ),
              ],
              const SizedBox(height: 15),

              // Test Notification Button (for debugging)
              OutlinedButton.icon(
                onPressed: _showTestNotification,
                icon: const Icon(Icons.notification_add),
                label: const Text('Test Notification'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD9436B),
                ),
              ),
              const SizedBox(height: 15),

              // Notes
              _buildTextField("Notes (Optional)", notesController, maxLines: 3),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9436B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveAppointment,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(
                    isEditing ? "Update Appointment" : "Save Appointment",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- Helper Widgets ---------------------- //

  Widget _buildDoctorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Doctor (Optional)",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: BlocBuilder<DoctorsCubit, DoctorsState>(
                builder: (context, state) {
                  if (state is DoctorsLoaded) {
                    return DropdownButtonFormField<String>(
                      value: selectedDoctorId,
                      hint: const Text("Select Doctor"),
                      items: state.doctors.map((doctor) {
                        return DropdownMenuItem(
                          value: doctor.id,
                          child: Text(doctor.fullName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedDoctorId = val);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF7F4F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black87,
                            width: 0.5,
                          ),
                        ),
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFD9436B)),
              tooltip: "Add New Doctor",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDoctorPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F4F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F4F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay? selectedTime,
    Function(TimeOfDay) onTimePicked,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null) onTimePicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black87, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          selectedTime != null ? selectedTime.format(context) : label,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDatePicked,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onDatePicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black87, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          selectedDate != null
              ? "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"
              : label,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ),
    );
  }

  String _getDoctorName(String? doctorId) {
    if (doctorId == null) return '';
    final state = context.read<DoctorsCubit>().state;
    if (state is DoctorsLoaded) {
      final doc = state.doctors.firstWhere(
        (d) => d.id == doctorId,
        orElse: () => Doctor(
          id: '',
          fullName: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return doc.fullName;
    }
    return '';
  }

  // ---------------------- Save Appointment ---------------------- //

  void _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    if (appointmentDate == null || appointmentTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    // Get childId from ChildSelectionCubit
    final childState = context.read<ChildSelectionCubit>().state;
    if (childState is! ChildSelected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a baby first')),
      );
      return;
    }
    final childId = childState.childId;

    setState(() => _isLoading = true);

    try {
      // Combine date and time
      final dateTime = DateTime(
        appointmentDate!.year,
        appointmentDate!.month,
        appointmentDate!.day,
        appointmentTime!.hour,
        appointmentTime!.minute,
      );

      final appointment = Appointment(
        id: widget.appointment?.id ?? '', // Empty for new, existing for updates
        childId: childId,
        doctorId: selectedDoctorId,
        title: titleController.text,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        appointmentDate: dateTime,
        durationMinutes: durationController.text.isEmpty
            ? null
            : int.tryParse(durationController.text),
        location: locationController.text.isEmpty
            ? null
            : locationController.text,
        hospitalName: hospitalNameController.text.isEmpty
            ? null
            : hospitalNameController.text,
        status: status,
        reminderEnabled: reminderEnabled,
        reminderMinutesBefore: reminderEnabled ? reminderMinutesBefore : null,
        notes: notesController.text.isEmpty ? null : notesController.text,
        createdAt: widget.appointment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.appointment == null) {
        // Create new
        // final userId = UserContext.getCurrentUserId();

        await context.read<AppointmentsCubit>().addAppointment(appointment);

        // Try to sync with backend, but don't block if it fails
        try {
          await ApiService.instance.createAppointment(
            childId: childId,
            doctorId: selectedDoctorId ?? '',
            doctorName: _getDoctorName(selectedDoctorId),
            title: titleController.text,
            description: descriptionController.text,
            date: dateTime,
          );
        } catch (e) {
          debugPrint('⚠️ Backend sync failed, appointment saved locally: $e');
          // Continue anyway - appointment is already saved locally
        }
      } else {
        // Update existing
        await context.read<AppointmentsCubit>().updateAppointment(appointment);
      }

      // Schedule reminder if enabled
      try {
        await _scheduleReminder(appointment);
      } catch (e) {
        debugPrint('Failed to schedule reminder: $e');
        // Do not block saving if reminder fails
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving appointment: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scheduleReminder(Appointment appointment) async {
    if (!appointment.reminderEnabled) {
      return;
    }

    final scheduledTime = appointment.appointmentDate.subtract(
      Duration(minutes: appointment.reminderMinutesBefore ?? 60),
    );

    if (scheduledTime.isBefore(DateTime.now())) {
      return; // Prevent scheduling in the past
    }

    // Generate a unique notification ID
    final notificationId = appointment.id.isNotEmpty
        ? appointment.id.hashCode
        : DateTime.now().millisecondsSinceEpoch % 2147483647;

    try {
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Appointment Reminder',
        '${appointment.title} at '
            '${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:'
            '${appointment.appointmentDate.minute.toString().padLeft(2, '0')}',
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_channel',
            'Appointment Reminders',
            channelDescription: 'Reminders for scheduled appointments',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
        payload: appointment.id.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
