import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/features/schedules/data/models/appointment_model.dart';
import 'package:tifli/features/schedules/presentation/cubit/appointments_cubit.dart';
import 'package:tifli/features/schedules/presentation/cubit/appointments_state.dart';
import 'package:tifli/features/schedules/presentation/screens/appointment_month_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/appointment_week_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0; // 0=Month 1=Week
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load appointments on init
    context.read<AppointmentsCubit>().loadAppointments();
  }

  void _goToPage(int i) {
    setState(() => currentIndex = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<DateTime> _weekFor(DateTime base) {
    // return 7 days representing the week containing base (Sun..Sat)
    final sunday = base.subtract(Duration(days: base.weekday % 7));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  // Convert List<Appointment> to Map format expected by views
  Map<String, List<Map<String, String>>> _convertAppointments(
    List<Appointment> appointments,
  ) {
    final Map<String, List<Map<String, String>>> result = {};

    for (var appt in appointments) {
      final dateKey = DateFormat('yyyy-MM-dd').format(appt.appointmentDate);
      if (!result.containsKey(dateKey)) {
        result[dateKey] = [];
      }

      result[dateKey]!.add({
        "id": appt.id,
        "time": DateFormat('hh:mm a').format(appt.appointmentDate),
        "title": appt.title,
        "childId": appt.childId,
        // Add other fields if needed by child views
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Appointments'),
      backgroundColor: const Color(0xfff5f4f8),
      body: SafeArea(
        child: Column(
          children: [
            // Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(child: _toggleButton("Month", 0)),
                  const SizedBox(width: 10),
                  Expanded(child: _toggleButton("Week", 1)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<AppointmentsCubit, AppointmentsState>(
                builder: (context, state) {
                  if (state is AppointmentsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffb03a57),
                      ),
                    );
                  }

                  if (state is AppointmentsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AppointmentsCubit>().loadAppointments();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final appointmentsList =
                      state is AppointmentsLoaded ? state.appointments : <Appointment>[];
                  final appointmentsMap = _convertAppointments(appointmentsList);

                  return PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      MonthAppointmentsView(
                        selectedDate: selectedDate,
                        appointments: appointmentsMap,
                        onDayTap: (d) => setState(() => selectedDate = d),
                        onAdd: (d) {
                          // Reload appointments when one is added from month view
                          context.read<AppointmentsCubit>().loadAppointments();
                        },
                      ),

                      WeekAppointmentsView(
                        weekDays: _weekFor(selectedDate),
                        selected: selectedDate,
                        onDaySelected: (d) => setState(() => selectedDate = d),
                        appointmentsForDate: (d) {
                          final key = DateFormat('yyyy-MM-dd').format(d);
                          return appointmentsMap[key] ?? [];
                        },
                        onAdd: (d) {
                          // Reload appointments when one is added from week view
                          context.read<AppointmentsCubit>().loadAppointments();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffb03a57) : Colors.transparent,
          border: Border.all(color: const Color(0xffb03a57)),
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xffb03a57),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
