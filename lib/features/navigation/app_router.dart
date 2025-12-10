import 'package:flutter/material.dart';
import 'package:tifli/features/auth/presentation/screens/login_screen.dart';
import 'package:tifli/features/auth/presentation/screens/splash_screen.dart';
import 'package:tifli/features/home/presentation/screens/home_screen.dart';
import 'package:tifli/features/navigation/presentation/screens/main_tab_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/schedules_menu_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/appointments_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/appointment_form_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/appointment_details_screen.dart';

import 'package:tifli/features/schedules/presentation/screens/meal_planner_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/medicine_schedule_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/add_medicine_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/shopping_list_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/trackers_menu_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:tifli/features/logs/presentation/screens/baby_logs_reports_screen.dart';
import 'package:tifli/features/logs/presentation/screens/feeding_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/sleeping_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/growth_logs_screen.dart';

import 'package:tifli/features/profiles/presentation/screens/baby_profile_screen.dart';
import 'package:tifli/features/profiles/presentation/screens/my_babies.dart';

import 'package:tifli/features/profiles/presentation/screens/parent_profile_screen.dart';
import 'package:tifli/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:tifli/features/auth/presentation/screens/onboarding_screen.dart';

class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String login = '/auth/login';
  // Auth + Intro
  static const String onboarding = '/onboarding';
  static const String auth = '/auth'; // or login wrapper screen

  // Home
  static const String home = '/home';
  static const String maintabscreen = '/main_tab_screen';
  // Schedules
  static const String schedules = '/schedules_menu_screen.dart';
  static const String appointments = '/schedules/appointments';
  static const String appointmentForm = '/schedules/appointment-form';
  static const String appointmentDetails = '/schedules/appointment-details';
  static const String appointmentMonth = '/schedules/appointment-month';
  static const String appointmentWeek = '/schedules/appointment-week';
  static const String mealPlanner = '/schedules/meal-planner';
  static const String medicineSchedule = '/schedules/medicine';
  static const String addMedicine = '/schedules/add-medicine';
  static const String shoppingList = '/schedules/shopping';

  // Trackers
  static const String trackers = '/trackers_menu_screen.dart';
  static const String foodTracker = '/trackers/food';
  static const String sleepTracker = '/trackers/sleep';
  static const String growthTracker = '/trackers/growth';

  // Logs
  static const String logs = '/logs';
  static const String feedingLogs = '/logs/feeding';
  static const String sleepingLogs = '/logs/sleeping';
  static const String growthLogs = '/logs/growth';
  static const String souvenirs = '/logs/souvenirs';
  static const String statistics = '/logs/statistics';
  static const String editFeedingLog = '/logs/edit-feeding';

  // Profiles
  static const String profiles = '/profiles';
  static const String babyProfile = '/profiles/baby';
  static const String createBaby = '/profiles/create-baby';
  static const String createProfile = '/profiles/create-profile';
  static const String myBabies = '/profiles/my-babies';
  static const String parentProfile = '/profiles/parent';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
}

class AppRouter {
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.maintabscreen:
        return MaterialPageRoute(builder: (_) => const MainTabScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // Schedules
      case AppRoutes.schedules:
        return MaterialPageRoute(builder: (_) => const SchedMenuScreen());
      case AppRoutes.appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case AppRoutes.appointmentForm:
        return MaterialPageRoute(builder: (_) => const AppointmentScreen());
      case AppRoutes.appointmentDetails:
        return MaterialPageRoute(
          builder: (_) => const AppointmentDetailsScreen(),
        );
      case AppRoutes.appointmentMonth:
        // Month View Placeholder
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Month View'))),
        );
      case AppRoutes.appointmentWeek:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Week View'))),
        );
      case AppRoutes.mealPlanner:
        return MaterialPageRoute(builder: (_) => const MealPlannerScreenV2());
      case AppRoutes.medicineSchedule:
        return MaterialPageRoute(builder: (_) => const MedicineScreen());
      case AppRoutes.addMedicine:
        return MaterialPageRoute(builder: (_) => const MedicineSchedulePage());
      case AppRoutes.shoppingList:
        return MaterialPageRoute(builder: (_) => const ShoppingListScreen());

      // Trackers
      case AppRoutes.trackers:
        return MaterialPageRoute(builder: (_) => const TrackersMenuScreen());
      case AppRoutes.foodTracker:
        return MaterialPageRoute(builder: (_) => const FoodTrackerScreen());
      case AppRoutes.sleepTracker:
        return MaterialPageRoute(builder: (_) => const SleepPage());
      case AppRoutes.growthTracker:
        return MaterialPageRoute(builder: (_) => const GrowthPage());

      // Logs
      case AppRoutes.logs:
        return MaterialPageRoute(builder: (_) => const BabyLogsReportsPage());
      case AppRoutes.feedingLogs:
        return MaterialPageRoute(builder: (_) => const FeedingLogsScreen());
      case AppRoutes.sleepingLogs:
        return MaterialPageRoute(builder: (_) => const SleepingLogsScreen());
      case AppRoutes.growthLogs:
        return MaterialPageRoute(builder: (_) => const GrowthLogsScreen());

      // Profiles
      case AppRoutes.babyProfile:
        return MaterialPageRoute(builder: (_) => const BabyProfileScreen());
      case AppRoutes.createBaby:
      // return MaterialPageRoute(builder: (_) => const CreateBabyScreen());
      case AppRoutes.createProfile:
      // return MaterialPageRoute(builder: (_) => const CreateProfileScreen());
      case AppRoutes.myBabies:
        return MaterialPageRoute(builder: (_) => const MyBabiesPage());
      case AppRoutes.parentProfile:
        return MaterialPageRoute(builder: (_) => const ParentProfileScreen());

      // Admin
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      default:
        return _errorRoute(settings);
    }
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
