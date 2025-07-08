
class Site {
  final String siteId;
  final String siteName;
  final double latitude;
  final double longitude;
  final double radius;
  final String? address;
  final bool isActive;

  Site({
    required this.siteId,
    required this.siteName,
    required this.latitude,
    required this.longitude,
    this.radius = 100, // 100m radius
    this.address,
    this.isActive = true,
  });

  String toStorageString() {
    return '$siteId|$siteName|$latitude|$longitude|$radius|${address ?? 
  ""}|$isActive';
  }

  static Site fromStorageString(String data) {
    final parts = data.split('|');
    return Site(
      siteId: parts[0],
      siteName: parts[1],
      latitude: double.parse(parts[2]),
      longitude: double.parse(parts[3]),
      radius: double.parse(parts[4]),
      address: parts[5].isEmpty ? null : parts[5],
      isActive: parts[6] == 'true',
    );
  }
}
