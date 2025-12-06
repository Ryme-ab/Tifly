// lib/profile/baby_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';
import 'package:tifli/core/constants/app_assets.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:intl/intl.dart';
import 'edit_baby_screen.dart';
import 'package:tifli/features/navigation/presentation/screens/drawer.dart';

class BabyProfileScreen extends StatefulWidget {
  final String babyId;
  
  const BabyProfileScreen({super.key, required this.babyId});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  Map<String, dynamic>? _babyData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBabyData();
  }

  Future<void> _fetchBabyData() async {
    try {
      final response = await SupabaseClientManager()
          .client
          .from('children')
          .select()
          .eq('id', widget.babyId)
          .single();
      
      setState(() {
        _babyData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _capitalizeFirst(String? text) {
    if (text == null || text.isEmpty) return 'Unknown';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Baby Profile"),
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Baby Profile"),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading baby data', style: AppFonts.heading2),
              const SizedBox(height: 8),
              Text(_error!, style: AppFonts.small),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchBabyData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final name = _babyData?['first_name'] ?? 'Unknown';
    final dob = _formatDate(_babyData?['birth_date']);
    final gender = _capitalizeFirst(_babyData?['gender']);
    final bloodType = _babyData?['blood_type'] ?? 'Not specified';
    final bornWeight = _babyData?['born_weight']?.toString() ?? 'Not specified';
    final bornHeight = _babyData?['born_height']?.toString() ?? 'Not specified';
    final circum = _babyData?['circum']?.toString() ?? 'Not specified';

    return Scaffold(
      appBar: const CustomAppBar(title: "Baby Profile"),
      backgroundColor: Colors.white,
      drawer: const Tiflidrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // top card with avatar and name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFEFFAFB,
                ), // very light aqua from screenshot
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  // avatar
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: _babyData?['profile_image'] != null
                        ? NetworkImage(_babyData!['profile_image'])
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: _babyData?['profile_image'] == null
                        ? Icon(Icons.child_care, size: 36, color: Colors.grey[400])
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // name & subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppFonts.heading2.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Happy and healthy',
                          style: AppFonts.body.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // edit icon (floating small)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditBabyScreen(babyData: _babyData!),
                          ),
                        );
                        if (result == true) {
                          // Refresh data after edit
                          _fetchBabyData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Basic Information card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Basic Information",
                        style: AppFonts.heading2.copyWith(fontSize: 14),
                      ),
                      IconButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditBabyScreen(babyData: _babyData!),
                            ),
                          );
                          if (result == true) {
                            _fetchBabyData();
                          }
                        },
                        icon: const Icon(Icons.edit, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // row: dob
                  Row(
                    children: [
                      const Icon(Icons.cake, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text("Date of birth", style: AppFonts.small),
                      ),
                      Text(dob, style: AppFonts.body),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // row: gender
                  Row(
                    children: [
                      const Icon(Icons.wc, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Gender", style: AppFonts.small)),
                      Text(gender, style: AppFonts.body),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // row: blood type
                  Row(
                    children: [
                      const Icon(Icons.bloodtype, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Blood Type", style: AppFonts.small)),
                      Text(bloodType, style: AppFonts.body),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Birth Details card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Birth Details",
                        style: AppFonts.heading2.copyWith(fontSize: 14),
                      ),
                      IconButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditBabyScreen(babyData: _babyData!),
                            ),
                          );
                          if (result == true) {
                            _fetchBabyData();
                          }
                        },
                        icon: const Icon(Icons.edit, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.monitor_weight, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Birth Weight", style: AppFonts.small)),
                      Text('$bornWeight kg', style: AppFonts.body),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.height, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Birth Height", style: AppFonts.small)),
                      Text('$bornHeight cm', style: AppFonts.body),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.radio_button_unchecked, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Head Circumference", style: AppFonts.small)),
                      Text('$circum cm', style: AppFonts.body),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Label for edit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Quick Actions',
                style: AppFonts.heading2.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Edit baby details button (full width)
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditBabyScreen(babyData: _babyData!),
                    ),
                  );
                  if (result == true) {
                    _fetchBabyData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.edit, size: 20),
                label: const Text(
                  "Edit baby details",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
