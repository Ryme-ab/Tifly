import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/features/profiles/presentation/cubit/children_cubit.dart';
import 'package:tifli/features/profiles/presentation/screens/create_baby_screen.dart';
import 'package:tifli/features/navigation/app_router.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'baby_card.dart';

class MyBabiesPage extends StatefulWidget {
  const MyBabiesPage({super.key});

  @override
  State<MyBabiesPage> createState() => _MyBabiesPageState();
}

class _MyBabiesPageState extends State<MyBabiesPage> {
  @override
  void initState() {
    super.initState();
    // Load children for the current authenticated user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = UserContext.getCurrentUserId();
      if (userId != null) {
        context.read<ChildrenCubit>().loadChildren(userId);
      }
    });
  }

  // Helper to calculate age in years
  int calculateAgeInYears(DateTime birthDate) {
    final now = DateTime.now();

    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Delete baby with confirmation
  Future<void> _deleteBaby(
    BuildContext context,
    String childId,
    String childName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Baby'),
        content: Text(
          'Are you sure you want to delete $childName? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await context.read<ChildrenCubit>().deleteChild(childId);

        // Reload children after deletion
        final userId = UserContext.getCurrentUserId();
        if (userId != null && context.mounted) {
          await context.read<ChildrenCubit>().loadChildren(userId);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$childName has been deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete $childName: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppBarConfig>(
      create: (_) => const AppBarConfig(title: 'My Babies'),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F4F8),
        appBar: const CustomAppBar(title: 'My Babies'),
        body: BlocBuilder<ChildrenCubit, ChildrenState>(
          builder: (context, state) {
            if (state is ChildrenLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChildrenError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading children',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ChildrenLoaded) {
              if (state.children.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.child_care,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No babies yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first baby to get started!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: state.children.map((child) {
                    return GestureDetector(
                      onTap: () {
                        // Select this child in ChildSelectionCubit
                        context.read<ChildSelectionCubit>().selectChild(
                          child.id,
                          child.firstName,
                        );

                        // Navigate to baby profile screen
                        Navigator.pushNamed(
                          context,
                          AppRoutes.babyProfile,
                          arguments: child,
                        );
                      },
                      child: BabyCard(
                        name: child.firstName,
                        age: calculateAgeInYears(child.birthDate),
                        imageUrl:
                            child.profileImage ??
                            'https://via.placeholder.com/150',
                        borderColor: Colors.pinkAccent,
                        onDelete: () =>
                            _deleteBaby(context, child.id, child.firstName),
                      ),
                    );
                  }).toList(),
                ),
              );
            }

            // Initial state
            return const Center(child: Text('Loading...'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBabyPage()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Baby'),
          backgroundColor: const Color(0xFFBA224D),
        ),
      ),
    );
  }
}
