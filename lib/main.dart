// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tifli/core/config/supabaseClient.dart';
// import 'package:tifli/features/auth/presentation/cubit/signin_cubit.dart';
// import 'package:tifli/features/auth/data/repositories/signin_repository.dart';
// import 'package:tifli/features/auth/presentation/screens/signin_screen.dart';
// import 'package:tifli/features/auth/presentation/screens/splash_screen.dart';
// import 'package:tifli/features/navigation/app_router.dart';

// import 'package:tifli/features/navigation/presentation/screens/main_tab_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SupabaseClientManager.initialize();

//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider<AuthCubit>(
//           create: (_) =>
//               AuthCubit(AuthRepository(SupabaseClientManager().client)),
//         ),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: const SignUpPage(),
//       ),
//       initialRoute: '/',
//       onGenerateRoute: AppRouter.generateRoute,
//       home: const MainTabScreen(),
//     );
//   }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:tifli/features/profiles/presentation/screens/my_babies.dart';

// <-- your file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 MUST RUN BEFORE ANYTHING USES SUPABASE
  await Supabase.initialize(
    url: 'https://oxkarvwcfcssbebiqamc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94a2FydndjZmNzc2JlYmlxYW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NzU5MjYsImV4cCI6MjA4MDE1MTkyNn0.kivBLMGBnaIIqQvFPj-xSMjqOwJgzktVYAW8PFzbBS0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyBabiesPage(
        parentId: '8c608294-5431-41b0-9ddc-d9cedaf5d109',
      ),
    );
  }
}
