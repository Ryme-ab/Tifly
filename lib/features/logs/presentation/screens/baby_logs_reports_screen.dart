import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/l10n/app_localizations.dart';

import 'package:tifli/features/logs/presentation/screens/growth_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/feeding_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/sleeping_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/medication_logs_screen.dart';

import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_state.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';

class BabyLogsReportsPage extends StatefulWidget {
  const BabyLogsReportsPage({super.key});

  @override
  State<BabyLogsReportsPage> createState() => _BabyLogsReportsPageState();
}

class _BabyLogsReportsPageState extends State<BabyLogsReportsPage> {
  Set<LogType> selectedTypes = {};
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String? selectedTime;
  bool isFiltering = false;
  bool showAllLogs = false; // Show more/less toggle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromCubit();
    });
  }

  void _initializeFromCubit() {
    final cubit = context.read<ChildSelectionCubit>();
    cubit.stream.listen(_handleChildSelectionState);
    _handleChildSelectionState(cubit.state);
  }

  void _handleChildSelectionState(ChildSelectionState state) {
    if (!mounted) return;
    if (state is ChildSelected) {
      context.read<BabyLogsCubit>().loadAllLogs(state.childId);
    }
  }

  // ✨ IMPROVED FILTER DIALOG
  void _showEnhancedFilterDialog() {
    Set<LogType> tempTypes = Set.from(selectedTypes);
    DateTime? tempStartDate = selectedStartDate;
    DateTime? tempEndDate = selectedEndDate;
    String? tempTime = selectedTime;

    final cubit = context.read<BabyLogsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header with Clear All
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Logs",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (tempTypes.isNotEmpty ||
                          tempStartDate != null ||
                          tempTime != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              tempTypes.clear();
                              tempStartDate = null;
                              tempEndDate = null;
                              tempTime = null;
                            });
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text("Clear All"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category Filter with Select All/Clear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Category",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     TextButton(
                      //       onPressed: () {
                      //         setState(() {
                      //           tempTypes = Set.from(LogType.values);
                      //         });
                      //       },
                      //       child: const Text("Select All", style: TextStyle(fontSize: 12)),
                      //     ),
                      //     TextButton(
                      //       onPressed: () {
                      //         setState(() {
                      //           tempTypes.clear();
                      //         });
                      //       },
                      //       child: const Text("Clear", style: TextStyle(fontSize: 12)),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: LogType.values.map((type) {
                      final isSelected = tempTypes.contains(type);
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _typeIcon(type),
                              size: 15,
                              color: isSelected
                                  ? Colors.white
                                  : _tagColor(type),
                            ),
                            const SizedBox(width: 4),
                            Text(_typeDisplayName(type)),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            if (isSelected) {
                              tempTypes.clear(); // unselect
                            } else {
                              tempTypes
                                ..clear()        // remove previous selection
                                ..add(type);     // select only this one
    
                            }
                          });
                        },
                        selectedColor: _tagColor(type),
                        backgroundColor: _tagColor(type).withOpacity(0.1),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 19),

                  // Date Range Filter
                  const Text(
                    "Date Range",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  // Quick date presets with icons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ImprovedDatePresetChip(
                        label: "Today",
                        icon: Icons.today,
                        isSelected:
                            tempStartDate != null &&
                            tempStartDate!.day == DateTime.now().day &&
                            tempStartDate!.month == DateTime.now().month,
                        onTap: () {
                          final now = DateTime.now();
                          setState(() {
                            tempStartDate = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );
                            tempEndDate = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              23,
                              59,
                              59,
                            );
                          });
                        },
                      ),
                      _ImprovedDatePresetChip(
                        label: "Last 7 Days",
                        icon: Icons.date_range,
                        isSelected: false,
                        onTap: () {
                          final now = DateTime.now();
                          setState(() {
                            tempStartDate = now.subtract(
                              const Duration(days: 7),
                            );
                            tempEndDate = now;
                          });
                        },
                      ),
                      // _ImprovedDatePresetChip(
                      //   label: "Last 30 Days",
                      //   icon: Icons.calendar_month,
                      //   isSelected: false,
                      //   onTap: () {
                      //     final now = DateTime.now();
                      //     setState(() {
                      //       tempStartDate = now.subtract(const Duration(days: 30));
                      //       tempEndDate = now;
                      //     });
                      //   },
                      // ),
                      _ImprovedDatePresetChip(
                        label: "This Month",
                        icon: Icons.calendar_today,
                        isSelected: false,
                        onTap: () {
                          final now = DateTime.now();
                          setState(() {
                            tempStartDate = DateTime(now.year, now.month, 1);
                            tempEndDate = now;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Custom date range with gradient
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.05),
                          Colors.purple.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Custom Range",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _ImprovedDatePickerButton(
                                label: "Start Date",
                                date: tempStartDate,
                                onDateSelected: (date) {
                                  setState(() => tempStartDate = date);
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: _ImprovedDatePickerButton(
                                label: "End Date",
                                date: tempEndDate,
                                onDateSelected: (date) {
                                  setState(() => tempEndDate = date);
                                },
                                minDate: tempStartDate,
                              ),
                            ),
                          ],
                        ),
                        if (tempStartDate != null || tempEndDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      tempStartDate = null;
                                      tempEndDate = null;
                                    });
                                  },
                                  icon: const Icon(Icons.clear, size: 16),
                                  label: const Text(
                                    "Clear Dates",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Time Filter with gradient
                  const Text(
                    "Time of Day ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(
                            255,
                            203,
                            201,
                            196,
                          ).withOpacity(0.05),
                          Colors.pink.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const Text(
                              //   "Filter by time",
                              //   style: TextStyle(
                              //     fontSize: 15,
                              //     color: Color.fromARGB(137, 0, 0, 0),
                              //     fontWeight: FontWeight.w600,

                              //   ),
                              // ),
                              Text(
                                tempTime ?? "Any time",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (tempTime != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() => tempTime = null);
                            },
                            color: Colors.red,
                            tooltip: "Clear time",
                          ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: tempTime != null
                                  ? TimeOfDay(
                                      hour: int.parse(tempTime!.split(':')[0]),
                                      minute: int.parse(
                                        tempTime!.split(':')[1],
                                      ),
                                    )
                                  : TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                tempTime =
                                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          icon: Icon(
                            tempTime == null ? Icons.add : Icons.edit,
                            size: 18,
                          ),
                          label: Text(tempTime == null ? "Select" : "Change"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Apply Button - improved
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Apply filters
                        this.setState(() {
                          selectedTypes = tempTypes;
                          selectedStartDate = tempStartDate;
                          selectedEndDate = tempEndDate;
                          selectedTime = tempTime;
                          isFiltering =
                              selectedTypes.isNotEmpty ||
                              selectedStartDate != null ||
                              selectedTime != null;
                        });

                        if (tempTypes.isEmpty &&
                            tempStartDate == null &&
                            tempTime == null) {
                          cubit.clearFilters();
                        } else {
                          // Apply with first selected type or null
                          cubit.applyFilter(
                            type: tempTypes.isEmpty ? null : tempTypes.first,
                            startDate: tempStartDate,
                            endDate: tempEndDate,
                            time: tempTime,
                          );
                        }

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle, size: 24),
                      label: const Text(
                        "Apply Filters",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B6BFF),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1113) : const Color(0xFFF6F4F8);
    final panelColor = isDark ? const Color(0xFF121214) : Colors.white;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: l10n.logsAndReports,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showEnhancedFilterDialog,
              ),
              if (isFiltering)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<BabyLogsCubit, BabyLogsState>(
        builder: (context, state) {
          if (state is BabyLogsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BabyLogsError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          if (state is BabyLogsLoaded) {
            final logs = state.logs;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Filters Chips
                  if (isFiltering) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...selectedTypes.map(
                          (type) => Chip(
                            label: Text(_typeDisplayName(type)),
                            avatar: Icon(_typeIcon(type), size: 16),
                            onDeleted: () {
                              setState(() {
                                selectedTypes.remove(type);
                                if (selectedTypes.isEmpty &&
                                    selectedStartDate == null &&
                                    selectedTime == null) {
                                  isFiltering = false;
                                  context.read<BabyLogsCubit>().clearFilters();
                                }
                              });
                            },
                          ),
                        ),
                        if (selectedStartDate != null)
                          Chip(
                            label: Text(
                              "${DateFormat('MMM d').format(selectedStartDate!)} - ${selectedEndDate != null ? DateFormat('MMM d').format(selectedEndDate!) : 'Now'}",
                            ),
                            avatar: const Icon(Icons.calendar_today, size: 16),
                            onDeleted: () {
                              setState(() {
                                selectedStartDate = null;
                                selectedEndDate = null;
                                if (selectedTypes.isEmpty &&
                                    selectedTime == null) {
                                  isFiltering = false;
                                  context.read<BabyLogsCubit>().clearFilters();
                                }
                              });
                            },
                          ),
                        if (selectedTime != null)
                          Chip(
                            label: Text(selectedTime!),
                            avatar: const Icon(Icons.access_time, size: 16),
                            onDeleted: () {
                              setState(() {
                                selectedTime = null;
                                if (selectedTypes.isEmpty &&
                                    selectedStartDate == null) {
                                  isFiltering = false;
                                  context.read<BabyLogsCubit>().clearFilters();
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Log Type Buttons
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LogButton(
                          icon: Icons.local_drink,
                          title: l10n.feedingLogs,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FeedingLogsScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LogButton(
                          icon: Icons.child_care,
                          title: l10n.growthLogs,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GrowthLogsScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LogButton(
                          icon: Icons.bedtime,
                          title: l10n.sleepingLogs,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SleepingLogsScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LogButton(
                          icon: Icons.medication_liquid,
                          title: l10n.medicationLogs,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MedicationsScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Logs Table
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.45 : 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.02)
                            : Colors.transparent,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                    children: [
                      // Logs list with show more/less
                      ...(() {
                        final logsToShow = showAllLogs 
                            ? logs 
                            : (logs.length > 5 ? logs.take(5).toList() : logs);
                        final hasMoreLogs = logs.length > 5;
                        
                        return [
                          LogTable(logs: logsToShow),
                          
                          // Show More / Show Less Button
                          if (hasMoreLogs)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      showAllLogs = !showAllLogs;
                                    });
                                  },
                                  icon: Icon(
                                    showAllLogs ? Icons.expand_less : Icons.expand_more,
                                    color: const Color(0xFF6B6BFF),
                                  ),
                                  label: Text(
                                    showAllLogs 
                                        ? "Show Less" 
                                        : "Show More (${logs.length - 5} more)",
                                    style: const TextStyle(
                                      color: Color(0xFF6B6BFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ];
                      })(),
                    ],
                  ),
                  ),
                  const SizedBox(height: 32),

                  // CHARTS SECTION
                  if (logs.isNotEmpty) ...[
                    const Text(
                      " Logs Analytics",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfessionalChartsSection(logs: logs, isDark: isDark),
                  ],

                  const SizedBox(height: 120),
                ],
              ),
            );
          }

          return const Center(child: Text("Select a baby to view logs."));
        },
      ),
    );
  }

  Color _tagColor(LogType type) {
    switch (type) {
      case LogType.feeding:
        return const Color(0xFF6B6BFF);
      case LogType.sleep:
        return const Color(0xFF4FB783);
      case LogType.medication:
        return const Color(0xFFE74C3C);
      case LogType.growth:
        return const Color(0xFF8E44AD);
    }
  }

  IconData _typeIcon(LogType type) {
    switch (type) {
      case LogType.feeding:
        return Icons.local_drink;
      case LogType.sleep:
        return Icons.bedtime;
      case LogType.medication:
        return Icons.medication_liquid;
      case LogType.growth:
        return Icons.child_care;
    }
  }

  String _typeDisplayName(LogType type) {
    switch (type) {
      case LogType.feeding:
        return "Feeding";
      case LogType.sleep:
        return "Sleep";
      case LogType.medication:
        return "Medication";
      case LogType.growth:
        return "Growth";
    }
  }
}

extension on Set<LogType> {
  get tempTypes => null;
}

// ===== IMPROVED WIDGETS =====

class _ImprovedDatePresetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ImprovedDatePresetChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B6BFF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6B6BFF) : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B6BFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImprovedDatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime) onDateSelected;
  final DateTime? minDate;

  const _ImprovedDatePickerButton({
    required this.label,
    required this.date,
    required this.onDateSelected,
    this.minDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: minDate ?? DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: date != null
                ? const Color(0xFF6B6BFF)
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null
                      ? const Color(0xFF6B6BFF)
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('MMM d, yyyy').format(date!)
                        : "Select",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: date != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// PROFESSIONAL CHARTS SECTION
class ProfessionalChartsSection extends StatelessWidget {
  final List<BabyLog> logs;
  final bool isDark;

  const ProfessionalChartsSection({
    super.key,
    required this.logs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Prepare data
    final Map<LogType, int> logCounts = {};
    final Map<String, int> logsPerDay = {};

    for (var log in logs) {
      logCounts[log.type] = (logCounts[log.type] ?? 0) + 1;
      final dayKey = DateFormat('MM/dd').format(log.timestamp);
      logsPerDay[dayKey] = (logsPerDay[dayKey] ?? 0) + 1;
    }

    final sortedDays = logsPerDay.keys.toList()..sort();

    return Column(
      children: [
        // Pie Chart - Log Type Distribution
        _ChartCard(
          title: "Log Type Distribution",
          isDark: isDark,
          child: SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                      sections: logCounts.entries.map((e) {
                        final percentage = (e.value / logs.length * 100)
                            .toStringAsFixed(1);
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          title: '$percentage%',
                          color: _getColor(e.key),
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: logCounts.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getColor(e.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getTypeName(e.key),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              '${e.value}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Line Chart - Logs Over Time
        _ChartCard(
          title: "Logs Over Time",
          isDark: isDark,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, _) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedDays.length) {
                            if (index % 2 == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  sortedDays[index],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        sortedDays.length,
                        (i) => FlSpot(
                          i.toDouble(),
                          logsPerDay[sortedDays[i]]!.toDouble(),
                        ),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Bar Chart - Log Type Comparison
        _ChartCard(
          title: "Activity Comparison",
          isDark: isDark,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (logCounts.values.reduce((a, b) => a > b ? a : b) + 2)
                      .toDouble(),
                  barGroups: logCounts.entries.toList().asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.value.toDouble(),
                          color: _getColor(data.key),
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY:
                                (logCounts.values.reduce(
                                          (a, b) => a > b ? a : b,
                                        ) +
                                        2)
                                    .toDouble(),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, _) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final entries = logCounts.entries.toList();
                          final index = value.toInt();
                          if (index >= 0 && index < entries.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getTypeName(entries[index].key),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getColor(entries[index].key),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor(LogType type) {
    switch (type) {
      case LogType.feeding:
        return const Color(0xFF6B6BFF);
      case LogType.sleep:
        return const Color(0xFF4FB783);
      case LogType.medication:
        return const Color(0xFFE74C3C);
      case LogType.growth:
        return const Color(0xFF8E44AD);
    }
  }

  String _getTypeName(LogType type) {
    switch (type) {
      case LogType.feeding:
        return "Feeding";
      case LogType.sleep:
        return "Sleep";
      case LogType.medication:
        return "Medicine";
      case LogType.growth:
        return "Growth";
    }
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _ChartCard({
    required this.title,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121214) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ===== ORIGINAL WIDGETS =====

class _LogButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LogButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  Color mapColor(String title) {
    switch (title) {
      case "Feeding Logs":
        return const Color(0xFF6B6BFF);
      case "Growth Logs":
        return const Color(0xFF4FB783);
      case "Sleeping Logs":
        return const Color(0xFF8E44AD);
      case "Medication Logs":
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFF56587);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = mapColor(title);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.16), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.02)
                : color.withOpacity(0.06),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.8,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.white70 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

class LogTable extends StatelessWidget {
  final List<BabyLog> logs;

  const LogTable({super.key, required this.logs});

  Color tagColor(LogType type) {
    switch (type) {
      case LogType.feeding:
        return const Color(0xFF6B6BFF);
      case LogType.sleep:
        return const Color(0xFF4FB783);
      case LogType.medication:
        return const Color(0xFFE74C3C);
      case LogType.growth:
        return const Color(0xFF8E44AD);
    }
  }

  IconData typeIcon(LogType type) {
    switch (type) {
      case LogType.feeding:
        return Icons.local_drink;
      case LogType.sleep:
        return Icons.bedtime;
      case LogType.medication:
        return Icons.medication_liquid;
      case LogType.growth:
        return Icons.child_care;
    }
  }

  String formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (logDate == today) {
      return DateFormat('hh:mm a').format(timestamp);
    } else if (logDate == yesterday) {
      return "Yesterday\n${DateFormat('hh:mm a').format(timestamp)}";
    } else {
      return DateFormat('MMM d\nhh:mm a').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text("No logs found")),
      );
    }

    return Column(
      children: logs.map((log) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121214) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.45 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tagColor(log.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon(log.type), color: tagColor(log.type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  log.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Text(
                formatTime(log.timestamp),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}