import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tifli/core/config/supabaseClient.dart';

import 'package:tifli/features/profiles/data/data_sources/baby_remote_data_source.dart';
import 'package:tifli/features/profiles/data/repositories/baby_repo.dart';
import 'package:tifli/features/profiles/presentation/cubit/baby_cubit.dart';
import 'package:tifli/features/profiles/presentation/screens/create_baby_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await SupabaseClientManager.initialize();

  final supabase = SupabaseClientManager().client;

  runApp(MyApp(supabase: supabase));
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabase;
  const MyApp({super.key, required this.supabase});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BabyCubit>(
          create: (_) =>
              BabyCubit(BabyRepository(BabyRemoteDataSource(supabase))),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AddBabyPage(),
      ),
    );
  }
}
