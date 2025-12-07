import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/features/profiles/presentation/cubit/children_cubit.dart';
import 'package:tifli/features/profiles/presentation/screens/create_baby_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'baby_card.dart';
import 'baby_profile_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading children',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Select this child in ChildSelectionCubit
                          context.read<ChildSelectionCubit>().selectChild(
                            child.id,
                            child.firstName,
                          );

                          // Show snackbar confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected ${child.firstName}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          // Navigate to Baby Profile
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BabyProfileScreen(),
                            ),
                          );
                        },
                        child: BabyCard(
                          name: child.firstName,
                          age: calculateAgeInYears(child.birthDate),
                          imageUrl:
                              child.profileImage ??
                              'https://via.placeholder.com/150',
                          borderColor: const Color.fromARGB(0, 255, 255, 255),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Baby'),
                                content: Text(
                                  'Are you sure you want to delete ${child.firstName}? This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      final userId =
                                          UserContext.getCurrentUserId();
                                      if (userId != null) {
                                        context
                                            .read<ChildrenCubit>()
                                            .deleteChild(child.id, userId);
                                      }
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color.fromARGB(255, 11, 11, 11),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
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
    );
  }
}
