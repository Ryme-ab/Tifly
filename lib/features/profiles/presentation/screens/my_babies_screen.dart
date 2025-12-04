import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class MyBabiesScreen extends StatelessWidget {
  const MyBabiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Babies'),
      body: const Center(
        child: Text('My Babies Screen - Coming Soon'),
      ),
    );
  }
}
