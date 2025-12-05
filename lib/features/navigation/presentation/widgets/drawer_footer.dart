import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/features/profiles/presentation/cubit/children_cubit.dart';
import 'package:tifli/features/profiles/data/models/child_model.dart';

class DrawerFooter extends StatefulWidget {
  const DrawerFooter({super.key});

  @override
  State<DrawerFooter> createState() => _DrawerFooterState();
}

class _DrawerFooterState extends State<DrawerFooter> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _parentProfile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadParentProfile();
    _loadChildren();
  }

  Future<void> _loadParentProfile() async {
    try {
      final userId = UserContext.getCurrentUserId();
      if (userId == null) return;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _parentProfile = profile;
          _loadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  Future<void> _loadChildren() async {
    final userId = UserContext.getCurrentUserId();
    if (userId != null) {
      context.read<ChildrenCubit>().loadChildren(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Parent Profile
          Expanded(
            child: _buildParentProfile(),
          ),
          const SizedBox(width: 12),
          // Baby Selector
          _buildBabySelector(),
        ],
      ),
    );
  }

  Widget _buildParentProfile() {
    if (_loadingProfile) {
      return const Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Loading...', style: TextStyle(fontSize: 12)),
        ],
      );
    }

    final fullName = _parentProfile?['full_name'] ?? 'Parent';
    final profileImage = _parentProfile?['profile_image'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: profileImage != null
                ? NetworkImage(profileImage)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: profileImage == null
                ? Icon(Icons.person, size: 16, color: Colors.grey.shade600)
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fullName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabySelector() {
    return BlocBuilder<ChildrenCubit, ChildrenState>(
      builder: (context, childrenState) {
        return BlocBuilder<ChildSelectionCubit, ChildSelectionState>(
          builder: (context, selectionState) {
            if (childrenState is! ChildrenLoaded) {
              return const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.child_care, color: Colors.white, size: 20),
              );
            }

            final children = childrenState.children;
            if (children.isEmpty) {
              return const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              );
            }

            // Get selected child
            String? selectedChildId;
            if (selectionState is ChildSelected) {
              selectedChildId = selectionState.childId;
            }

            final selectedChild = children.firstWhere(
              (child) => child.id == selectedChildId,
              orElse: () => children.first,
            );

            return GestureDetector(
              onTap: () => _showBabySelector(context, children, selectedChildId),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: selectedChild.profileImage != null
                    ? NetworkImage(selectedChild.profileImage!)
                    : null,
                backgroundColor: const Color(0xFFBA224D),
                child: selectedChild.profileImage == null
                    ? Text(
                        selectedChild.firstName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showBabySelector(
    BuildContext context,
    List<ChildModel> children,
    String? currentlySelectedId,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Baby',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children.map((child) {
              final isSelected = child.id == currentlySelectedId;
              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: child.profileImage != null
                      ? NetworkImage(child.profileImage!)
                      : null,
                  backgroundColor: const Color(0xFFBA224D),
                  child: child.profileImage == null
                      ? Text(
                          child.firstName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  child.firstName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFFBA224D))
                    : null,
                onTap: () {
                  // Use the parent context here, not bottomSheetContext
                  context.read<ChildSelectionCubit>().selectChild(
                        child.id,
                        child.firstName,
                      );
                  Navigator.pop(bottomSheetContext);
                  
                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected ${child.firstName}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
