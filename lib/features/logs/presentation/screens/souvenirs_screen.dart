import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class SouvenirsScreen extends StatelessWidget {
  const SouvenirsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Souvenirs'),
      body: const Center(
        child: Text('Souvenirs Screen - Coming Soon'),
      ),
    );
  }
}
