import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:tifli/features/auth/presentation/cubit/signin_cubit.dart';
import 'package:tifli/features/auth/data/repositories/signin_repository.dart';
import 'package:tifli/features/auth/presentation/screens/signin_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientManager.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) =>
              AuthCubit(AuthRepository(SupabaseClientManager().client)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SignUpPage(),
      ),
    ),
  );
}
