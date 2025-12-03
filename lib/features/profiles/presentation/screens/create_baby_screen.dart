import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class CreateBabyScreen extends StatelessWidget {
  const CreateBabyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Baby Profile'),
      body: const Center(
        child: Text('Create Baby Screen - Coming Soon'),
      ),
    );
  }
}