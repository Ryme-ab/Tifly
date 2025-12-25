import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/schedules/presentation/screens/add_medicine_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/logs/presentation/cubit/medication_log_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/medication_log_state.dart';
import 'package:tifli/features/logs/data/models/medication_log_model.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
// For test child ID

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load medications data when screen is initialized
    // Using test child ID - replace with actual child ID in production
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationLogCubit>().loadMedicines();
    });
  }

  Future<void> _exportMedicationLogsPDF(BuildContext context) async {
    final state = context.read<MedicationLogCubit>().state;
    if (state is! MedicationLoaded) return;

    final logs = state.medicines;
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No medication logs to export')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final childState = context.read<ChildSelectionCubit>().state;
      String childName = 'Baby';
      if (childState is ChildSelected) {
        childName = childState.childName;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Medication Logs Report', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                  pw.SizedBox(height: 8),
                  pw.Text('Child: $childName', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey800)),
                  pw.Text('Generated: ${DateFormat('MMMM dd, yyyy hh:mm a').format(DateTime.now())}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total Logs: ${logs.length}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Date', 'Medicine', 'Doctor', 'Dose', 'Notes'],
              data: logs.map((log) {
                return [
                  DateFormat('MMM dd, yyyy').format(log.createdAt),
                  log.medicineName,
                  '-',
                  log.dosage.toString(),
                  log.notes?.isEmpty ?? true ? '-' : log.notes!,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.red500),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'medication_logs_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: "Medication Tracker",
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFE74C3C)),
            onPressed: () => _exportMedicationLogsPDF(context),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<MedicationLogCubit, MedicationState>(
          builder: (context, state) {
            if (state is MedicationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MedicationError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is MedicationLoaded) {
              final medicines = state.medicines;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Medications",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: const AssetImage("assets/profile.jpg"),
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Medicines list
                  if (medicines.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No medications yet'),
                      ),
                    )
                  else
                    ...medicines.map((med) => _medicationCard(med, context)),

                  const SizedBox(height: 20),

                  // Summary chart
                  if (medicines.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Medication Summary",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _miniBarChart(medicines),
                        ],
                      ),
                    ),
                ],
              );
            }

            return const Center(child: Text('No data'));
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MedicineApp()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _medicationCard(Medication med, BuildContext context) {
    IconData icon = Icons.medication;

    // Customize icon by medicine name
    final nameLower = med.medicineName.toLowerCase();
    if (nameLower.contains('vitamin')) {
      icon = Icons.medication_liquid;
    } else if (nameLower.contains('spray')) {
      icon = Icons.healing;
    } else if (nameLower.contains('vaccine')) {
      icon = Icons.vaccines;
    }

    final colors = [
      const Color(0xffe8f3ff),
      const Color(0xfffff0f0),
      const Color(0xfffff9e5),
      const Color(0xfff0eaff),
    ];
    final color = colors[med.medicineName.hashCode % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(med.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xffb03a57),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          context.read<MedicationLogCubit>().deleteMedication(med.id);
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xffb03a57)),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.medicineName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (med.timeOfMedication != null)
                      Text(
                        DateFormat(
                          'hh:mm a',
                        ).format(DateTime.parse(med.timeOfMedication!)),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    if (med.notes != null && med.notes!.isNotEmpty)
                      Text(
                        med.notes!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  // Edit action
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniBarChart(List<Medication> medicines) {
    final medCounts = <String, int>{};

    for (final med in medicines) {
      String shortName = med.medicineName;
      if (shortName.length > 8) shortName = shortName.substring(0, 8);
      medCounts[shortName] = (medCounts[shortName] ?? 0) + 1;
    }

    final barData = medCounts.entries.take(5).toList();

    if (barData.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No data to display')),
      );
    }

    final colors = [
      const Color(0xffe3f2fd),
      const Color(0xffffcdd2),
      const Color(0xfffff9c4),
      const Color(0xfff0eaff),
      const Color(0xffe0f7fa),
    ];

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= barData.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      barData[index].key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(barData.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: barData[i].value.toDouble(),
                  color: colors[i % colors.length],
                  width: 30,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
