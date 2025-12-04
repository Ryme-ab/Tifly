import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/logs/presentation/cubit/statistics_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/statistics_state.dart';
import 'package:tifli/core/config/test_config.dart'; // For test child ID

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load statistics data when screen is initialized
    // Using test child ID - replace with actual child ID in production
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsCubit>().loadStatistics(TestConfig.testChildId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f4f8),
      appBar: const CustomAppBar(title: 'Statistics'),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StatisticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<StatisticsCubit>().refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is StatisticsLoaded) {
            final stats = state.statistics;
            
            return RefreshIndicator(
              onRefresh: () => context.read<StatisticsCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Key Metrics
                  const Text(
                    "Key Metrics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildKeyMetrics(stats),
                  const SizedBox(height: 28),
                  
                  // Feeding Statistics
                  const Text(
                    "Feeding Frequency",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFeedingChart(stats),
                  const SizedBox(height: 28),
                  
                  // Sleep Statistics
                  const Text(
                    "Sleep Quality Distribution",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSleepChart(stats),
                  const SizedBox(height: 28),
                  
                  // Growth Data (if available)
                  if (stats.latestWeight != null || stats.latestHeight != null) ...[
                    const Text(
                      "Latest Growth Data",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildGrowthData(stats),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            );
          }
          
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildKeyMetrics(dynamic stats) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: "Total Meals",
            value: "${stats.totalMeals}",
            subtitle: "Today: ${stats.todayMeals}",
            icon: Icons.restaurant,
            color: const Color(0xffe3f2fd),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: "Avg Sleep",
            value: "${stats.avgSleepHoursPerDay.toStringAsFixed(1)}h",
            subtitle: "Per day",
            icon: Icons.nightlight_round,
            color: const Color(0xfff3e5f5),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xffb03a57), size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xffb03a57),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingChart(dynamic stats) {
    final mealTypes = stats.mealTypeDistribution as Map<String, int>;
    
    if (mealTypes.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No feeding data available')),
      );
    }
    
    final entries = mealTypes.entries.toList();
    final colors = [
      const Color(0xffe3f2fd),
      const Color(0xfffff9c4),
      const Color(0xffffcdd2),
      const Color(0xfff3e5f5),
      const Color(0xffe0f7fa),
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average: ${stats.avgMealsPerDay.toStringAsFixed(1)} meals/day',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            entries[index].key.length > 8
                                ? '${entries[index].key.substring(0, 8)}...'
                                : entries[index].key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(entries.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entries[i].value.toDouble(),
                        color: colors[i % colors.length],
                        width: 30,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepChart(dynamic stats) {
    final sleepQuality = stats.sleepQualityDistribution as Map<String, int>;
    
    if (sleepQuality.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No sleep data available')),
      );
    }
    
    final total = sleepQuality.values.reduce((a, b) => a + b);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Total this week: ${stats.totalSleepHoursThisWeek.toStringAsFixed(1)} hours',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: sleepQuality.entries.map((entry) {
                  final color = switch (entry.key.toLowerCase()) {
                    "good" => const Color(0xffb2dfdb),
                    "fair" => const Color(0xfffff9c4),
                    "poor" => const Color(0xffffccbc),
                    _ => Colors.grey,
                  };
                  final percentage = (entry.value / total) * 100;
                  return PieChartSectionData(
                    color: color,
                    value: entry.value.toDouble(),
                    title: "${percentage.toStringAsFixed(1)}%",
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: sleepQuality.keys.map((key) {
              final color = switch (key.toLowerCase()) {
                "good" => const Color(0xffb2dfdb),
                "fair" => const Color(0xfffff9c4),
                "poor" => const Color(0xffffccbc),
                _ => Colors.grey,
              };
              return Row(
                children: [
                  Container(width: 14, height: 14, color: color),
                  const SizedBox(width: 4),
                  Text(key),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthData(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (stats.latestWeight != null)
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.monitor_weight,
                    color: Color(0xffb03a57),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.latestWeight!.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffb03a57),
                    ),
                  ),
                  const Text(
                    'Weight',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          if (stats.latestWeight != null && stats.latestHeight != null)
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
          if (stats.latestHeight != null)
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.height,
                    color: Color(0xffb03a57),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.latestHeight!.toStringAsFixed(1)} cm',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffb03a57),
                    ),
                  ),
                  const Text(
                    'Height',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
