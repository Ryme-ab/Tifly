// lib/profile/parent_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';
import 'package:tifli/core/constants/app_assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/config/supabaseClient.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../../data/data_sources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  // === Account Preferences ===
  bool enableNotifications = true;
  bool dailySummaryEmails = false;
  bool shareActivityData = true;
  bool darkMode = false;

  // ✅ EMPTY Controllers (NO FAKE DATA)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // === Edit States ===
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  String? _profileImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseClientManager().client;
    final String? currentUserId = supabase.auth.currentUser?.id;
    // For development fallback to a fixed id if no authenticated user is present
    final userId = currentUserId ?? '8c608294-5431-41b0-9ddc-d9cedaf5d109';

    return BlocProvider(
      create: (_) {
        final repo = ProfileRepository(ProfileRemoteDataSource(supabase));
        final cubit = ProfileCubit(repository: repo);

        cubit.loadProfile(userId);

        return cubit;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: "Parent Profile"),
        backgroundColor: AppColors.backgroundLight,

        // ✅ PROPER STATE REBUILD
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              final profile = state.profile;
              _nameController.text = profile.fullName ?? '';
              _emailController.text = profile.email ?? '';
              _phoneController.text = profile.phone ?? '';
              _profileImageUrl = profile.profileImage;
            } else if (state is ProfileUpdated) {
              final profile = state.profile;
              _nameController.text = profile.fullName ?? '';
              _emailController.text = profile.email ?? '';
              _phoneController.text = profile.phone ?? '';
              _profileImageUrl = profile.profileImage;
            }

            if (state is ProfileError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // === Profile Header ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.surfaceLight,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!) as ImageProvider
                              : const AssetImage(AppAssets.babyMom),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _nameController.text,
                          style: AppFonts.heading2.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _emailController.text,
                          style: AppFonts.small.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // === Personal Information ===
                  _buildSectionTitle("Personal Information"),
                  const SizedBox(height: 8),

                  _buildEditableField(
                    "Full Name",
                    _nameController,
                    _isEditingName,
                    onEditTap: () =>
                        setState(() => _isEditingName = !_isEditingName),
                  ),

                  _buildEditableField(
                    "Email Address",
                    _emailController,
                    _isEditingEmail,
                    onEditTap: () =>
                        setState(() => _isEditingEmail = !_isEditingEmail),
                  ),

                  _buildEditableField(
                    "Phone Number",
                    _phoneController,
                    _isEditingPhone,
                    onEditTap: () =>
                        setState(() => _isEditingPhone = !_isEditingPhone),
                  ),

                  const SizedBox(height: 20),

                  // === Account Preferences ===
                  _buildSectionTitle("Account Preferences"),
                  const SizedBox(height: 8),

                  _buildToggle(
                    "Enable Notifications",
                    enableNotifications,
                    (val) => setState(() => enableNotifications = val),
                  ),

                  _buildToggle(
                    "Daily Summary Emails",
                    dailySummaryEmails,
                    (val) => setState(() => dailySummaryEmails = val),
                  ),

                  _buildToggle(
                    "Share Activity Data",
                    shareActivityData,
                    (val) => setState(() => shareActivityData = val),
                  ),

                  _buildToggle(
                    "Dark Mode (Coming Soon)",
                    darkMode,
                    (val) => setState(() => darkMode = val),
                    enabled: false,
                  ),

                  const SizedBox(height: 24),

                  // === Save Changes Button ===
                  ElevatedButton(
                    onPressed: state is ProfileLoading
                        ? null
                        : () {
                            if (currentUserId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User not logged in'),
                                ),
                              );
                              return;
                            }

                            final data = {
                              'full_name': _nameController.text.trim(),
                              'email': _emailController.text.trim(),
                              'phone': _phoneController.text.trim(),
                            };

                            context.read<ProfileCubit>().updateProfile(
                              userId,
                              data,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surfaceLight,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: state is ProfileLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Save Changes",
                            style: AppFonts.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.surfaceLight,
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),

                  // === Logout Button ===
                  ElevatedButton(
                    onPressed: () async {
                      await supabase.auth.signOut();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // === Helper Widgets ===

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppFonts.heading2.copyWith(
          fontSize: 16,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isEditing, {
    required VoidCallback onEditTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: !isEditing,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppFonts.small.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isEditing ? Icons.check_circle : Icons.edit,
              color: isEditing ? AppColors.success : AppColors.iconLight,
            ),
            onPressed: onEditTap,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: AppColors.surfaceLight,
        ),
        style: AppFonts.body.copyWith(
          fontSize: 15,
          color: AppColors.textPrimaryLight,
        ),
        cursorColor: AppColors.primary,
      ),
    );
  }

  Widget _buildToggle(
    String title,
    bool value,
    Function(bool) onChanged, {
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppFonts.body),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
