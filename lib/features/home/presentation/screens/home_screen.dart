import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';
import 'package:tifli/features/navigation/presentation/screens/drawer.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/l10n/app_localizations.dart';
import '../cubit/home_cubit.dart';
import '../../data/repositories/home_repository.dart';
import '../widgets/header_section.dart' hide AppColors;
import '../widgets/logs_section.dart';
import '../widgets/schedule_section.dart';
import '../widgets/memories_section.dart';
import '../widgets/growth_section.dart';
import 'package:tifli/features/navigation/app_router.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/features/profiles/presentation/screens/create_baby_screen.dart';
import 'package:tifli/core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final String? childId; // optional override for testing/switching
  final String? parentId; // optional override for testing without auth
  const HomeScreen({super.key, this.childId, this.parentId});
  static const double horizontalPadding = 20.0;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late final HomeCubit cubit;
  bool _didInitLoad = false;

  @override
  void initState() {
    super.initState();
    final repo = SupabaseHomeRepository();
    cubit = HomeCubit(repository: repo);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to know when we return to Home
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute<dynamic>) {
      AppRouter.routeObserver.subscribe(this, modalRoute);
    }
    if (_didInitLoad) return;
    _didInitLoad = true;
    // Safe access to inherited widgets/route arguments after initState
    final settingsArgs = ModalRoute.of(context)?.settings.arguments;
    String? argChildId;
    String? argParentId;
    if (settingsArgs is Map) {
      argChildId = settingsArgs['childId'] as String?;
      argParentId = settingsArgs['parentId'] as String?;
    }
    // Prefer persisted/selected child from ChildSelectionCubit
    final cubitSelectedChildId = context
        .read<ChildSelectionCubit>()
        .selectedChildId;
    final effectiveChildId =
        cubitSelectedChildId ?? widget.childId ?? argChildId;
    final effectiveParentId = widget.parentId ?? argParentId;
    // Defer state-changing loads to next frame to avoid build-time setState warnings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (effectiveChildId != null && effectiveChildId.isNotEmpty) {
        cubit.loadForChild(effectiveChildId, parentId: effectiveParentId);
      } else {
        cubit.load(parentId: effectiveParentId);
      }
    });
  }

  @override
  void dispose() {
    // Unsubscribe from route observer
    AppRouter.routeObserver.unsubscribe(this);
    cubit.close();
    super.dispose();
  }

  // Called when coming back to this route (e.g., after pushing another screen)
  @override
  void didPopNext() {
    // Reload using the currently selected child to reflect latest changes
    final selectedChildId = context.read<ChildSelectionCubit>().selectedChildId;
    if (selectedChildId != null && selectedChildId.isNotEmpty) {
      cubit.loadForChild(selectedChildId);
    } else {
      cubit.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Provider<AppBarConfig>(
      create: (_) => AppBarConfig(title: l10n.home),
      child: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const CustomAppBar(),
          drawer: const Tiflidrawer(),
          body: SafeArea(
            child: BlocListener<ChildSelectionCubit, ChildSelectionState>(
              listenWhen: (prev, curr) => curr is ChildSelected,
              listener: (context, state) {
                if (state is ChildSelected) {
                  // Reload home when the selected child changes
                  cubit.loadForChild(state.childId);
                }
              },
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading || state is HomeInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HomeError) {
                    return _ErrorView(
                      error: state.message,
                      onRetry: () => context.read<HomeCubit>().refresh(),
                    );
                  } else if (state is HomeLoaded) {
                    final data = state.data;
                    if (!data.hasChildren) {
                      return const _NoChildrenView();
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: HomeScreen.horizontalPadding,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderCard(profile: data.profile, stats: data.stats),
                          const SizedBox(height: 20),
                          const LogsSection(),
                          const SizedBox(height: 22),
                          GrowthSection(summary: data.growthSummary),
                          const SizedBox(height: 22),
                          ScheduleSection(entries: data.schedule),
                          const SizedBox(height: 22),
                          MemoriesSection(memories: data.memories),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.failedToLoadHomeData,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _NoChildrenView extends StatelessWidget {
  const _NoChildrenView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.baby_changing_station,
              size: 64,
              color: Colors.pinkAccent.shade200,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noLittleOnesYet,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(l10n.noChildrenAddedYet, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBabyPage()),
                );
              },
              child: Text(l10n.addBaby),
            ),
          ],
        ),
      ),
    );
  }
}
