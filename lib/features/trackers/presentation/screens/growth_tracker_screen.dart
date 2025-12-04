import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/widgets/calendar.dart';
import 'package:tifli/features/trackers/presentation/widgets/tracker_button.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/cubit/growth_cubit.dart';

class GrowthPage extends StatefulWidget {
  const GrowthPage({super.key, this.showTracker = true});
  final bool showTracker;
  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
  String? selectedUnit1 = 'kg';
  String? selectedUnit2 = 'cm';
  String? selectedUnit3;
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedChildId = "75ec0c30-58d0-4306-b225-007cd9997b0f";

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    bmiController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _logGrowthData() async {
    // Get current date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Parse values
    final weight = double.tryParse(weightController.text);
    final height = double.tryParse(heightController.text);
    final bmi = double.tryParse(bmiController.text);
    final notes = notesController.text.trim();

    // Validation
    if (weight == null || height == null || bmi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid numeric values for all fields"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notes field cannot be empty!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await context.read<GrowthCubit>().addGrowthLog(
        childId: selectedChildId,
        date: today,
        height: height,
        weight: weight,
        headCircumference: bmi,
        notes: notes,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Growth data logged successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      setState(() {
        weightController.clear();
        heightController.clear();
        bmiController.clear();
        notesController.clear();
      });
    } catch (e) {
      if (e.toString().contains("already exists")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This growth log already exists for today!"),
            backgroundColor: Color.fromARGB(255, 78, 78, 77),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to log growth data."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF5),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Add Trackers',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/parent_placeholder.jpg',
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTracker) ...[
                TrackerButtonsRow(currentPage: 'food'),
                const SizedBox(height: 20),
              ],
              SmallWeekCalendar(),
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
                    _buildMeasurementField(
                      'Weight',
                      selectedUnit1,
                      weightController,
                      (val) => setState(() => selectedUnit1 = val),
                    ),
                    const SizedBox(height: 16),
                    _buildMeasurementField(
                      'Height',
                      selectedUnit2,
                      heightController,
                      (val) => setState(() => selectedUnit2 = val),
                    ),
                    const SizedBox(height: 16),
                    _buildMeasurementField(
                      'BMI',
                      selectedUnit3,
                      bmiController,
                      (val) => setState(() => selectedUnit3 = val),
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
                        onPressed: _logGrowthData,
                        icon: const Icon(Icons.child_care, color: Colors.white),
                        label: const Text(
                          'Log Growth Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA41639),
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

  Widget _buildMeasurementField(
    String label,
    String? selected,
    TextEditingController controller,
    ValueChanged<String?> onChanged,
  ) {
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
                  hintText: 'Enter value',
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
            Flexible(
              flex: 1,
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
                    isExpanded: true,
                    value: selected,
                    items: _getUnitsForLabel(label)
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<String> _getUnitsForLabel(String label) {
    switch (label) {
      case 'Weight':
        return ['kg', 'lb'];
      case 'Height':
        return ['cm', 'in'];
      case 'BMI':
        return ['kg/m²'];
      default:
        return [];
    }
  }
}

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
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const FoodTrackerScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        TrackerButton(
          icon: Icons.nightlight_round,
          borderColor: Colors.blue,
          activeColor: Colors.blue,
          isActive: currentPage == 'sleep',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SleepPage()),
            );
          },
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
