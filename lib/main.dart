import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tifli/core/services/notification_service.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/firebase_options.dart';
import 'package:tifli/l10n/app_localizations.dart';

// --- Supabase Core ---
import 'package:tifli/core/config/supabaseClient.dart';

import 'package:tifli/core/config/test_config.dart';
import 'package:tifli/core/widgets/test_data_loader.dart';

// --- Auth ---
import 'package:tifli/features/auth/presentation/cubit/signin_cubit.dart';
import 'package:tifli/features/auth/data/repositories/signin_repository.dart';

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

// --- Trackers ---
import 'package:tifli/features/trackers/presentation/cubit/meal_cubit.dart';
import 'package:tifli/features/trackers/presentation/cubit/sleep_cubit.dart';
import 'package:tifli/features/trackers/presentation/cubit/growth_cubit.dart';
import 'package:tifli/features/trackers/data/repositories/sleep_repository.dart';
import 'package:tifli/features/trackers/data/repositories/growth_repository.dart';

// --- Gallery System ---
import 'package:tifli/features/souvenires/data/data_sources/gallery_remote_data_source.dart';
import 'package:tifli/features/souvenires/data/repositories/gallery_repository.dart';
import 'package:tifli/features/souvenires/presentation/cubit/gallery_cubit.dart';

// --- Child Selection ---
import 'package:tifli/core/state/child_selection_cubit.dart';

// --- Parent Profile ---
import 'package:tifli/features/profiles/data/repositories/profiles_repository.dart';
import 'package:tifli/features/profiles/presentation/cubit/profiles_cubit.dart';
// --- Localization ---
import 'package:tifli/core/state/locale_cubit.dart';

// --- Emergency Card ---
import 'package:tifli/features/profiles/data/data_sources/emergency_card_local_data_source.dart';
import 'package:tifli/features/profiles/data/data_sources/emergency_card_remote_data_source.dart';
import 'package:tifli/features/profiles/data/repositories/emergency_card_repository_impl.dart';
import 'package:tifli/features/profiles/domain/usecases/get_emergency_card_usecase.dart';
import 'package:tifli/features/profiles/domain/usecases/save_emergency_card_usecase.dart';
import 'package:tifli/features/profiles/presentation/cubit/emergency_card_cubit.dart';
import 'package:tifli/core/utils/database_helper.dart';

// --- Appointments & Doctors ---
import 'package:tifli/features/schedules/data/data_sources/appointments_remote_data_source.dart';
import 'package:tifli/features/schedules/data/data_sources/doctors_remote_data_source.dart';
import 'package:tifli/features/schedules/data/repositories/appointments_repository.dart';
import 'package:tifli/features/schedules/data/repositories/doctors_repository.dart';
import 'package:tifli/features/schedules/presentation/cubit/appointments_cubit.dart';
import 'package:tifli/features/schedules/presentation/cubit/doctors_cubit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;


// --- Theme ---
import 'package:tifli/core/theme/app_theme.dart';
import 'package:tifli/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:tifli/features/theme/presentation/cubit/theme_state.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  // Initialize timezone data
  tz_data.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create notification channel for Android 8.0+
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'appointment_channel', // id
    'Appointment Reminders', // name
    description: 'Reminders for scheduled appointments',
    importance: Importance.max,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initNotifications();

  await SupabaseClientManager.initialize();

  final supabase = SupabaseClientManager().client;

  final userId = UserContext.getCurrentUserId();
  if (userId != null) {
    NotificationService.instance.initFCM(userId: userId);
  }

  runApp(
    MultiBlocProvider(
      providers: [
        // THEME SYSTEM (load saved theme on startup)
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit()..loadSavedTheme(),
        ),

        // LOCALIZATION
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),

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
        BlocProvider<MealCubit>(create: (_) => MealCubit()),
        BlocProvider<SleepCubit>(
          create: (_) => SleepCubit(SleepRepository(supabase)),
        ),
        BlocProvider<GrowthCubit>(
          create: (_) => GrowthCubit(GrowthRepository(supabase)),
        ),

        // GALLERY SYSTEM
        BlocProvider<GalleryCubit>(
          create: (_) =>
              GalleryCubit(GalleryRepositoryImpl(GalleryRemoteDataSource())),
        ),

        // PARENT PROFILE SYSTEM
        BlocProvider<ProfilesCubit>(
          create: (_) => ProfilesCubit(ProfilesRepository()),
        ),

        // EMERGENCY CARD SYSTEM
        BlocProvider<EmergencyCardCubit>(
          create: (context) {
            final repository = EmergencyCardRepositoryImpl(
              localDataSource: EmergencyCardLocalDataSourceImpl(
                dbHelper: DatabaseHelper(),
              ),
              remoteDataSource: EmergencyCardRemoteDataSourceImpl(
                client: supabase,
              ),
            );
            return EmergencyCardCubit(
              getUseCase: GetEmergencyCardUseCase(repository),
              saveUseCase: SaveEmergencyCardUseCase(repository),
              childSelectionCubit: context.read<ChildSelectionCubit>(),
            );
          },
        ),

        // APPOINTMENTS & DOCTORS SYSTEM
        BlocProvider<AppointmentsCubit>(
          create: (context) => AppointmentsCubit(
            repository: AppointmentsRepository(
              dataSource: AppointmentsDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),
        BlocProvider<DoctorsCubit>(
          create: (_) => DoctorsCubit(
            repository: DoctorsRepository(
              dataSource: DoctorsDataSource(client: supabase),
            ),
          ),
        ),
      ],

      // Wrap with both LocaleCubit and ThemeCubit builders
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return TestDataLoader(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  
                  // Theme configuration
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.themeMode,
                  
                  // Localization
                  locale: locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('en'), Locale('fr')],
                  
                  // Navigation
                  initialRoute: AppRoutes.splash,
                  onGenerateRoute: AppRouter.generateRoute,
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
