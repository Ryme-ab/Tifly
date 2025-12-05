// Domain models for the Home screen
import 'package:tifli/features/home/presentation/models/home_models.dart';

class Profile {
  final String id;
  final String name;
  final String ageDescription;
  final String avatarUrl;

  Profile({
    required this.id,
    required this.name,
    required this.ageDescription,
    required this.avatarUrl,
  });

  factory Profile.fromDb({
    required Map<String, dynamic> profileRow,
    required Map<String, dynamic> childRow,
  }) {
    final fullName = profileRow['full_name'] as String? ?? '';
    final firstName = childRow['first_name'] as String? ?? '';
    final birthDate = childRow['birth_date'] as String?;
    final avatar = childRow['profile_image'] as String? ?? '';
    final ageDesc = birthDate != null ? _ageFromBirthDate(birthDate) : '';
    return Profile(
      id: profileRow['id'] as String? ?? '',
      name: firstName.isNotEmpty ? firstName : fullName,
      ageDescription: ageDesc,
      avatarUrl: avatar,
    );
  }

  static String _ageFromBirthDate(String birthDate) {
    try {
      final date = DateTime.parse(birthDate);
      final now = DateTime.now();
      int months = (now.year - date.year) * 12 + (now.month - date.month);
      if (now.day < date.day) months -= 1;
      if (months < 12) return '$months Months Old';
      final years = months ~/ 12;
      final remMonths = months % 12;
      return remMonths > 0 ? '$years yr $remMonths mo' : '$years yrs';
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age_description': ageDescription,
        'avatar_url': avatarUrl,
      };
}

class Stat {
  final String title;
  final String subtitle;
  final String value;
  final String icon;
  Stat({required this.title, required this.subtitle, required this.value, required this.icon});
}

class LogEntry {
  final String id;
  final String type;
  final String value;
  final String timestamp;
  LogEntry({required this.id, required this.type, required this.value, required this.timestamp});
}

class ScheduleEntry {
  final String id;
  final String title;
  final String time;
  final String icon;
  final String status;
  ScheduleEntry({required this.id, required this.title, required this.time, required this.icon, required this.status});
}

class Memory {
  final String id;
  final String imageUrl;
  final String title;
  final String date;
  Memory({required this.id, required this.imageUrl, required this.title, required this.date});
}

class HomeData {
  final Profile profile;
  final List<Stat> stats;
  final List<LogEntry> logs;
  final List<ScheduleEntry> schedule;
  final List<Memory> memories;

  // ADD THIS
  final GrowthSummary? growthSummary;

  HomeData({
    required this.profile,
    required this.stats,
    required this.logs,
    required this.schedule,
    required this.memories,

    // ADD THIS
    this.growthSummary,
  });
}
