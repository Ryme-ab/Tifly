import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Profile'),
      body: const Center(
        child: Text('Create Profile Screen - Coming Soon'),
      ),
    );
  }
}
