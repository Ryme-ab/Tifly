import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Home'),
      body: Center(
        child: Text(
          "🏠 Home Page Content",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
