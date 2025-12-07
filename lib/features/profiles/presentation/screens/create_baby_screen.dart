import 'package:flutter/material.dart';

import 'package:tifli/core/config/supabaseClient.dart';
import 'create_baby_screen_2.dart';

import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/navigation/presentation/screens/main_tab_screen.dart';

class AddBabyPage extends StatelessWidget {
  const AddBabyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddBabyScreen();
  }
}

class AddBabyScreen extends StatefulWidget {
  const AddBabyScreen({super.key});

  @override
  State<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends State<AddBabyScreen> {
  bool isBoy = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _birthController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFFBE185D);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Add Baby",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainTabScreen()),
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header removed (replaced by AppBar)

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Baby Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Provide essential information about your little one.",
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextFormField(
                          label: "Baby's Name",
                          hint: "E.g., Luna, Leo",
                          controller: _nameController,
                          isDark: isDark,
                          validator: (v) =>
                              v!.isEmpty ? "Please enter baby's name" : null,
                        ),
                        const SizedBox(height: 20),

                        _buildDatePickerField(
                          label: "Birth Date",
                          hint: "Select birth date",
                          controller: _birthController,
                          isDark: isDark,
                          onTap: () => _selectDate(context),
                          validator: (v) =>
                              v!.isEmpty ? "Please select birth date" : null,
                        ),
                        const SizedBox(height: 20),

                        _buildNumericFormField(
                          label: "Baby's Height",
                          hint: "E.g., 30 cm",
                          controller: _heightController,
                          isDark: isDark,
                          validator: (v) {
                            if (v!.isEmpty) return "Please enter height";
                            if (!_isNumeric(v)) {
                              return "Please enter numbers only";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildNumericFormField(
                          label: "Baby's Weight",
                          hint: "E.g., 3.5 kg",
                          controller: _weightController,
                          isDark: isDark,
                          validator: (v) {
                            if (v!.isEmpty) return "Please enter weight";
                            if (!_isNumeric(v)) {
                              return "Please enter numbers only";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        Text(
                          "Gender",
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[300]
                                : Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() => isBoy = true),
                                icon: const Icon(Icons.child_care, size: 18),
                                label: const Text("Boy"),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: isBoy
                                      ? Colors.cyan[700]
                                      : Colors.cyan[300],
                                  backgroundColor: isBoy
                                      ? Colors.cyan[100]
                                      : (isDark
                                            ? Colors.cyan[900]!.withOpacity(0.4)
                                            : Colors.grey[100]),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() => isBoy = false),
                                icon: const Icon(Icons.face_3, size: 18),
                                label: const Text("Girl"),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: !isBoy
                                      ? primaryColor
                                      : Colors.pink.shade300,
                                  backgroundColor: !isBoy
                                      ? const Color(0xFFFFE4E9)
                                      : (isDark
                                            ? Colors.pink.shade900.withOpacity(
                                                0.4,
                                              )
                                            : Colors.grey[100]),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null) {
                    try {
                      final currentUser =
                          SupabaseClientManager().client.auth.currentUser;
                      if (currentUser == null) {
                        throw Exception("User not logged in");
                      }
                      final userId = currentUser.id;
                      final babyData = {
                        'first_name': _nameController.text,
                        'birth_date': _selectedDate!.toIso8601String(),
                        'gender': isBoy ? 'male' : 'female',
                        'parent_id': userId,
                        'born_height': int.parse(_heightController.text),
                        'born_weight': int.parse(_weightController.text),
                      };

                      final insertedRows = await SupabaseClientManager().client
                          .from('children')
                          .insert([babyData])
                          .select();

                      if (insertedRows.isEmpty) {
                        throw Exception("Failed to insert baby");
                      }

                      final babyId = insertedRows[0]['id'];

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Baby added successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddBabyPage2(babyId: babyId),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error adding baby: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DATE PICKER
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  bool _isNumeric(String str) => RegExp(r'^\d*\.?\d*$').hasMatch(str);

  // REUSABLE FIELDS
  Widget _buildTextFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              validator: validator,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: isDark ? Colors.grey[500] : Colors.grey.shade500,
                ),
                hintText: hint,
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
