import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'add_baby_profile_pic.dart'; // ✅ IMPORT PICTURE PAGE
import 'package:tifli/features/profiles/data/models/baby_model.dart';

class AddBabyPage2 extends StatelessWidget {
  final String babyId;
  const AddBabyPage2({super.key, required this.babyId});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFBE185D);
    const backgroundLight = Color(0xFFF8FAFC);
    const backgroundDark = Color(0xFF1E293B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          background: backgroundLight,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          background: backgroundDark,
        ),
      ),
      home: AddBabyScreen(babyId: babyId),
    );
  }
}

class AddBabyScreen extends StatefulWidget {
  final String babyId;
  const AddBabyScreen({super.key, required this.babyId});

  @override
  State<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends State<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _circmController = TextEditingController();
  final _bornWeightController = TextEditingController();
  final _bornHeightController = TextEditingController();
  final _bloodController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFFBE185D);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SizedBox(width: 32),
                  Text(
                    "Add Baby",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  CircleAvatar(radius: 16, backgroundColor: Colors.grey),
                ],
              ),
            ),

            // FORM
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
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Baby Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          "Head Circumference (cm)",
                          "Example: 34",
                          _circmController,
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          "Birth Weight (kg)",
                          "Example: 3.1",
                          _bornWeightController,
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          "Birth Height (cm)",
                          "Example: 48",
                          _bornHeightController,
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          "Blood Type",
                          "A / B / AB / O",
                          _bloodController,
                          isDark,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ✅ SAVE BUTTON WITH REDIRECT
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final response = await SupabaseClientManager().client
                          .from('children')
                          .update({
                            "circum": double.parse(_circmController.text),
                            "born_weight": double.parse(
                              _bornWeightController.text,
                            ),
                            "born_height": double.parse(
                              _bornHeightController.text,
                            ),
                            "blood_type": _bloodController.text,
                          })
                          .eq('id', widget.babyId)
                          .select();

                      if (response.isEmpty) throw Exception("Update failed");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Baby details saved successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // ✅ CLEAR FIELDS
                      _circmController.clear();
                      _bornWeightController.clear();
                      _bornHeightController.clear();
                      _bloodController.clear();

                      // ✅ REDIRECT TO PICTURE PAGE
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddBabyProfilePictureScreen(
                            baby: Baby(
                              id: widget.babyId,
                              firstName: '',
                              birthDate: '',
                              gender: '',
                              parentId: '',
                            ),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "Save Baby",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController c,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: c,
          validator: (v) => v!.isEmpty ? "Required" : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
