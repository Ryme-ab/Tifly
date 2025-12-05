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
import 'package:provider/provider.dart' as provider;
// flutter_bloc and local supabase client manager not required here
import 'package:tifli/features/profiles/presentation/screens/parent_profile_screen.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';

// <-- your file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 MUST RUN BEFORE ANYTHING USES SUPABASE
  await Supabase.initialize(
    url: 'https://oxkarvwcfcssbebiqamc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94a2FydndjZmNzc2JlYmlxYW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NzU5MjYsImV4cCI6MjA4MDE1MTkyNn0.kivBLMGBnaIIqQvFPj-xSMjqOwJgzktVYAW8PFzbBS0',
  );

  // Create shared app-level providers
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<AppBarConfig> appBarNotifier = ValueNotifier(
    AppBarConfig(
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    ),
  );

  runApp(MyApp(scaffoldKey: scaffoldKey, appBarNotifier: appBarNotifier));
}

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ValueNotifier<AppBarConfig> appBarNotifier;

  const MyApp({
    super.key,
    required this.scaffoldKey,
    required this.appBarNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.Provider<GlobalKey<ScaffoldState>>.value(value: scaffoldKey),
        provider.ValueListenableProvider<AppBarConfig>.value(
          value: appBarNotifier,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const ParentProfileScreen(),
      ),
    );
  }
}
