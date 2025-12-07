import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/home_model.dart';

abstract class HomeRepository {
  Future<HomeData> getHomeDataForCurrentUser({String? parentId});
  Future<HomeData> getHomeDataForChild(String childId, {String? parentId});
}

class SupabaseHomeRepository implements HomeRepository {
  final SupabaseClient client;
  SupabaseHomeRepository({SupabaseClient? client})
    : client = client ?? Supabase.instance.client;

  @override
  Future<HomeData> getHomeDataForCurrentUser({String? parentId}) async {
    final userId = parentId ?? client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    // 1) Get profile
    final profileResp = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .limit(1)
        .maybeSingle();
    // if (profileResp == null) throw Exception('Profile not found');
    // Allow missing profile for new users, create a placeholder
    final safeProfileResp =
        profileResp ?? {'full_name': 'My Parent Profile', 'avatar_url': ''};

    final childResp = await client
        .from('children')
        .select()
        .eq('parent_id', userId)
        .order('created_at', ascending: true)
        .limit(1)
        .maybeSingle();

    // FIX: Return empty data instead of throwing if no child exists
    if (childResp == null) {
      print('no child');
      return HomeData(
        profile: Profile(
          name: safeProfileResp['full_name'] ?? 'User',
          avatarUrl: safeProfileResp['avatar_url'] ?? '',
          ageDescription: '',
        ),
        stats: [],
        logs: [],
        schedule: [],
        memories: [],
        growthSummary: GrowthSummary(date: ''),
        hasChildren: false,
      );
    }

    final profile = Profile.fromDb(
      profileRow: safeProfileResp,
      childRow: childResp,
    );
    final childId = childResp['id'] as String;

    // 3) Logs and schedules from checklist (filter by child and user)
    // NOTE: If RLS is strict, ensure policies allow reading this data
    final checklist = await client
        .from('checklist')
        .select(
          'id, title, done, created_at, updated_at, checklist_date, child_id, user_id',
        )
        .eq('child_id', childId)
        .eq('user_id', userId)
        .order('checklist_date', ascending: false)
        .order('created_at', ascending: false);

    // Debug: log counts and fallback without user filter if empty
    // ignore: avoid_print
    print('[home] checklist rows (child+user) => ${checklist.length}');
    List<Map> filtered = checklist.whereType<Map>().toList();
    if (filtered.isEmpty) {
      final checklistChildOnly = await client
          .from('checklist')
          .select(
            'id, title, done, created_at, updated_at, checklist_date, child_id, user_id',
          )
          .eq('child_id', childId)
          .order('checklist_date', ascending: false)
          .order('created_at', ascending: false);
      // ignore: avoid_print
      print(
        '[home] checklist rows (child only) => ${checklistChildOnly.length}',
      );
      filtered = checklistChildOnly.whereType<Map>().toList();
    }

    String inferType(Map item) {
      final explicit = (item['type'] as String?)?.toLowerCase();
      if (explicit != null && explicit.isNotEmpty) return explicit;
      final title = (item['title'] as String?)?.toLowerCase() ?? '';
      if (title.contains('diaper')) return 'diaper';
      if (title.contains('temp') || title.contains('temperature')) {
        return 'temperature';
      }
      if (title.contains('feed') ||
          title.contains('bottle') ||
          title.contains('milk')) {
        return 'feeding';
      }
      if (title.contains('sleep') || title.contains('nap')) return 'sleep';
      return 'other';
    }

    DateTime? extractDate(Map item) {
      final c1 = item['checklist_date']?.toString();
      final c2 = item['created_at']?.toString();
      final c3 = item['updated_at']?.toString();
      for (final s in [c1, c2, c3]) {
        if (s == null || s.isEmpty) continue;
        final dt = DateTime.tryParse(s);
        if (dt != null) return dt;
        // try parsing date-only
        try {
          final parts = s.split('-');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        } catch (_) {}
      }
      return null;
    }

    // use filtered result above, which may be fallback

    // logs: only last one per type where done = true
    final seenTypes = <String>{};
    final List<LogEntry> logs = [];
    for (final item in filtered) {
      final done = item['done'] == true;
      if (!done) continue;
      final type = inferType(item);
      if (type == 'other' || seenTypes.contains(type)) continue;
      seenTypes.add(type);
      final dt = extractDate(item);
      final ts = dt?.toIso8601String() ?? '';
      final title = item['title'] as String? ?? type;
      logs.add(
        LogEntry(
          id: item['id'].toString(),
          type: type,
          value: title,
          timestamp: ts,
        ),
      );
      if (seenTypes.length >= 4) break; // diaper,temp,feeding,sleep
    }
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // schedules: all items where done = false
    final undone = filtered.where((i) => i['done'] != true).toList();
    undone.sort((a, b) {
      final da = extractDate(a);
      final db = extractDate(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    final List<ScheduleEntry> schedule = [];
    for (final item in undone) {
      final type = inferType(item);
      final dt = extractDate(item);
      final timeStr = dt != null ? _formatTime(dt) : '';
      schedule.add(
        ScheduleEntry(
          id: item['id'].toString(),
          title: (item['title'] as String?) ?? 'Scheduled',
          time: timeStr,
          icon: _mapAppointmentTypeToIcon(type),
          status: 'scheduled',
          isoDate: dt?.toIso8601String(),
        ),
      );
    }

    // 5) Memories: gallery
    final gallery = await client
        .from('gallery')
        .select('id, file_path, title, picture_date')
        .eq('child_id', childId)
        .order('picture_date', ascending: false)
        .limit(10);

    final memories = gallery.map<Memory>((g) {
      final dateStr = g['picture_date']?.toString() ?? '';
      return Memory(
        id: g['id'] as String,
        imageUrl: g['file_path'] as String? ?? '',
        title: g['title'] as String? ?? '',
        date: dateStr,
      );
    }).toList();

    // 6) Growth summary (latest)
    // Growth: filter by child and user; fallback to child-only
    // Debug: who's querying
    // ignore: avoid_print
    print('[home] growth query using userId=$userId, childId=$childId');
    var growthRows = await client
        .from('growth')
        .select(
          'date, height, weight, head_circumference, unit_height, unit_weight, unit_head_circ',
        )
        .eq('child_id', childId)
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(1);
    // ignore: avoid_print
    print('[home] growth rows (child+user) => ${growthRows.length}');
    if (growthRows.isEmpty) {
      growthRows = await client
          .from('growth')
          .select(
            'date, height, weight, head_circumference, unit_height, unit_weight, unit_head_circ',
          )
          .eq('child_id', childId)
          .order('date', ascending: false)
          .limit(1);
      // ignore: avoid_print
      print('[home] growth rows (child only) => ${growthRows.length}');
    }
    GrowthSummary? growthSummary;
    if (growthRows.isNotEmpty) {
      final r = growthRows.first as Map;
      growthSummary = GrowthSummary(
        height: (r['height'] != null
            ? '${r['height']} ${r['unit_height'] ?? ''}'.trim()
            : null),
        weight: (r['weight'] != null
            ? '${r['weight']} ${r['unit_weight'] ?? ''}'.trim()
            : null),
        headCircumference: (r['head_circumference'] != null
            ? '${r['head_circumference']} ${r['unit_head_circ'] ?? ''}'.trim()
            : null),
        date: (r['date']?.toString()) ?? '',
      );
    } else {
      // Ensure GrowthSection shows placeholders even without data
      growthSummary = GrowthSummary(
        height: null,
        weight: null,
        headCircumference: null,
        date: '',
      );
    }

    // 7) Stats (example: average sleep duration & feedings per day)
    final avgSleep = await _computeAverageSleep(client, childId);
    final feedingsPerDay = await _computeFeedingPerDay(client, childId);
    final stats = <Stat>[
      Stat(
        title: 'Sleep',
        subtitle: 'Avg. Sleep',
        value: avgSleep,
        icon: 'time',
      ),
      Stat(
        title: 'Feeding',
        subtitle: 'Avg. Feeding',
        value: feedingsPerDay,
        icon: 'feeding',
      ),
      if (profile.bloodType != null && profile.bloodType!.isNotEmpty)
        Stat(
          title: 'Blood',
          subtitle: 'Blood Type',
          value: profile.bloodType!,
          icon: 'hospital',
        ),
      if (growthSummary.weight != null && growthSummary.weight!.isNotEmpty)
        Stat(
          title: 'Weight',
          subtitle: 'Latest',
          value: growthSummary.weight!,
          icon: 'feeding',
        ),
    ];

    return HomeData(
      profile: profile,
      stats: stats,
      logs: logs.take(4).toList(),
      schedule: schedule,
      memories: memories,
      growthSummary: growthSummary,
    );
  }

  @override
  Future<HomeData> getHomeDataForChild(
    String childId, {
    String? parentId,
  }) async {
    // Prefer explicitly provided parentId for testing; fallback to auth user
    final userId = parentId ?? client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No parent id provided');
    }

    // Fetch parent profile (for completeness). If RLS blocks, proceed with child-only data.
    Map<String, dynamic>? profileResp;
    try {
      profileResp = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .limit(1)
          .maybeSingle();
    } catch (e) {
      // ignore and continue
    }

    final childResp = await client
        .from('children')
        .select()
        .eq('id', childId)
        .limit(1)
        .maybeSingle();

    if (childResp == null) {
      return getHomeDataForCurrentUser(parentId: userId);
    }

    final profile = Profile.fromDb(
      profileRow: profileResp ?? <String, dynamic>{},
      childRow: childResp,
    );

    // reuse existing logic with provided childId
    // 3) Logs and schedules from checklist for specific child (filter by child and user)
    final checklist = await client
        .from('checklist')
        .select(
          'id, title, done, created_at, updated_at, checklist_date, child_id, user_id',
        )
        .eq('child_id', childId)
        .eq('user_id', userId)
        .order('checklist_date', ascending: false)
        .order('created_at', ascending: false);

    // Debug: log counts and fallback without user filter if empty
    // ignore: avoid_print
    print('[home] checklist rows (child+user) => ${checklist.length}');
    List<Map> filtered = checklist.whereType<Map>().toList();
    if (filtered.isEmpty) {
      final checklistChildOnly = await client
          .from('checklist')
          .select(
            'id, title, done, created_at, updated_at, checklist_date, child_id, user_id',
          )
          .eq('child_id', childId)
          .order('checklist_date', ascending: false)
          .order('created_at', ascending: false);
      // ignore: avoid_print
      print(
        '[home] checklist rows (child only) => ${checklistChildOnly.length}',
      );
      filtered = checklistChildOnly.whereType<Map>().toList();
    }

    String inferType(Map item) {
      final explicit = (item['type'] as String?)?.toLowerCase();
      if (explicit != null && explicit.isNotEmpty) return explicit;
      final title = (item['title'] as String?)?.toLowerCase() ?? '';
      if (title.contains('diaper')) return 'diaper';
      if (title.contains('temp') || title.contains('temperature')) {
        return 'temperature';
      }
      if (title.contains('feed') ||
          title.contains('bottle') ||
          title.contains('milk')) {
        return 'feeding';
      }
      if (title.contains('sleep') || title.contains('nap')) return 'sleep';
      return 'other';
    }

    DateTime? extractDate(Map item) {
      final c1 = item['checklist_date']?.toString();
      final c2 = item['created_at']?.toString();
      final c3 = item['updated_at']?.toString();
      for (final s in [c1, c2, c3]) {
        if (s == null || s.isEmpty) continue;
        final dt = DateTime.tryParse(s);
        if (dt != null) return dt;
        try {
          final parts = s.split('-');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        } catch (_) {}
      }
      return null;
    }

    // use filtered result above, which may be fallback

    final seenTypes = <String>{};
    final List<LogEntry> logs = [];
    for (final item in filtered) {
      final done = item['done'] == true;
      if (!done) continue;
      final type = inferType(item);
      if (type == 'other' || seenTypes.contains(type)) continue;
      seenTypes.add(type);
      final dt = extractDate(item);
      final ts = dt?.toIso8601String() ?? '';
      final title = item['title'] as String? ?? type;
      logs.add(
        LogEntry(
          id: item['id'].toString(),
          type: type,
          value: title,
          timestamp: ts,
        ),
      );
      if (seenTypes.length >= 4) break;
    }
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final undone = filtered.where((i) => i['done'] != true).toList();
    undone.sort((a, b) {
      final da = extractDate(a);
      final db = extractDate(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    final List<ScheduleEntry> schedule = [];
    for (final item in undone) {
      final type = inferType(item);
      final dt = extractDate(item);
      final timeStr = dt != null ? _formatTime(dt) : '';
      schedule.add(
        ScheduleEntry(
          id: item['id'].toString(),
          title: (item['title'] as String?) ?? 'Scheduled',
          time: timeStr,
          icon: _mapAppointmentTypeToIcon(type),
          status: 'scheduled',
          isoDate: dt?.toIso8601String(),
        ),
      );
    }

    // 5) Memories: gallery
    final gallery = await client
        .from('gallery')
        .select('id, file_path, title, picture_date')
        .eq('child_id', childId)
        .order('picture_date', ascending: false)
        .limit(10);

    final memories = gallery.map<Memory>((g) {
      final dateStr = g['picture_date']?.toString() ?? '';
      return Memory(
        id: g['id'] as String,
        imageUrl: g['file_path'] as String? ?? '',
        title: g['title'] as String? ?? '',
        date: dateStr,
      );
    }).toList();

    // 6) Growth summary (latest)
    // Growth: filter by child and user; fallback to child-only
    // Debug: who's querying
    // ignore: avoid_print
    print('[home] growth query using userId=$userId, childId=$childId');
    var growthRows = await client
        .from('growth')
        .select(
          'date, height, weight, head_circumference, unit_height, unit_weight, unit_head_circ',
        )
        .eq('child_id', childId)
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(1);
    // ignore: avoid_print
    print('[home] growth rows (child+user) => ${growthRows.length}');
    if (growthRows.isEmpty) {
      growthRows = await client
          .from('growth')
          .select(
            'date, height, weight, head_circumference, unit_height, unit_weight, unit_head_circ',
          )
          .eq('child_id', childId)
          .order('date', ascending: false)
          .limit(1);
      // ignore: avoid_print
      print('[home] growth rows (child only) => ${growthRows.length}');
    }
    GrowthSummary? growthSummary;
    if (growthRows.isNotEmpty) {
      final r = growthRows.first as Map;
      growthSummary = GrowthSummary(
        height: (r['height'] != null
            ? '${r['height']} ${r['unit_height'] ?? ''}'.trim()
            : null),
        weight: (r['weight'] != null
            ? '${r['weight']} ${r['unit_weight'] ?? ''}'.trim()
            : null),
        headCircumference: (r['head_circumference'] != null
            ? '${r['head_circumference']} ${r['unit_head_circ'] ?? ''}'.trim()
            : null),
        date: (r['date']?.toString()) ?? '',
      );
    } else {
      growthSummary = GrowthSummary(
        height: null,
        weight: null,
        headCircumference: null,
        date: '',
      );
    }

    final avgSleep = await _computeAverageSleep(client, childId);
    final feedingsPerDay = await _computeFeedingPerDay(client, childId);
    final stats = <Stat>[
      Stat(
        title: 'Sleep',
        subtitle: 'Avg. Sleep',
        value: avgSleep,
        icon: 'time',
      ),
      Stat(
        title: 'Feeding',
        subtitle: 'Avg. Feeding',
        value: feedingsPerDay,
        icon: 'feeding',
      ),
      if (profile.bloodType != null && profile.bloodType!.isNotEmpty)
        Stat(
          title: 'Blood',
          subtitle: 'Blood Type',
          value: profile.bloodType!,
          icon: 'hospital',
        ),
      if (growthSummary.weight != null && growthSummary.weight!.isNotEmpty)
        Stat(
          title: 'Weight',
          subtitle: 'Latest',
          value: growthSummary.weight!,
          icon: 'feeding',
        ),
    ];

    return HomeData(
      profile: profile,
      stats: stats,
      logs: logs.take(4).toList(),
      schedule: schedule,
      memories: memories,
      growthSummary: growthSummary,
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  // _formatDuration removed; checklist-based logs no longer need it

  static String _mapAppointmentTypeToIcon(String type) {
    switch (type) {
      case 'medication':
        return 'medication';
      case 'hospital':
        return 'hospital';
      case 'checkup':
        return 'hospital';
      default:
        return 'hospital';
    }
  }

  static Future<String> _computeAverageSleep(
    SupabaseClient client,
    String childId,
  ) async {
    final List<Map<String, dynamic>> rows = List<Map<String, dynamic>>.from(
      await client
          .from('sleep')
          .select('start_time, end_time')
          .eq('child_id', childId)
          .order('start_time', ascending: false)
          .limit(20),
    );
    if (rows.isEmpty) return '--';
    final durations = rows
        .map<Duration>((r) {
          final s = r['start_time'] as String;
          final e = r['end_time'] as String?;
          if (e == null) return Duration.zero;
          return DateTime.parse(e).difference(DateTime.parse(s));
        })
        .where((d) => d > Duration.zero)
        .toList();
    if (durations.isEmpty) return '--';
    final avgMinutes =
        durations.map((d) => d.inMinutes).reduce((a, b) => a + b) /
        durations.length;
    final h = (avgMinutes ~/ 60);
    final m = (avgMinutes % 60).round();
    return '${h}h ${m}m';
  }

  static Future<String> _computeFeedingPerDay(
    SupabaseClient client,
    String childId,
  ) async {
    final rows = await client
        .from('meals')
        .select('meal_time')
        .eq('child_id', childId)
        .order('meal_time', ascending: false)
        .limit(50);
    if (rows.isEmpty) return '--';
    // naive grouping by date
    final map = <String, int>{};
    for (final r in rows) {
      final t = DateTime.parse(r['meal_time'] as String);
      final key = '${t.year}-${t.month}-${t.day}';
      map[key] = (map[key] ?? 0) + 1;
    }
    final avg = map.values.reduce((a, b) => a + b) / map.length;
    return '${avg.toStringAsFixed(1)}x/day';
  }
}
