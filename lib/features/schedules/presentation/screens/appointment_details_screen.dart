import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/features/schedules/data/models/appointment_model.dart';
import 'package:tifli/features/schedules/data/models/doctor_model.dart';
import 'package:tifli/features/schedules/presentation/cubit/appointments_cubit.dart';
import 'package:tifli/features/schedules/presentation/cubit/appointments_state.dart';
import 'package:tifli/features/schedules/presentation/cubit/doctors_cubit.dart';
import 'package:tifli/features/schedules/presentation/screens/appointment_form_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;
  final String childId;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
    required this.childId,
  });

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load appointment and doctors data
    context.read<AppointmentsCubit>().loadAppointment(
      widget.appointmentId,
      widget.childId,
    );
    context.read<DoctorsCubit>().loadDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Appointment Details",
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Get the current appointment from state
              final state = context.read<AppointmentsCubit>().state;
              if (state is AppointmentLoaded) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppointmentScreen(appointment: state.appointment),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<AppointmentsCubit, AppointmentsState>(
        builder: (context, state) {
          if (state is AppointmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AppointmentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AppointmentsCubit>().loadAppointment(
                        widget.appointmentId,
                        widget.childId,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AppointmentLoaded) {
            return _buildAppointmentDetails(state.appointment);
          }

          return const Center(child: Text('No appointment data'));
        },
      ),
    );
  }

  Widget _buildAppointmentDetails(Appointment appointment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(appointment),
          const SizedBox(height: 20),
          _buildDoctorCard(appointment),
          const SizedBox(height: 20),
          _buildDateTimeCard(appointment),
          const SizedBox(height: 20),
          if (appointment.reminderEnabled) _buildReminderCard(appointment),
          if (appointment.reminderEnabled) const SizedBox(height: 20),
          if (appointment.location != null && appointment.location!.isNotEmpty)
            _buildLocationCard(appointment),
          if (appointment.location != null && appointment.location!.isNotEmpty)
            const SizedBox(height: 20),
          if (appointment.notes != null && appointment.notes!.isNotEmpty)
            _buildNotesCard(appointment),
        ],
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _buildHeaderCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  appointment.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                label: Text(appointment.status.toUpperCase()),
                backgroundColor: _getStatusColor(appointment.status),
              ),
            ],
          ),
          if (appointment.description != null &&
              appointment.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              appointment.description!,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue.shade100;
      case 'completed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'missed':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Widget _buildDoctorCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doctor Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          BlocBuilder<DoctorsCubit, DoctorsState>(
            builder: (context, state) {
              if (state is DoctorsLoaded) {
                if (appointment.doctorId != null) {
                  final doctor = state.doctors.firstWhere(
                    (d) => d.id == appointment.doctorId,
                    orElse: () => Doctor(
                      id: '',
                      fullName: 'Unknown Doctor',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.person, doctor.fullName),
                      if (doctor.specialty != null &&
                          doctor.specialty!.isNotEmpty)
                        _infoRow(Icons.medical_services, doctor.specialty!),
                      if (doctor.phone != null && doctor.phone!.isNotEmpty)
                        _infoRow(Icons.phone, doctor.phone!),
                      if (doctor.hospitalName != null &&
                          doctor.hospitalName!.isNotEmpty)
                        _infoRow(Icons.location_on, doctor.hospitalName!),
                    ],
                  );
                } else {
                  return const Text('No doctor assigned');
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Time',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.calendar_today,
            DateFormat.yMMMMd().format(appointment.appointmentDate),
          ),
          _infoRow(
            Icons.access_time,
            DateFormat.jm().format(appointment.appointmentDate),
          ),
          if (appointment.durationMinutes != null)
            _infoRow(Icons.timer, '${appointment.durationMinutes} minutes'),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Appointment appointment) {
    if (!appointment.reminderEnabled) return const SizedBox.shrink();

    final reminderMinutes = appointment.reminderMinutesBefore ?? 60;
    final reminderDateTime = appointment.appointmentDate.subtract(
      Duration(minutes: reminderMinutes),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reminder',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.notifications_active,
            '$reminderMinutes minutes before appointment',
          ),
          _infoRow(
            Icons.access_time,
            DateFormat.yMMMd().add_jm().format(reminderDateTime),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on, appointment.location!),
          if (appointment.hospitalName != null &&
              appointment.hospitalName!.isNotEmpty)
            _infoRow(Icons.local_hospital, appointment.hospitalName!),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(appointment.notes ?? ''),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xffb03a57)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.black12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
