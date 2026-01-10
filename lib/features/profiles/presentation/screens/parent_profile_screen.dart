// lib/profile/parent_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/profiles/presentation/cubit/profiles_cubit.dart';
import 'package:tifli/features/profiles/presentation/cubit/profiles_state.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/core/constants/app_assets.dart';
import 'package:tifli/features/navigation/app_router.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  // === User Data Controllers ===
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // === Edit State ===
  // Global edit mode for simpler UX
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Load profile on start
    context.read<ProfilesCubit>().loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _enableEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit(ProfilesLoaded state) {
    setState(() {
      _isEditing = false;
      // Revert changes
      _nameController.text = state.profile.fullName;
      _emailController.text = state.profile.email;
      _phoneController.text = state.profile.phone;
    });
  }

  void _saveProfile() {
    context.read<ProfilesCubit>().updateProfile(
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Theme shortcuts
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: "Parent Profile",
        actions: [
          // Edit/Save toggle in AppBar OR we can keep it in body
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: theme.appBarTheme.iconTheme?.color),
              onPressed: _enableEdit,
            ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<ProfilesCubit, ProfilesState>(
        listener: (context, state) {
          if (state is ProfilesLoaded) {
            // Only update controllers if NOT editing (initially or after save)
            if (!_isEditing) {
              _nameController.text = state.profile.fullName;
              _emailController.text = state.profile.email;
              _phoneController.text = state.profile.phone;
            }
          } else if (state is ProfilesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfilesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use loaded state or fallback to controllers if we have data there
          // (Handle case where ProfilesCubit might be initial or error but we want to show UI)
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // === Profile Header ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: (state is ProfilesLoaded &&
                                    state.profile.avatarUrl != null &&
                                    state.profile.avatarUrl!.isNotEmpty)
                                ? NetworkImage(state.profile.avatarUrl!)
                                    as ImageProvider
                                : AssetImage(AppAssets.babyMom),
                            backgroundColor: colorScheme.surface,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : "User Name",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailController.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // === Personal Information ===
                _buildSectionTitle(context, "Personal Information"),
                const SizedBox(height: 16),
                
                _buildTextField(
                  context,
                  label: "Full Name",
                  controller: _nameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  label: "Email Address",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  enabled: _isEditing, // Email usually read-only or requires re-auth? Let's allow edit for now.
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  label: "Phone Number",
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                ),

                const SizedBox(height: 32),

                // === Action Buttons ===
                if (_isEditing && state is ProfilesLoaded) ...[
                   Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelEdit(state),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text("Save Changes"),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Normal View Buttons
                  _buildMenuButton(
                    context,
                    title: "Check your babies list",
                    icon: Icons.child_care,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.myBabies),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    context,
                    title: "Logout",
                    icon: Icons.logout,
                    isDestructive: true,
                    onTap: () {
                      context.read<ProfilesCubit>().signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // === Helper Widgets ===

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: controller,
      readOnly: !enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.iconTheme.color?.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        filled: true,
        fillColor: enabled 
            ? theme.colorScheme.surface 
            : theme.colorScheme.surfaceVariant.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final color = isDestructive ? colorScheme.error : colorScheme.primary;
    
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive 
            ? colorScheme.errorContainer 
            : colorScheme.primaryContainer.withOpacity(0.4),
        foregroundColor: isDestructive ? colorScheme.error : colorScheme.onSurface,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
