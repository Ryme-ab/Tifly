import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/statistics_model.dart';

class StatisticsDataSource {
  final SupabaseClient client;

  StatisticsDataSource({required this.client});

  Future<Statistics> getStatistics(String childId) async {
    try {
      // Get current date range
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));
      
      // Fetch meals data
      final mealsData = await client
          .from('meals')
          .select()
          .eq('child_id', childId);
      
      final todayMeals = mealsData.where((meal) {
        final mealTime = DateTime.parse(meal['meal_time']);
        return mealTime.isAfter(today);
      }).length;
      
      final weekMeals = mealsData.where((meal) {
        final mealTime = DateTime.parse(meal['meal_time']);
        return mealTime.isAfter(weekAgo);
      }).toList();
      
      // Calculate meal type distribution
      final mealTypeDistribution = <String, int>{};
      for (final meal in mealsData) {
        final type = meal['meal_type'] as String? ?? 'Unknown';
        mealTypeDistribution[type] = (mealTypeDistribution[type] ?? 0) + 1;
      }
      
      // Fetch sleep data
      final sleepData = await client
          .from('sleep')
          .select()
          .eq('child_id', childId);
      
      final weekSleep = sleepData.where((sleep) {
        final createdAt = DateTime.parse(sleep['created_at']);
        return createdAt.isAfter(weekAgo);
      }).toList();
      
      // Calculate sleep statistics
      double totalSleepHours = 0.0;
      final sleepQualityDistribution = <String, int>{};
      
      for (final sleep in weekSleep) {
        final startTime = DateTime.parse(sleep['start_time']);
        final endTime = DateTime.parse(sleep['end_time']);
        final duration = endTime.difference(startTime);
        totalSleepHours += duration.inMinutes / 60.0;
        
        final quality = sleep['quality'] as String? ?? 'Unknown';
        sleepQualityDistribution[quality] = (sleepQualityDistribution[quality] ?? 0) + 1;
      }
      
      // Fetch health records (medications)
      final healthData = await client
          .from('health_records')
          .select()
          .eq('child_id', childId);
      
      final recentMedications = healthData.where((record) {
        final recordDate = DateTime.parse(record['record_date']);
        return recordDate.isAfter(weekAgo);
      }).length;
      
      // Try to fetch growth data (optional)
      double? latestWeight;
      double? latestHeight;
      
      try {
        final growthData = await client
            .from('growth')
            .select()
            .eq('child_id', childId)
            .order('record_date', ascending: false)
            .limit(1);
        
        if (growthData.isNotEmpty) {
          latestWeight = (growthData[0]['weight'] as num?)?.toDouble();
          latestHeight = (growthData[0]['height'] as num?)?.toDouble();
        }
      } catch (e) {
        // Growth table might not exist or have data
      }
      
      return Statistics(
        totalMeals: mealsData.length,
        todayMeals: todayMeals,
        avgMealsPerDay: weekMeals.isEmpty ? 0.0 : weekMeals.length / 7.0,
        mealTypeDistribution: mealTypeDistribution,
        totalSleepSessions: sleepData.length,
        avgSleepHoursPerDay: weekSleep.isEmpty ? 0.0 : totalSleepHours / 7.0,
        totalSleepHoursThisWeek: totalSleepHours,
        sleepQualityDistribution: sleepQualityDistribution,
        totalMedications: healthData.length,
        activeMedications: recentMedications,
        latestWeight: latestWeight,
        latestHeight: latestHeight,
      );
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }
}
