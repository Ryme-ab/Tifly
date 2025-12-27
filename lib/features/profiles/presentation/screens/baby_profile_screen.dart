// lib/profile/baby_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';
import 'package:tifli/core/config/supabase_client.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'edit_baby_screen.dart';
import 'package:tifli/features/navigation/presentation/screens/drawer.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';

class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

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
      _fetchBabyData(state.childId);
    } else if (state is NoChildSelected) {
      setState(() {
        _babyData = null;
        _isLoading = false;
        _error = "No baby selected. Please select a baby from the drawer.";
      });
    }
  }

  Future<void> _fetchBabyData(String babyId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await SupabaseClientManager().client
          .from('children')
          .select()
          .eq('id', babyId)
          .single();

      if (mounted) {
        setState(() {
          _babyData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ---------- UI Helpers ----------
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

  // ---------- MAIN BUILD ----------
  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Provider.value(
      value: scaffoldKey,
      child: _buildPage(context, scaffoldKey),
    );
  }

  // ---------- PAGE CONTENT ----------
  Widget _buildPage(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    if (_isLoading) {
      return Scaffold(
        key: scaffoldKey,
        drawer: const Tiflidrawer(),
        appBar: const CustomAppBar(title: "Baby Profile"),
        backgroundColor:   AppColors.backgroundLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        key: scaffoldKey,
        drawer: const Tiflidrawer(),
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
                  final state = context.read<ChildSelectionCubit>().state;
                  if (state is ChildSelected) {
                    _fetchBabyData(state.childId);
                  } else {
                    setState(() {
                      _isLoading = false;
                      _error =
                          "No baby selected. Please select a baby from the drawer.";
                    });
                  }
                },
                child: const Text('Retry'),
              ),
              if (_error ==
                  "No baby selected. Please select a baby from the drawer.") ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    scaffoldKey.currentState!.openDrawer();
                  },
                  child: const Text('Open Drawer'),
                ),
              ],
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
      key: scaffoldKey,
      drawer: const Tiflidrawer(),
      appBar: const CustomAppBar(title: "Baby Profile"),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PROFILE IMAGE & NAME CENTERED
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _babyData?['profile_image'] != null
                          ? NetworkImage(_babyData!['profile_image'])
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: _babyData?['profile_image'] == null
                          ? Icon(
                              Icons.child_care,
                              size: 50,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: AppFonts.heading2.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_calculateAge(_babyData?['birth_date'] ?? '')} ',
                    style: AppFonts.body.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // UNIFIED DETAILS CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailTile(Icons.cake, "Date of Birth", dob),
                  _buildDivider(),
                  _buildDetailTile(Icons.wc, "Gender", gender),
                  _buildDivider(),
                  _buildDetailTile(Icons.bloodtype, "Blood Type", bloodType),
                  _buildDivider(),
                  _buildDetailTile(
                    Icons.monitor_weight,
                    "Birth Weight",
                    "$bornWeight kg",
                  ),
                  _buildDivider(),
                  _buildDetailTile(
                    Icons.height,
                    "Birth Height",
                    "$bornHeight cm",
                  ),
                  _buildDivider(),
                  _buildDetailTile(
                    Icons.circle_outlined,
                    "Head Circumference",
                    "$circum cm",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // EDIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditBabyScreen(babyData: _babyData!),
                    ),
                  );
                  if (result == true && _babyData != null) {
                    _fetchBabyData(_babyData!['id']);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.08),
      indent: 20,
      endIndent: 20,
    );
  }

  String _calculateAge(String dobString) {
    if (dobString.isEmpty) return 'Unknown age';
    try {
      // Assuming dobString is in a parseable format (e.g. "MMMM dd, yyyy" from _formatDate,
      // but better to use original ISO string.
      // However _formatDate returns formatted string.
      // Let's re-parse from _babyData directly if possible or parse the formatted string if we trust format.
      // Better conceptual approach: Pass the raw ISO string to this helper.

      // Let's use _babyData directly in the build method, but here we can try to parse.
      // If we passed the formatted string "MMMM dd, yyyy", we can parse that back.
      // But let's assume we pass the raw string to this function in updated build call?
      // Wait, in build we passed `dob` which is formatted.
      // Strategy: Let's parse the original `_babyData['birth_date']` in build and pass result here.
      // Actually, let's just use _babyData['birth_date'] inside this function if available,
      // or change call site.

      // Simpler: Let's make this function take DateTime or ISO string.
      // But for this patch, let's fix the call site in next step.
      // For now, I will write generic logic that takes ISO string.

      final dob = DateTime.parse(dobString);
      final now = DateTime.now();

      int years = now.year - dob.year;
      int months = now.month - dob.month;
      int days = now.day - dob.day;

      if (months < 0 || (months == 0 && days < 0)) {
        years--;
        months += 12;
      }
      if (days < 0) {
        months--;
        final previousMonth = DateTime(now.year, now.month, 0);
        days += previousMonth.day;
      }

      if (years > 0) {
        return '$years ${years == 1 ? "year" : "years"} old';
      } else if (months > 0) {
        return '$months ${months == 1 ? "month" : "months"} old';
      } else {
        return '$days ${days == 1 ? "day" : "days"} old';
      }
    } catch (e) {
      return 'Unknown age';
    }
  }
}
