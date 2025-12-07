class Profile {
  final String name;
  final String avatarUrl;
  final String ageDescription;
  final String? bloodType;

  Profile({
    required this.name,
    required this.avatarUrl,
    required this.ageDescription,
    this.bloodType,
  });

  factory Profile.fromDb({
    required Map<String, dynamic> profileRow,
    required Map<String, dynamic> childRow,
  }) {
    // Prefer baby (child) details for Home profile card using schema fields
    final name =
        (childRow['first_name'] as String?) ??
        (childRow['full_name'] as String?) ??
        (childRow['name'] as String?) ??
        'Baby';
    final avatar =
        (childRow['profile_image'] as String?) ??
        (childRow['avatar_url'] as String?) ??
        (profileRow['avatar_url'] as String?) ??
        '';
    final birthIso = childRow['birth_date']?.toString();
    final bloodType = childRow['blood_type'] as String?;
    String ageDesc = '';
    if (birthIso != null) {
      try {
        final dob = DateTime.parse(birthIso);
        final now = DateTime.now();
        final months = (now.year - dob.year) * 12 + (now.month - dob.month);
        ageDesc = months <= 0 ? 'Newborn' : '$months mo';
      } catch (_) {
        ageDesc = '';
      }
    }
    return Profile(
      name: name,
      avatarUrl: avatar,
      ageDescription: ageDesc,
      bloodType: bloodType,
    );
  }
}

class Stat {
  final String title;
  final String subtitle;
  final String value;
  final String icon;
  Stat({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
  });
}

class LogEntry {
  final String id;
  final String type; // feeding | sleep | diaper | temperature
  final String value;
  final String timestamp; // ISO8601
  LogEntry({
    required this.id,
    required this.type,
    required this.value,
    required this.timestamp,
  });
}

class ScheduleEntry {
  final String id;
  final String title;
  final String time; // formatted time
  final String icon; // string key to map to AppIcons
  final String status; // scheduled | done
  final String? isoDate; // ISO8601 date/time for filtering
  ScheduleEntry({
    required this.id,
    required this.title,
    required this.time,
    required this.icon,
    required this.status,
    this.isoDate,
  });
}

class Memory {
  final String id;
  final String imageUrl;
  final String title;
  final String date; // display string
  Memory({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.date,
  });
}

class HomeData {
  final Profile profile;
  final List<Stat> stats;
  final List<LogEntry> logs;
  final List<ScheduleEntry> schedule;
  final List<Memory> memories;
  final GrowthSummary? growthSummary;

  final bool hasChildren; // New flag

  HomeData({
    required this.profile,
    required this.stats,
    required this.logs,
    required this.schedule,
    required this.memories,
    this.growthSummary,
    this.hasChildren = true,
  });
}

class GrowthSummary {
  final String? height;
  final String? weight;
  final String? headCircumference;
  final String date; // display string
  GrowthSummary({
    this.height,
    this.weight,
    this.headCircumference,
    required this.date,
  });
}
