import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';
import 'package:tifli/features/navigation/presentation/screens/drawer.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import '../cubit/home_cubit.dart';
import '../../data/repositories/home_repository.dart';
import '../widgets/header_section.dart';
import '../widgets/logs_section.dart';
import '../widgets/schedule_section.dart';
import '../widgets/memories_section.dart';
import '../widgets/growth_section.dart';

class HomeScreen extends StatefulWidget {
  final String? childId; // optional override for testing/switching
  final String? parentId; // optional override for testing without auth
  const HomeScreen({super.key, this.childId, this.parentId});
  static const double horizontalPadding = 20.0;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit cubit;

  @override
  void initState() {
    super.initState();
    final repo = SupabaseHomeRepository();
    cubit = HomeCubit(repository: repo);
    // Allow passing args via Navigator route settings
    final settingsArgs = (ModalRoute.of(context)?.settings.arguments);
    String? argChildId;
    String? argParentId;
    if (settingsArgs is Map) {
      argChildId = settingsArgs['childId'] as String?;
      argParentId = settingsArgs['parentId'] as String?;
    }
    final effectiveChildId = widget.childId ?? argChildId;
    final effectiveParentId = widget.parentId ?? argParentId;
    if (effectiveChildId != null && effectiveChildId.isNotEmpty) {
      cubit.loadForChild(effectiveChildId, parentId: effectiveParentId);
    } else {
      cubit.load(parentId: effectiveParentId);
    }
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppBarConfig>(
      create: (_) => AppBarConfig(title: 'Home'),
      child: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: const CustomAppBar(),
          drawer: const Tiflidrawer(),
          body: SafeArea(
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: HomeScreen.horizontalPadding, vertical: 16),
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
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Failed to load home data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      ),
    );
  }
}