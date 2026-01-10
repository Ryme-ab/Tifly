import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  void _showEnhancedFilterDialog() {
    LogType? tempType = selectedTypes.isNotEmpty ? selectedTypes.first : null;
    DateTime? tempDate = selectedStartDate;
    String? tempTime = selectedTime;

    final cubit = context.read<BabyLogsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    "Filter Logs",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Log Type ChoiceChips
                  Wrap(
                    spacing: 8,
                    children: LogType.values.map((e) {
                      final isSelected = tempType == e;
                      return ChoiceChip(
                        label: Text(e.toString().split('.').last),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => tempType = selected ? e : null);
                        },
                        selectedColor: _tagColor(e).withOpacity(0.2),
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: isSelected ? _tagColor(e) : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Date Picker
                  Row(
                    children: [
                      const Text("Date:"),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => tempDate = picked);
                          }
                        },
                        child: Text(
                          tempDate == null
                              ? "Select Date"
                              : DateFormat('yyyy-MM-dd').format(tempDate!),
                        ),
                      ),
                      if (tempDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => tempDate = null);
                          },
                        ),
                    ],
                  ),

                  // Time Picker
                  Row(
                    children: [
                      const Text("Time:"),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: tempTime != null
                                ? TimeOfDay(
                                    hour: int.parse(tempTime!.split(':')[0]),
                                    minute: int.parse(tempTime!.split(':')[1]),
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
                        child: Text(tempTime ?? "Select Time"),
                      ),
                      if (tempTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => tempTime = null);
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              tempType = null;
                              tempDate = null;
                              tempTime = null;
                            });
                          },
                          child: const Text("Reset"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Update parent state
                            this.setState(() {
                              selectedTypes.clear();
                              if (tempType != null) {
                                selectedTypes.add(tempType!);
                              }
                              selectedStartDate = tempDate;
                              selectedTime = tempTime;
                              isFiltering = tempType != null ||
                                  tempDate != null ||
                                  tempTime != null;
                            });

                            // Apply to cubit
                            cubit.applyFilter(
                              type: tempType,
                              date: tempDate,
                              time: tempTime,
                            );

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B6BFF),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Apply Filter"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, List<BabyLog> logs) {
    bool includeFeeding = true;
    bool includeGrowth = true;
    bool includeSleeping = true;
    bool includeMedication = true;

    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Color(0xFFF56587)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.exportPdf, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.selectBaby}:',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Icon(
                        Icons.local_drink,
                        size: 20,
                        color: Color(0xFF6B6BFF),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.feedingLogs)),
                    ],
                  ),
                  value: includeFeeding,
                  onChanged: (value) =>
                      setState(() => includeFeeding = value ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Icon(
                        Icons.child_care,
                        size: 20,
                        color: Color(0xFF8E44AD),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.growthLogs)),
                    ],
                  ),
                  value: includeGrowth,
                  onChanged: (value) =>
                      setState(() => includeGrowth = value ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Icon(
                        Icons.bedtime,
                        size: 20,
                        color: Color(0xFF4FB783),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.sleepingLogs)),
                    ],
                  ),
                  value: includeSleeping,
                  onChanged: (value) =>
                      setState(() => includeSleeping = value ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Icon(
                        Icons.medication_liquid,
                        size: 20,
                        color: Color(0xFFE74C3C),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.medicationLogs)),
                    ],
                  ),
                  value: includeMedication,
                  onChanged: (value) =>
                      setState(() => includeMedication = value ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: Text(l10n.exportPdf),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF56587),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _generatePdfReport(
                    context,
                    logs,
                    includeFeeding,
                    includeGrowth,
                    includeSleeping,
                    includeMedication,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _generatePdfReport(
    BuildContext context,
    List<BabyLog> logs,
    bool includeFeeding,
    bool includeGrowth,
    bool includeSleeping,
    bool includeMedication,
  ) async {
    try {
      // Show loading
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(l10n.generatingPdf),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      final pdf = pw.Document();

      // Filter logs based on selection
      final filteredLogs = logs.where((log) {
        if (log.type == LogType.feeding && !includeFeeding) return false;
        if (log.type == LogType.growth && !includeGrowth) return false;
        if (log.type == LogType.sleep && !includeSleeping) return false;
        if (log.type == LogType.medication && !includeMedication) return false;
        return true;
      }).toList();

      // Calculate statistics
      final feedingLogs = filteredLogs
          .where((l) => l.type == LogType.feeding)
          .toList();
      final growthLogs = filteredLogs
          .where((l) => l.type == LogType.growth)
          .toList();
      final sleepLogs = filteredLogs
          .where((l) => l.type == LogType.sleep)
          .toList();
      final medicationLogs = filteredLogs
          .where((l) => l.type == LogType.medication)
          .toList();

      // Get child info
      final childState = context.read<ChildSelectionCubit>().state;
      String childName = 'Baby';
      if (childState is ChildSelected) {
        childName = childState.childName;
      }

      // Add page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    l10n.logsAndReports,
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.pink700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '${l10n.child}: $childName',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey800),
                  ),
                  pw.Text(
                    '${l10n.generated}: ${DateFormat('MMMM dd, yyyy hh:mm a').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Summary Statistics
            pw.Text(
              l10n.summaryStatistics,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),

            _buildStatisticsGrid(
              feedingLogs.length,
              growthLogs.length,
              sleepLogs.length,
              medicationLogs.length,
              includeFeeding,
              includeGrowth,
              includeSleeping,
              includeMedication,
            ),

            pw.SizedBox(height: 30),

            // Visual Charts Section
            pw.Text(
              l10n.visualAnalytics,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            _buildChartsForPdf(
              feedingLogs.length,
              growthLogs.length,
              sleepLogs.length,
              medicationLogs.length,
              includeFeeding,
              includeGrowth,
              includeSleeping,
              includeMedication,
            ),
            pw.SizedBox(height: 30),

            // Detailed Logs
            if (includeFeeding && feedingLogs.isNotEmpty) ...[
              _buildLogSection(
                l10n.feedingLogs,
                feedingLogs,
                PdfColors.blue500,
              ),
              pw.SizedBox(height: 20),
            ],

            if (includeGrowth && growthLogs.isNotEmpty) ...[
              _buildLogSection(
                l10n.growthLogs,
                growthLogs,
                PdfColors.purple500,
              ),
              pw.SizedBox(height: 20),
            ],

            if (includeSleeping && sleepLogs.isNotEmpty) ...[
              _buildLogSection(
                l10n.sleepingLogs,
                sleepLogs,
                PdfColors.green500,
              ),
              pw.SizedBox(height: 20),
            ],

            if (includeMedication && medicationLogs.isNotEmpty) ...[
              _buildLogSection(
                l10n.medicationLogs,
                medicationLogs,
                PdfColors.red500,
              ),
            ],
          ],
        ),
      );

      // Show/save PDF
      if (!context.mounted) return;

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            'baby_logs_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.pdfGeneratedSuccessfully),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorGeneratingPdf}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  pw.Widget _buildStatisticsGrid(
    int feedingCount,
    int growthCount,
    int sleepCount,
    int medicationCount,
    bool showFeeding,
    bool showGrowth,
    bool showSleep,
    bool showMedication,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          if (showFeeding)
            _buildStatRow('Feeding Logs', feedingCount, PdfColors.blue500),
          if (showGrowth)
            _buildStatRow('Growth Logs', growthCount, PdfColors.purple500),
          if (showSleep)
            _buildStatRow('Sleeping Logs', sleepCount, PdfColors.green500),
          if (showMedication)
            _buildStatRow('Medication Logs', medicationCount, PdfColors.red500),
        ],
      ),
    );
  }

  pw.Widget _buildStatRow(String label, int count, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Text(
              '$count',
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.white),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLogSection(String title, List<BabyLog> logs, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Date/Time', isHeader: true),
                _buildTableCell('Title', isHeader: true),
                _buildTableCell('Details', isHeader: true),
              ],
            ),
            // Data rows
            ...logs.map(
              (log) => pw.TableRow(
                children: [
                  _buildTableCell(
                    DateFormat('MMM dd, yyyy\nhh:mm a').format(log.timestamp),
                  ),
                  _buildTableCell(log.title),
                  _buildTableCell(log.details),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildChartsForPdf(
    int feedingCount,
    int growthCount,
    int sleepCount,
    int medicationCount,
    bool showFeeding,
    bool showGrowth,
    bool showSleep,
    bool showMedication,
  ) {
    final List<MapEntry<String, int>> data = [];
    if (showFeeding) data.add(MapEntry('Feeding', feedingCount));
    if (showGrowth) data.add(MapEntry('Growth', growthCount));
    if (showSleep) data.add(MapEntry('Sleep', sleepCount));
    if (showMedication) data.add(MapEntry('Medication', medicationCount));

    final maxValue = data.isEmpty
        ? 1
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return pw.Container(
      height: 200,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: data.map((entry) {
          final colors = {
            'Feeding': PdfColors.blue500,
            'Growth': PdfColors.purple500,
            'Sleep': PdfColors.green500,
            'Medication': PdfColors.red500,
          };
          final barHeight = (entry.value / maxValue) * 150;
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                '${entry.value}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                width: 60,
                height: barHeight,
                decoration: pw.BoxDecoration(
                  color: colors[entry.key] ?? PdfColors.grey,
                  borderRadius: const pw.BorderRadius.vertical(
                    top: pw.Radius.circular(8),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.SizedBox(
                width: 60,
                child: pw.Text(
                  entry.key,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        }).toList(),
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
                              : (logs.length > 5
                                    ? logs.take(5).toList()
                                    : logs);
                          final hasMoreLogs = logs.length > 5;

                          return [
                            LogTable(logs: logsToShow),

                            // Show More / Show Less Button
                            if (hasMoreLogs)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Center(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        showAllLogs = !showAllLogs;
                                      });
                                    },
                                    icon: Icon(
                                      showAllLogs
                                          ? Icons.expand_less
                                          : Icons.expand_more,
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
      floatingActionButton: BlocBuilder<BabyLogsCubit, BabyLogsState>(
        builder: (context, state) {
          if (state is BabyLogsLoaded && state.logs.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => _showExportDialog(context, state.logs),
              backgroundColor: const Color(0xFFF56587),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text(
                'Export PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 6,
            );
          }
          return const SizedBox.shrink();
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

  _ImprovedDatePresetChip({
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

  _ImprovedDatePickerButton({
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

  ProfessionalChartsSection({
    super.key,
    required this.logs,
    required this.isDark,
  });

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
                      centerSpaceRadius: 30,
                      sections: logCounts.entries.map((e) {
                        final percentage = (e.value / logs.length * 100)
                            .toStringAsFixed(1);
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          title: '$percentage%',
                          color: _getColor(e.key),
                          radius: 50,
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
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  _ChartCard({required this.title, required this.child, required this.isDark});

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

  _LogButton({required this.icon, required this.title, required this.onTap});

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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

  LogTable({super.key, required this.logs});

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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatTime(log.timestamp),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
