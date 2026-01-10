enum LogType { feeding, sleep, medication, growth }

class BabyLog {
  final String id;
  final LogType type;
  final DateTime timestamp;
  final String title;
  final String details;
  final Map<String, dynamic> metadata;

  var note;

  BabyLog({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    required this.details,
    required this.metadata,
  });

  // Factory constructor for feeding logs
  factory BabyLog.fromFeeding(Map<String, dynamic> json) {
    final mealTime = DateTime.parse(json['meal_time']);
    final mealType = json['meal_type'] ?? 'Unknown';
    final items = json['items'] ?? '';
    final amount = json['amount'] ?? 0;

    return BabyLog(
      id: json['id'] ?? '',
      type: LogType.feeding,
      timestamp: mealTime,
      title: 'Feeding - $mealType',
      details: items.isNotEmpty ? '$items\n$amount ml' : '$amount ml',
      metadata: json,
    );
  }

  // Factory constructor for sleep logs
  factory BabyLog.fromSleep(Map<String, dynamic> json) {
    final startTime = DateTime.parse(json['start_time']);
    final endTime = DateTime.parse(json['end_time']);
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final quality = json['quality'] ?? 'Unknown';

    return BabyLog(
      id: json['id'] ?? '',
      type: LogType.sleep,
      timestamp: startTime,
      title: 'Sleep - $quality',
      details: '${hours}h ${minutes}m\n${json['descp'] ?? ''}',
      metadata: json,
    );
  }

  // Factory constructor for medication logs
  factory BabyLog.fromMedication(Map<String, dynamic> json) {
    // Parse timestamps safely
    final timestamp =
        DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now();

    // Extract all medication fields
    final name = json['medicine_name'] ?? 'Unknown Medicine';
    final dosage = json['dosage']?.toString() ?? '';
    final durationUnit = json['duration_unit'] ?? '';
    final durationValue = json['duration_value']?.toString() ?? '';
    final frequency = json['frequency_type'] ?? '';
    final color = json['appearance_color'] ?? '';
    final time = json['time_of_medication'] ?? '';
    final timesPerDay = json['frequency_per_day']?.toString() ?? '';
    final intervalHours = json['interval_hours']?.toString() ?? '';
    final intervalStart = json['interval_start_time'] ?? '';
    final notes = json['notes'] ?? '';

    // Build a readable details string automatically
    final details = [
      "Dosage: $dosage",
      if (durationUnit.isNotEmpty) "Duration: $durationValue $durationUnit",
      if (frequency.isNotEmpty) "Frequency: $frequency",
      if (time.isNotEmpty) "Time: $time",
      if (timesPerDay.isNotEmpty) "Times per day: $timesPerDay",
      if (intervalHours.isNotEmpty) "Every: $intervalHours hours",
      if (intervalStart.isNotEmpty) "Start: $intervalStart",
      if (color.isNotEmpty) "Color tag: $color",
      if (notes.isNotEmpty) "Notes: $notes",
    ].join("\n");

    return BabyLog(
      id: json['id'] ?? '',
      type: LogType.medication,
      timestamp: timestamp,
      title: 'Medication - $name',
      details: details,
      metadata: json, // Keep raw data if needed later
    );
  }

  // Factory constructor for growth logs
  factory BabyLog.fromGrowth(Map<String, dynamic> json) {
    final recordDate = DateTime.parse(json['date']);
    final weight = json['weight'] ?? 0.0;
    final height = json['height'] ?? 0.0;
    final headcir = json['head_circumference'] ?? 0.0;
    final unitHeight = json['unit_height'] ?? 0.0;
    final unitWeight = json['unit_weight'] ?? 0.0;
    final unitHeadCirc = json['unit_head_circ'] ?? 0.0;
    return BabyLog(
      id: json['id'] ?? '',
      type: LogType.growth,
      timestamp: recordDate,
      title: 'Growth Check',
      details:
          'Weight: $weight$unitHeight\nHeight: $height$unitWeight \nCircumenference: $headcir$unitHeadCirc',
      metadata: json,
    );
  }
}
