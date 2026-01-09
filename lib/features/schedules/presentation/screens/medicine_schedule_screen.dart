import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/features/schedules/data/data_sources/medicine_schedule_data_source.dart';
import 'package:tifli/features/schedules/data/models/medicine_model.dart';
import 'package:tifli/features/schedules/domain/repositories/medicine_schedule_repository.dart';
import 'package:tifli/features/schedules/presentation/cubit/medicine_schedule_cubit.dart';
import 'package:tifli/features/schedules/presentation/screens/add_medicine_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineScheduleCubit(
        repository: MedicineScheduleRepository(
          dataSource: MedicineScheduleDataSource(
            client: Supabase.instance.client,
          ),
        ),
      ),
      child: const _MedicineScreenBody(),
    );
  }
}

class _MedicineScreenBody extends StatefulWidget {
  const _MedicineScreenBody();

  @override
  State<_MedicineScreenBody> createState() => _MedicineScreenBodyState();
}

class _MedicineScreenBodyState extends State<_MedicineScreenBody> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  void _fetchSchedules() {
    final childState = context.read<ChildSelectionCubit>().state;
    if (childState is ChildSelected) {
      context.read<MedicineScheduleCubit>().loadSchedules(childState.childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f4f8),
      appBar: const CustomAppBar(title: 'Medicine Schedule'),
      body: SafeArea(
        child: Column(
          children: [
            _buildWeekSelector(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<MedicineScheduleCubit, MedicineScheduleState>(
                builder: (context, state) {
                   if (state is MedicineScheduleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MedicineScheduleError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is MedicineScheduleLoaded) {
                    final schedules = state.schedules;
                    if (schedules.isEmpty) {
                      return const Center(child: Text("No medicines scheduled"));
                    }

                    // Filter for selected date (simple check if date falls within range)
                    // Currently model has start_date and end_date.
                    // Also simple morning/night split based on first time.
                    
                    final morningMedicines = <MedicineSchedule>[];
                    final nightMedicines = <MedicineSchedule>[];

                    for (var s in schedules) {
                       // Check if selectedDate is within range
                       if (selectedDate.isBefore(s.startDate) || selectedDate.isAfter(s.endDate)) {
                         continue; 
                       }
                      
                       if (s.times.isNotEmpty) {
                         final timeParts = s.times.first.split(':');
                         final hour = int.tryParse(timeParts[0]) ?? 8;
                         if (hour < 12) {
                           morningMedicines.add(s);
                         } else {
                           nightMedicines.add(s);
                         }
                       } else {
                         morningMedicines.add(s); // Default
                       }
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (morningMedicines.isNotEmpty) ...[
                          const Text(
                            "Morning",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...morningMedicines.map((m) => _medicineCard(m, isMorning: true, context: context)),
                           const SizedBox(height: 16),
                        ],
                        
                        if (nightMedicines.isNotEmpty) ...[
                          const Text(
                            "Night",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...nightMedicines.map((m) => _medicineCard(m, isMorning: false, context: context)),
                        ],

                        if (morningMedicines.isEmpty && nightMedicines.isEmpty)
                           const Center(child: Text("No medicines for this date")),

                        const SizedBox(height: 40),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MedicineSchedulePage()),
          );
          if (mounted) _fetchSchedules(); // Refresh after return
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday % 7),
    );
    final weekDays = List.generate(
      7,
      (i) => startOfWeek.add(Duration(days: i)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              "Week of ${DateFormat('d MMM').format(weekDays.first)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((d) {
                final isSelected =
                    DateFormat('yyyy-MM-dd').format(d) ==
                    DateFormat('yyyy-MM-dd').format(selectedDate);
                return GestureDetector(
                  onTap: () => setState(() => selectedDate = d),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(d),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xffb03a57)
                              : const Color(0xfffff0f5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${d.day}",
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicineCard(
    MedicineSchedule medicine, {
    required bool isMorning,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(medicine.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xffb03a57),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
           // Delete logic
           final childState = context.read<ChildSelectionCubit>().state;
            if (childState is ChildSelected) {
              context.read<MedicineScheduleCubit>().deleteSchedule(medicine.id, childState.childId);
            }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isMorning
                ? const Color(0xffdde1eb)
                : const Color(0xfff7f1d1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication, color: Colors.pinkAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.medicineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${medicine.dosageAmount} ${medicine.dosageUnit}, ${medicine.frequency}",
                      style: const TextStyle(color: Colors.pinkAccent),
                    ),
                  ],
                ),
              ),
              // Checkbox logic would need tracking logic in a separate table or local state
              // For now, simplify to just display
              Icon(
                  Icons.check_box_outline_blank,
                   color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

