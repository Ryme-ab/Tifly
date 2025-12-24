// lib/features/trackers/presentation/screens/growth_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/widgets/calendar.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/features/trackers/presentation/widgets/tracker_button.dart';
import 'package:tifli/features/trackers/presentation/cubit/growth_cubit.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';
import 'package:tifli/features/navigation/app_router.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class GrowthPage extends StatefulWidget {
  final bool showTracker;
  final GrowthLog? existingLog;

  const GrowthPage({super.key, this.showTracker = true, this.existingLog});

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
  String? selectedUnitWeight = 'kg';
  String? selectedUnitHeight = 'cm';
  String? selectedUnitHeadCircumference = 'cm';

  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController headCircumferenceController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final Color primary = const Color(0xFFA41639);

  @override
  void initState() {
    super.initState();

    // Prefill if editing
    if (widget.existingLog != null) {
      final e = widget.existingLog!;
      weightController.text = e.weight.toString();
      heightController.text = e.height.toString();
      headCircumferenceController.text = e.headCircumference.toString();
      notesController.text = e.notes ?? '';
      _selectedDate = e.date;
      // units keep defaults (kg/cm), change if you store units in model
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    headCircumferenceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final weight = double.tryParse(weightController.text.trim());
    final height = double.tryParse(heightController.text.trim());
    final headCircumference = double.tryParse(
      headCircumferenceController.text.trim(),
    );
    final notes = notesController.text.trim();

    if (weight == null || height == null || headCircumference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid numeric values for weight, height and head circumference.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ensure a child is selected
    final childState = context.read<ChildSelectionCubit>().state;
    if (childState is! ChildSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a baby first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final childId = childState.childId;

    try {
      if (widget.existingLog != null) {
        // EDIT MODE - create updated object and call cubit update
        final existing = widget.existingLog!;
        final updated = existing.copyWith(
          date: _selectedDate,
          height: height,
          weight: weight,
          headCircumference: headCircumference,
          notes: notes.isEmpty ? existing.notes : notes,
          // keep createdAt as existing.createdAt
        );

        await context.read<GrowthCubit>().updateGrowthLog(updated);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Growth log updated'),
            backgroundColor: Colors.green,
          ),
        );

        // return updated log to previous screen (optional)
        Navigator.of(context).pop(updated);
      } else {
        // CREATE MODE - call cubit add
        await context.read<GrowthCubit>().addGrowthLog(
          childId: childId,
          date: _selectedDate,
          height: height,
          weight: weight,
          headCircumference: headCircumference,
          notes: notes.isEmpty ? null : notes,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Growth data logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // After creating, go back to growth logs list
        Navigator.pushReplacementNamed(context, AppRoutes.growthLogs);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $msg'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMeasurementField({
    required String label,
    required String? selectedUnit,
    required TextEditingController controller,
    required ValueChanged<String?> onUnitChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Flexible(
              flex: 3,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter $label',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80, 
              height: 50,
              child: InputDecorator(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedUnit,
                    items: _unitsForLabel(label)
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: onUnitChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<String> _unitsForLabel(String label) {
    switch (label) {
      case 'Weight':
        return ['kg', 'lb'];
      case 'Height':
        return ['cm', 'in'];
      case 'Head Circumference':
        return ['cm', 'in'];
      default:
        return [''];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF5),
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: widget.existingLog != null
            ? 'Edit Growth Log'
            : 'Add Growth Data',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTracker) ...[
                TrackerButtonsRow(currentPage: 'growth'),
                const SizedBox(height: 20),
              ],
              SmallWeekCalendar(
                selectedDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weight
                    _buildMeasurementField(
                      label: 'Weight',
                      selectedUnit: selectedUnitWeight,
                      controller: weightController,
                      onUnitChanged: (v) =>
                          setState(() => selectedUnitWeight = v),
                    ),
                    const SizedBox(height: 16),

                    // Height
                    _buildMeasurementField(
                      label: 'Height',
                      selectedUnit: selectedUnitHeight,
                      controller: heightController,
                      onUnitChanged: (v) =>
                          setState(() => selectedUnitHeight = v),
                    ),
                    const SizedBox(height: 16),

                    // Head Circumference field
                    _buildMeasurementField(
                      label: 'Head Circumference',
                      selectedUnit: selectedUnitHeadCircumference,
                      controller: headCircumferenceController,
                      onUnitChanged: (v) =>
                          setState(() => selectedUnitHeadCircumference = v),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Notes',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.child_care, color: Colors.white),
                        label: Text(
                          widget.existingLog != null
                              ? 'Update Growth Data'
                              : 'Log Growth Data',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
} // Minimal TrackerButtonsRow - you already had this in your original file; included for completeness

class TrackerButtonsRow extends StatelessWidget {
  final String currentPage;
  const TrackerButtonsRow({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TrackerButton(
          icon: Icons.water_drop,
          borderColor: const Color.fromARGB(255, 61, 61, 59),
          activeColor: const Color.fromARGB(255, 56, 55, 54),
          isActive: currentPage == 'food',
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FoodTrackerScreen()),
          ),
        ),
        const SizedBox(width: 20),
        TrackerButton(
          icon: Icons.nightlight_round,
          borderColor: Colors.blue,
          activeColor: Colors.blue,
          isActive: currentPage == 'sleep',
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SleepPage()),
          ),
        ),
        const SizedBox(width: 20),
        TrackerButton(
          icon: Icons.child_care,
          borderColor: Colors.green,
          activeColor: Colors.green,
          isActive: currentPage == 'growth',
          onTap: () {},
        ),
      ],
    );
  }
}
