import 'package:flutter/material.dart';
import 'package:tifli/features/navigation/app_router.dart';
import 'package:tifli/features/navigation/presentation/screens/drawer.dart';
import 'package:provider/provider.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';
import 'package:tifli/l10n/app_localizations.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ValueNotifier<AppBarConfig> _appBarNotifier;

  @override
  void initState() {
    super.initState();
    _appBarNotifier = ValueNotifier(AppBarConfig());
  }

  /// Builds a new Navigator for the selected tab
  Widget _buildCurrentNavigator(int index) {
    return Navigator(
      key: GlobalKey<NavigatorState>(), // NEW key -> resets state
      onGenerateRoute: (settings) {
        switch (index) {
          case 0: // Home
            return AppRouter.generateRoute(RouteSettings(name: AppRoutes.home));
          case 1: // Schedule
            return AppRouter.generateRoute(
              RouteSettings(name: AppRoutes.schedules),
            );
          case 2: // Track
            return AppRouter.generateRoute(
              RouteSettings(name: AppRoutes.trackers),
            );
          case 3: // Logs
            return AppRouter.generateRoute(RouteSettings(name: AppRoutes.logs));
          default:
            return MaterialPageRoute(
              builder: (_) =>
                  const Scaffold(body: Center(child: Text('Unknown Tab'))),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiProvider(
      providers: [
        Provider<GlobalKey<ScaffoldState>>.value(value: _scaffoldKey),
        ValueListenableProvider<AppBarConfig>.value(value: _appBarNotifier),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const Tiflidrawer(),
        body: _buildCurrentNavigator(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Rebuilds navigator -> resets state
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFD93B63),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: l10n.home),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: l10n.schedule,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes),
              label: l10n.track,
            ),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: l10n.logs),
          ],
        ),
      ),
    );
  }
}
