import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Supabase Core ---
import 'package:tifli/core/config/supabaseClient.dart';

// --- Test Configuration (REMOVE IN PRODUCTION) ---
import 'package:tifli/core/config/test_config.dart';
import 'package:tifli/core/widgets/test_data_loader.dart';

// --- Auth ---
import 'package:tifli/features/auth/presentation/cubit/signin_cubit.dart';
import 'package:tifli/features/auth/data/repositories/signin_repository.dart';
import 'package:tifli/features/auth/presentation/screens/splash_screen.dart';

// --- Feeding Logs ---
import 'package:tifli/features/logs/data/data_sources/feeding_logs_data.dart';
import 'package:tifli/features/logs/data/repositories/feeding_logs_repo.dart';
import 'package:tifli/features/logs/presentation/cubit/feeding_logs_cubit.dart';

// --- Growth Logs ---
import 'package:tifli/features/logs/data/data_sources/growth_logs_data_source.dart';
import 'package:tifli/features/logs/data/repositories/growth_logs_repository.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_cubit.dart';

// --- Baby Logs ---
import 'package:tifli/features/logs/data/data_sources/baby_logs_data_source.dart';
import 'package:tifli/features/logs/data/repositories/baby_logs_repository.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_cubit.dart';

// --- Sleep Logs ---
import 'package:tifli/features/logs/data/data_sources/sleep_log_data_source.dart';
import 'package:tifli/features/logs/data/repositories/sleep_log_repository.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_cubit.dart';

// --- Medication Logs ---
import 'package:tifli/features/logs/data/data_sources/medication_log_data_source.dart';
import 'package:tifli/features/logs/data/repositories/medication_log_repository.dart';
import 'package:tifli/features/logs/presentation/cubit/medication_log_cubit.dart';

// --- Statistics ---
import 'package:tifli/features/logs/data/data_sources/statistics_data_source.dart';
import 'package:tifli/features/logs/data/repositories/statistics_repository.dart';
import 'package:tifli/features/logs/presentation/cubit/statistics_cubit.dart';

// --- Checklist ---
import 'package:tifli/features/schedules/data/data_sources/schedules_remote_data_source.dart';
import 'package:tifli/features/schedules/data/repositories/schedules_repository.dart';
import 'package:tifli/features/schedules/presentation/cubit/schedules_cubit.dart';

// --- Children ---
import 'package:tifli/features/profiles/data/data_sources/children_data_source.dart';
import 'package:tifli/features/profiles/data/repositories/children_repository.dart';
import 'package:tifli/features/profiles/presentation/cubit/children_cubit.dart';

// --- Navigation ---
import 'package:tifli/features/navigation/app_router.dart';
import 'package:tifli/features/navigation/presentation/screens/main_tab_screen.dart';
import 'package:tifli/features/trackers/data/repositories/meal_repository.dart';

// --- Trackers ---
import 'package:tifli/features/trackers/presentation/cubit/meal_cubit.dart';
import 'package:tifli/features/trackers/presentation/cubit/sleep_cubit.dart';
import 'package:tifli/features/trackers/presentation/cubit/growth_cubit.dart';
import 'package:tifli/features/trackers/data/repositories/sleep_repository.dart';
import 'package:tifli/features/trackers/data/repositories/growth_repository.dart';

// --- Child Selection ---
import 'package:tifli/core/state/child_selection_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientManager.initialize();

  final supabase = SupabaseClientManager().client;

  runApp(
    MultiBlocProvider(
      providers: [
        // CHILD SELECTION (FIRST - REQUIRED BY OTHER CUBITS)
        BlocProvider<ChildSelectionCubit>(create: (_) => ChildSelectionCubit()),

        // AUTH SYSTEM
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(AuthRepository(supabase)),
        ),

        // FEEDING LOGS SYSTEM
        BlocProvider<FeedingLogCubit>(
          create: (context) => FeedingLogCubit(
            repository: FeedingLogRepository(
              dataSource: FeedingLogDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // Growth System
        BlocProvider<GrowthLogCubit>(
          create: (context) => GrowthLogCubit(
            repository: GrowthLogRepository(
              dataSource: GrowthLogDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // BABY LOGS SYSTEM
        BlocProvider<BabyLogsCubit>(
          create: (_) => BabyLogsCubit(
            repository: BabyLogsRepository(
              dataSource: BabyLogsDataSource(client: supabase),
            ),
          ),
        ),

        // SLEEP LOGS SYSTEM
        BlocProvider<SleepLogCubit>(
          create: (context) => SleepLogCubit(
            repository: SleepLogRepository(
              dataSource: SleepLogDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // MEDICATION LOGS SYSTEM
        BlocProvider<MedicationLogCubit>(
          create: (context) => MedicationLogCubit(
            repository: MedicationRepository(
              dataSource: MedicationDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // STATISTICS SYSTEM
        BlocProvider<StatisticsCubit>(
          create: (_) => StatisticsCubit(
            repository: StatisticsRepository(
              dataSource: StatisticsDataSource(client: supabase),
            ),
          ),
        ),

        // CHECKLIST SYSTEM
        BlocProvider<ChecklistCubit>(
          create: (context) => ChecklistCubit(
            repository: ChecklistRepository(
              dataSource: ChecklistDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // CHILDREN SYSTEM
        BlocProvider<ChildrenCubit>(
          create: (context) {
            final cubit = ChildrenCubit(
              ChildrenRepository(
                datasource: ChildrenDataSource(client: supabase),
              ),
            );

            if (TestConfig.enableTestMode) {
              cubit.loadChildren(TestConfig.testParentId);
            }

            return cubit;
          },
        ),

        // TRACKERS SYSTEM
        BlocProvider<MealCubit>(create: (_) => MealCubit(childId: '')),
        BlocProvider<SleepCubit>(
          create: (_) => SleepCubit(SleepRepository(supabase)),
        ),
        BlocProvider<GrowthCubit>(
          create: (_) => GrowthCubit(GrowthRepository(supabase)),
        ),
      ],

      child: TestDataLoader(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    ),
  );
}
