import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'baby_card.dart';

class MyBabiesPage extends StatefulWidget {
  final String parentId;

  const MyBabiesPage({super.key, required this.parentId});

  @override
  State<MyBabiesPage> createState() => _MyBabiesPageState();
}

class _MyBabiesPageState extends State<MyBabiesPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> babies = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchBabies();
  }

  // Fetch babies for this parent
  Future<void> fetchBabies() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await supabase
          .from('children')
          .select()
          .eq('parent_id', widget.parentId)
          .execute();

      setState(() {
        babies = List<Map<String, dynamic>>.from(response.data as List);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Helper to calculate age in years
  int calculateAgeInYears(String birthDateString) {
    final birthDate = DateTime.parse(birthDateString);
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
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text('Error: $error')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Babies')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: babies.map((baby) {
            return BabyCard(
              name: baby['first_name'] as String,
              age: calculateAgeInYears(baby['birth_date'] as String),
              imageUrl:
                  baby['profile_image'] as String? ??
                  'https://via.placeholder.com/150',
              borderColor: Colors.pinkAccent,
            );
          }).toList(),
        ),
      ),
    );
  }
}
