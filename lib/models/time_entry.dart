
class TimeEntry {
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final String? siteId;
  final String? siteName;
  final int breakMinutes;

  TimeEntry({
    required this.date,
    this.clockIn, 
    this.clockOut,
    this.siteId,
    this.siteName,
    this.breakMinutes = 0,
  });

  // Calculate total hours worked
  double get totalHours {
    if (clockIn == null || clockOut == null) return 0;
    final duration = clockOut!.difference(clockIn!);
    final totalMinutes = duration.inMinutes - breakMinutes;
    return totalMinutes / 60;
  }

  String toStorageString() {
    return '${date.toIso8601String()}|${clockIn?.toIso8601String() ?? 
  ""}|${clockOut?.toIso8601String() ?? ""}|${siteId ?? ""}|${siteName ?? 
  ""}|$breakMinutes';
  }

  static TimeEntry fromStorageString(String data) {
    final parts = data.split('|');
    return TimeEntry(
      date: DateTime.parse(parts[0]),
      clockIn: parts[1].isEmpty ? null : DateTime.parse(parts[1]),
        clockOut: parts[2].isEmpty ? null : DateTime.parse(parts[2]),
        siteId: parts[3].isEmpty ? null : parts[3],
        siteName: parts[4].isEmpty ? null : parts[4],
        breakMinutes: int.tryParse(parts[5]) ?? 0,
    );
  }
}
