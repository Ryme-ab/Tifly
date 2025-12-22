import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromCubit();
    });
  }

  void _initializeFromCubit() {
    final cubit = context.read<ChildSelectionCubit>();
    // listen for child selection changes to reload logs
    cubit.stream.listen(_handleChildSelectionState);
    _handleChildSelectionState(cubit.state);
  }

  void _handleChildSelectionState(ChildSelectionState state) {
    if (!mounted) return;
    if (state is ChildSelected) {
      context.read<BabyLogsCubit>().loadAllLogs(state.childId);
    }
  }

  void _showExportDialog(BuildContext context, List<BabyLog> logs) {
    bool includeFeeding = true;
    bool includeGrowth = true;
    bool includeSleeping = true;
    bool includeMedication = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Color(0xFFF56587)),
                SizedBox(width: 12),
                Text('Export PDF Report'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select which logs to include:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.local_drink, size: 20, color: Color(0xFF6B6BFF)),
                      SizedBox(width: 8),
                      Text('Feeding Logs'),
                    ],
                  ),
                  value: includeFeeding,
                  onChanged: (value) => setState(() => includeFeeding = value ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.child_care, size: 20, color: Color(0xFF8E44AD)),
                      SizedBox(width: 8),
                      Text('Growth Logs'),
                    ],
                  ),
                  value: includeGrowth,
                  onChanged: (value) => setState(() => includeGrowth = value ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.bedtime, size: 20, color: Color(0xFF4FB783)),
                      SizedBox(width: 8),
                      Text('Sleeping Logs'),
                    ],
                  ),
                  value: includeSleeping,
                  onChanged: (value) => setState(() => includeSleeping = value ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.medication_liquid, size: 20, color: Color(0xFFE74C3C)),
                      SizedBox(width: 8),
                      Text('Medication Logs'),
                    ],
                  ),
                  value: includeMedication,
                  onChanged: (value) => setState(() => includeMedication = value ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export PDF'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Generating PDF...'),
            ],
          ),
          duration: Duration(seconds: 2),
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
      final feedingLogs = filteredLogs.where((l) => l.type == LogType.feeding).toList();
      final growthLogs = filteredLogs.where((l) => l.type == LogType.growth).toList();
      final sleepLogs = filteredLogs.where((l) => l.type == LogType.sleep).toList();
      final medicationLogs = filteredLogs.where((l) => l.type == LogType.medication).toList();

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
                    'Baby Logs Report',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.pink700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Child: $childName',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey800),
                  ),
                  pw.Text(
                    'Generated: ${DateFormat('MMMM dd, yyyy hh:mm a').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Summary Statistics
            pw.Text(
              'Summary Statistics',
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

            // Detailed Logs
            if (includeFeeding && feedingLogs.isNotEmpty) ...[
              _buildLogSection('Feeding Logs', feedingLogs, PdfColors.blue500),
              pw.SizedBox(height: 20),
            ],

            if (includeGrowth && growthLogs.isNotEmpty) ...[
              _buildLogSection('Growth Logs', growthLogs, PdfColors.purple500),
              pw.SizedBox(height: 20),
            ],

            if (includeSleeping && sleepLogs.isNotEmpty) ...[
              _buildLogSection('Sleeping Logs', sleepLogs, PdfColors.green500),
              pw.SizedBox(height: 20),
            ],

            if (includeMedication && medicationLogs.isNotEmpty) ...[
              _buildLogSection('Medication Logs', medicationLogs, PdfColors.red500),
            ],
          ],
        ),
      );

      // Show/save PDF
      if (!context.mounted) return;
      
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'baby_logs_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('PDF generated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
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
              style: const pw.TextStyle(
                fontSize: 14,
                color: PdfColors.white,
              ),
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
            ...logs.map((log) => pw.TableRow(
              children: [
                _buildTableCell(
                  DateFormat('MMM dd, yyyy\nhh:mm a').format(log.timestamp),
                ),
                _buildTableCell(log.title),
                _buildTableCell(log.details),
              ],
            )),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1113) : const Color(0xFFF6F4F8);
    final panelColor = isDark ? const Color(0xFF121214) : Colors.white;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(title: l10n.logsAndReports),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Top action buttons - modernized and colorful
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

                  const SizedBox(height: 18),

                  // Activity Logs panel
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // header row with title and quick filters (visual only)
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    l10n.activityLogs,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : const Color(0xFFF3F6F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.recent,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        BlocBuilder<BabyLogsCubit, BabyLogsState>(
                          builder: (context, state) {
                            if (state is BabyLogsLoading) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 28,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      isDark
                                          ? Colors.white
                                          : const Color(0xFF6B6BFF),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is BabyLogsError) {
                              return Padding(
                                padding: const EdgeInsets.all(28.0),
                                child: Center(
                                  child: Text(
                                    "Error: ${state.message}",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is BabyLogsLoaded) {
                              return LogTable(logs: state.logs);
                            }

                            final selectionState = context
                                .watch<ChildSelectionCubit>()
                                .state;

                            if (selectionState is NoChildSelected) {
                              return const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: Text(
                                    "Please select a baby from the drawer.",
                                  ),
                                ),
                              );
                            }

                            return const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: Text("Select a baby to view logs."),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.description_outlined, size: 20),
          label: const Text("Generate Report"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF56587),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            elevation: 6,
          ),
          onPressed: () {
            final state = context.read<BabyLogsCubit>().state;
            if (state is BabyLogsLoaded) {
              _showExportDialog(context, state.logs);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please wait for logs to load'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

/* -----------------------------------------
   _LogButton - modernized and color-coded
   ----------------------------------------- */
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

/* -----------------------------------------
   LogTable - modern cards with colors/icons
   ----------------------------------------- */
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

  String typeName(LogType type) {
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
        child: Center(child: Text("No activity logs yet")),
      );
    }

    return Column(
      children: logs.map((log) {
        final color = tagColor(log.type);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark ? const Color(0xFF0F1113) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(isDark ? 0.06 : 0.03),
              width: 0.6,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // colored vertical indicator
              Container(
                width: 6,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 12),

              // Icon + details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // icon badge
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(typeIcon(log.type), size: 20, color: color),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeName(log.type),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      log.details,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // TIME
              SizedBox(
                width: 78,
                child: Text(
                  formatTime(log.timestamp),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
