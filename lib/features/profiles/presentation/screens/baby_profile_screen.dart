// lib/profile/baby_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';
import 'package:tifli/core/constants/app_assets.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/profiles/data/models/child_model.dart';
import 'package:tifli/features/profiles/presentation/cubit/children_cubit.dart';
import 'package:tifli/features/profiles/presentation/screens/edit_baby_screen.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';
import 'package:intl/intl.dart';

class BabyProfileScreen extends StatefulWidget {
  final ChildModel? childData;

  const BabyProfileScreen({super.key, this.childData});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  late ChildModel? currentChildData;

  @override
  void initState() {
    super.initState();
    currentChildData = widget.childData;
  }

  Future<void> _navigateToEdit() async {
    if (currentChildData == null) return;

    // Get the ChildrenCubit to pass to the edit screen
    final childrenCubit = context.read<ChildrenCubit>();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: childrenCubit,
          child: Provider<AppBarConfig>(
            create: (_) => AppBarConfig(title: 'Edit Baby Profile'),
            child: EditBabyScreen(childData: currentChildData!),
          ),
        ),
      ),
    );

    // Reload data if edit was successful
    if (result == true && mounted) {
      final userId = UserContext.getCurrentUserId();
      if (userId != null) {
        await context.read<ChildrenCubit>().loadChildren(userId);
        // Get updated child data
        final state = context.read<ChildrenCubit>().state;
        if (state is ChildrenLoaded) {
          final updatedChild = state.children.firstWhere(
            (child) => child.id == currentChildData!.id,
            orElse: () => currentChildData!,
          );
          setState(() {
            currentChildData = updatedChild;
          });
        }
      }
    }
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    final months = now.month - birthDate.month;

    if (age < 1) {
      final totalMonths = (now.year - birthDate.year) * 12 + months;
      return '$totalMonths months';
    } else if (months < 0 || (months == 0 && now.day < birthDate.day)) {
      return '${age - 1} years old';
    }
    return '$age years old';
  }

  @override
  Widget build(BuildContext context) {
    // Use current data or fallback to sample data
    final String name = currentChildData?.firstName ?? "islam";
    final String subtitle = currentChildData != null
        ? _calculateAge(currentChildData!.birthDate)
        : "happy and healthy";
    final String dob = currentChildData != null
        ? DateFormat('MMMM dd, yyyy').format(currentChildData!.birthDate)
        : "October 15, 2023";
    final String gender = currentChildData?.gender ?? "Female";
    final String? profileImage = currentChildData?.profileImage;
    final String notes =
        "${currentChildData?.firstName ?? 'Baby'} loves bright colors and giggles when seeing favorite toys. Recently started trying solid foods. No known allergies.";

    return Scaffold(
      appBar: const CustomAppBar(title: "Baby Profile"),
      backgroundColor: Colors.white,
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
                    backgroundImage: profileImage != null
                        ? NetworkImage(profileImage)
                        : AssetImage(AppAssets.baby1) as ImageProvider,
                    backgroundColor: Colors.grey[100],
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
                          subtitle,
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
                      onPressed: currentChildData != null
                          ? _navigateToEdit
                          : null,
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
                        onPressed: currentChildData != null
                            ? _navigateToEdit
                            : null,
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Additional notes card (yellow background)
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
                        "Additional notes",
                        style: AppFonts.heading2.copyWith(fontSize: 14),
                      ),
                      IconButton(
                        onPressed: currentChildData != null
                            ? _navigateToEdit
                            : null,
                        icon: const Icon(Icons.edit, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(notes, style: AppFonts.body.copyWith(fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Edit baby details button (full width)
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: currentChildData != null ? _navigateToEdit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
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
