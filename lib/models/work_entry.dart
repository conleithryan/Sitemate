// Class to represent a single work entry
class WorkEntry {
  final String workType;
  final String? footpathType;
  final String? metersSquare;
  final String? metersCubic;
  final String? metersTotal;
  final String? quantity;
  final String? hours;
  final DateTime dateTime;

  // Constructor - creates a new WorkEntry object
  WorkEntry({
    required this.workType,
    this.footpathType,
    this.metersSquare,
    this.metersCubic,
    this.metersTotal,
    this.quantity,
    this.hours,

    required this.dateTime,
  });

  // Converts the work entry to a string so we can save it
  String toStorageString() {
    return '$workType|${footpathType ?? ""}|${metersSquare ?? ""}|${metersCubic ?? ""}|${metersTotal ?? ""}|${quantity ?? ""}|${hours ?? ""}|${dateTime.toIso8601String()}';
  }

  // Creates a WorkEntry from a saved string (opposite of toStorageString)
  static WorkEntry fromStorageString(String data) {
    final parts = data.split('|');
    // Ensure we have at least 8 parts
    if (parts.length < 8) {
      throw FormatException(
        'Invalid work entry data: expected 8 parts, got ${parts.length}',
      );
    }
    return WorkEntry(
      workType: parts[0],
      footpathType: parts[1].isEmpty ? null : parts[1],
      metersSquare: parts[2].isEmpty ? null : parts[2],
      metersCubic: parts[3].isEmpty ? null : parts[3],
      metersTotal: parts[4].isEmpty ? null : parts[4],
      quantity: parts[5].isEmpty ? null : parts[5],
      hours: parts[6].isEmpty ? null : parts[6],
      dateTime: DateTime.parse(parts[7]),
    );
  }
}
