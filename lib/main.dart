import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tifli/l10n/app_localizations.dart';

// --- Firebase & Notifications ---
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:tifli/core/services/notification_service.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/firebase_options.dart';

// --- Supabase Core ---
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:tifli/core/config/test_config.dart';
import 'package:tifli/core/widgets/test_data_loader.dart';

// --- Auth ---
import 'package:tifli/features/auth/presentation/cubit/signin_cubit.dart';
import 'package:tifli/features/auth/data/repositories/signin_repository.dart';

// --- Logs ---
import 'package:tifli/features/logs/data/data_sources/feeding_logs_data.dart';
import 'package:tifli/features/logs/data/data_sources/growth_logs_data_source.dart';
import 'package:tifli/features/logs/data/data_sources/baby_logs_data_source.dart';
import 'package:tifli/features/logs/data/data_sources/sleep_log_data_source.dart';
import 'package:tifli/features/logs/data/data_sources/medication_log_data_source.dart';
import 'package:tifli/features/logs/data/data_sources/statistics_data_source.dart';
import 'package:tifli/features/logs/data/repositories/feeding_logs_repo.dart';
import 'package:tifli/features/logs/data/repositories/growth_logs_repository.dart';
import 'package:tifli/features/logs/data/repositories/baby_logs_repository.dart';
import 'package:tifli/features/logs/data/repositories/sleep_log_repository.dart';
import 'package:tifli/features/logs/data/repositories/medication_log_repository.dart';
import 'package:tifli/features/logs/data/repositories/statistics_repository.dart';
import 'package:tifli/features/logs/presentation/cubit/feeding_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/medication_log_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/statistics_cubit.dart';

// --- Schedule & Checklist ---
import 'package:tifli/features/schedules/data/data_sources/schedules_remote_data_source.dart';
import 'package:tifli/features/schedules/data/data_sources/appointments_remote_data_source.dart';
import 'package:tifli/features/schedules/data/data_sources/doctors_remote_data_source.dart';
import 'package:tifli/features/schedules/data/repositories/schedules_repository.dart';
import 'package:tifli/features/schedules/data/repositories/appointments_repository.dart';
import 'package:tifli/features/schedules/data/repositories/doctors_repository.dart';
import 'package:tifli/features/schedules/presentation/cubit/schedules_cubit.dart';
import 'package:tifli/features/schedules/presentation/cubit/appointments_cubit.dart';
import 'package:tifli/features/schedules/presentation/cubit/doctors_cubit.dart';

// --- Meal Planner ---
import 'package:tifli/features/schedules/data/data_sources/meal_planner_data_source.dart';
import 'package:tifli/features/schedules/data/repositories/meal_planner_repository.dart';
import 'package:tifli/features/schedules/presentation/cubit/meal_planner_cubit.dart';

// --- Profiles & Children ---
import 'package:tifli/features/profiles/data/data_sources/children_data_source.dart';
import 'package:tifli/features/profiles/data/data_sources/emergency_card_local_data_source.dart';
import 'package:tifli/features/profiles/data/data_sources/emergency_card_remote_data_source.dart';
import 'package:tifli/features/profiles/data/repositories/children_repository.dart';
import 'package:tifli/features/profiles/data/repositories/profiles_repository.dart';
import 'package:tifli/features/profiles/data/repositories/emergency_card_repository_impl.dart';
import 'package:tifli/features/profiles/domain/usecases/get_emergency_card_usecase.dart';
import 'package:tifli/features/profiles/domain/usecases/save_emergency_card_usecase.dart';
import 'package:tifli/features/profiles/presentation/cubit/children_cubit.dart';
import 'package:tifli/features/profiles/presentation/cubit/profiles_cubit.dart';
import 'package:tifli/features/profiles/presentation/cubit/emergency_card_cubit.dart';
import 'package:tifli/core/utils/database_helper.dart';

// --- Navigation ---
import 'package:tifli/features/navigation/app_router.dart';

// --- Trackers ---
import 'package:tifli/features/trackers/presentation/cubit/meal_cubit.dart';
import 'package:tifli/features/trackers/presentation/cubit/sleep_cubit.dart';
import 'package:tifli/features/trackers/presentation/cubit/growth_cubit.dart';
import 'package:tifli/features/trackers/data/repositories/sleep_repository.dart';
import 'package:tifli/features/trackers/data/repositories/growth_repository.dart';

// --- Gallery ---
import 'package:tifli/features/souvenires/data/data_sources/gallery_remote_data_source.dart';
import 'package:tifli/features/souvenires/data/repositories/gallery_repository.dart';
import 'package:tifli/features/souvenires/presentation/cubit/gallery_cubit.dart';

// --- Child Selection & Locale ---
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/core/state/locale_cubit.dart';

// --- Theme ---
import 'package:tifli/core/theme/app_theme.dart';
import 'package:tifli/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:tifli/features/theme/presentation/cubit/theme_state.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz_data.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'appointment_channel',
    'Appointment Reminders',
    description: 'Reminders for scheduled appointments',
    importance: Importance.max,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase & Notifications
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initNotifications();

  // Initialize Supabase
  await SupabaseClientManager.initialize();
  final supabase = SupabaseClientManager().client;
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FCM for current user
  final userId = UserContext.getCurrentUserId();
  if (userId != null) {
    NotificationService.instance.initFCM(userId: userId);
  }

  runApp(
    MultiBlocProvider(
      providers: [
        // THEME SYSTEM
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()..loadSavedTheme()),

        // LOCALIZATION
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),

        // CHILD SELECTION
        BlocProvider<ChildSelectionCubit>(create: (_) => ChildSelectionCubit()),

        // AUTH
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(AuthRepository(supabase)),
        ),

        // FEEDING LOGS
        BlocProvider<FeedingLogCubit>(
          create: (context) => FeedingLogCubit(
            repository: FeedingLogRepository(
              dataSource: FeedingLogDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // GROWTH LOGS
        BlocProvider<GrowthLogCubit>(
          create: (context) => GrowthLogCubit(
            repository: GrowthLogRepository(
              dataSource: GrowthLogDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // BABY LOGS
        BlocProvider<BabyLogsCubit>(
          create: (_) => BabyLogsCubit(
            repository: BabyLogsRepository(
              dataSource: BabyLogsDataSource(client: supabase),
            ),
          ),
        ),

        // SLEEP LOGS
        BlocProvider<SleepLogCubit>(
          create: (context) => SleepLogCubit(
            repository: SleepLogRepository(
              dataSource: SleepLogDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // MEDICATION LOGS
        BlocProvider<MedicationLogCubit>(
          create: (context) => MedicationLogCubit(
            repository: MedicationRepository(
              dataSource: MedicationDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // STATISTICS
        BlocProvider<StatisticsCubit>(
          create: (_) => StatisticsCubit(
            repository: StatisticsRepository(
              dataSource: StatisticsDataSource(client: supabase),
            ),
          ),
        ),

        // CHECKLIST
        BlocProvider<ChecklistCubit>(
          create: (context) => ChecklistCubit(
            repository: ChecklistRepository(
              dataSource: ChecklistDataSource(client: supabase),
            ),
            supabase: supabase,
            childSelectionCubit: context.read<ChildSelectionCubit>(),
          ),
        ),

        // MEAL PLANNER SYSTEM
        BlocProvider<MealPlannerCubit>(
          create: (_) => MealPlannerCubit(
            repository: MealPlannerRepository(
              dataSource: MealPlannerDataSource(),
            ),
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

        // TRACKERS
        BlocProvider<MealCubit>(create: (_) => MealCubit()),
        BlocProvider<SleepCubit>(
          create: (_) => SleepCubit(SleepRepository(supabase)),
        ),
        BlocProvider<GrowthCubit>(
          create: (_) => GrowthCubit(GrowthRepository(supabase)),
        ),

        // GALLERY
        BlocProvider<GalleryCubit>(
          create: (_) =>
              GalleryCubit(GalleryRepositoryImpl(GalleryRemoteDataSource())),
        ),

        // PARENT PROFILE
        BlocProvider<ProfilesCubit>(
          create: (_) => ProfilesCubit(ProfilesRepository()),
        ),

        // EMERGENCY CARD
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

        // APPOINTMENTS & DOCTORS
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
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return TestDataLoader(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.themeMode,
                  locale: locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
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
