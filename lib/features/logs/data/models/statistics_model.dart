class Statistics {
  // Feeding statistics
  final int totalMeals;
  final int todayMeals;
  final double avgMealsPerDay;
  final Map<String, int> mealTypeDistribution;
  
  // Sleep statistics
  final int totalSleepSessions;
  final double avgSleepHoursPerDay;
  final double totalSleepHoursThisWeek;
  final Map<String, int> sleepQualityDistribution;
  
  // Health/Medication statistics
  final int totalMedications;
  final int activeMedications;
  
  // Growth statistics (if available)
  final double? latestWeight;
  final double? latestHeight;
  
  Statistics({
    required this.totalMeals,
    required this.todayMeals,
    required this.avgMealsPerDay,
    required this.mealTypeDistribution,
    required this.totalSleepSessions,
    required this.avgSleepHoursPerDay,
    required this.totalSleepHoursThisWeek,
    required this.sleepQualityDistribution,
    required this.totalMedications,
    required this.activeMedications,
    this.latestWeight,
    this.latestHeight,
  });

  factory Statistics.empty() {
    return Statistics(
      totalMeals: 0,
      todayMeals: 0,
      avgMealsPerDay: 0.0,
      mealTypeDistribution: {},
      totalSleepSessions: 0,
      avgSleepHoursPerDay: 0.0,
      totalSleepHoursThisWeek: 0.0,
      sleepQualityDistribution: {},
      totalMedications: 0,
      activeMedications: 0,
      latestWeight: null,
      latestHeight: null,
    );
  }

  Statistics copyWith({
    int? totalMeals,
    int? todayMeals,
    double? avgMealsPerDay,
    Map<String, int>? mealTypeDistribution,
    int? totalSleepSessions,
    double? avgSleepHoursPerDay,
    double? totalSleepHoursThisWeek,
    Map<String, int>? sleepQualityDistribution,
    int? totalMedications,
    int? activeMedications,
    double? latestWeight,
    double? latestHeight,
  }) {
    return Statistics(
      totalMeals: totalMeals ?? this.totalMeals,
      todayMeals: todayMeals ?? this.todayMeals,
      avgMealsPerDay: avgMealsPerDay ?? this.avgMealsPerDay,
      mealTypeDistribution: mealTypeDistribution ?? this.mealTypeDistribution,
      totalSleepSessions: totalSleepSessions ?? this.totalSleepSessions,
      avgSleepHoursPerDay: avgSleepHoursPerDay ?? this.avgSleepHoursPerDay,
      totalSleepHoursThisWeek: totalSleepHoursThisWeek ?? this.totalSleepHoursThisWeek,
      sleepQualityDistribution: sleepQualityDistribution ?? this.sleepQualityDistribution,
      totalMedications: totalMedications ?? this.totalMedications,
      activeMedications: activeMedications ?? this.activeMedications,
      latestWeight: latestWeight ?? this.latestWeight,
      latestHeight: latestHeight ?? this.latestHeight,
    );
  }
}
