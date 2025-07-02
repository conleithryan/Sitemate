import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

// Entry point of the app - this runs first
void main() {
  runApp(const Sitemate());
}

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
    return '${workType}|${footpathType ?? ""}|${metersSquare ?? ""}|${metersCubic ?? ""}|${metersTotal ?? ""}|${quantity ?? ""}|${hours ?? ""}|${dateTime.toIso8601String()}';
  }

  // Creates a WorkEntry from a saved string (opposite of toStorageString)
  static WorkEntry fromStorageString(String data) {
    final parts = data.split('|');
    // Ensure we have at least 8 parts
    if (parts.length < 8) {
      throw FormatException('Invalid work entry data: expected 8 parts, got ${parts.length}');
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

// Main app widget - sets up the app theme and home page
class Sitemate extends StatelessWidget {
  const Sitemate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ), // Orange theme for construction
      home: HomeScreen(), // First screen users see
    );
  }
}

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

/// Home screen with the START WORK LOG button
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

  class _HomeScreenState extends State<HomeScreen> {
  String? currentSiteName;

  @override
  void initState() {
    super.initState();
    _detectCurrentSite();
  }

  Future<void> _detectCurrentSite() async {
    // Check location permission
    if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition();

      // Load sites and check which one we're at
      final prefs = await SharedPreferences.getInstance();
      final siteStrings = prefs.getStringList('sites') ?? [];
      
      for (String siteString in siteStrings) {
        final site = Site.fromStorageString(siteString);
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          site.latitude,
          site.longitude,
        );

        if (distance <= site.radius && site.isActive) {
          setState(() {
            currentSiteName = site.siteName;
          });
          break;
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sitemate'), backgroundColor: Colors.orange),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Current site indicator
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    currentSiteName != null ? 'At: $currentSiteName' : 'No site detected',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Start work log button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddWorkScreen()),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('START WORK LOG', style: TextStyle(fontSize: 20)),
              ),
            ),

            SizedBox(height: 20),

            // Time tracker button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => _TimeTrackerScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('TIME TRACKER', style: TextStyle(fontSize: 20)),
              ),
            ),

            SizedBox(height: 20),

            // View work entries
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewWorkScreen()),
                    );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'VIEW WORK ENTRIES',
                  style: TextStyle(fontSize: 20)),
              ),
            ),

            SizedBox(height: 20),

            // Manage sites button
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SiteManagementScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('MANAGE SITES', style: TextStyle(fontSize: 20))
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for tile selectors (work type, footpath type)
Widget buildTileSelector({
  required String label, // Text above tiles
  required List<String> options, // List of choices
  required String? selectedValue, // Currently selected option
  required Function(String) onSelected, // What to do when tile tapped
  Map<String, Color>? colorMap, // Colors for each option
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align label to left
    children: [
      // Label text
      Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(height: 10),

      // Horizontal scrolling list of tiles
      SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Scroll left/right
          itemCount: options.length,
          itemBuilder: (context, index) {
            String option = options[index];
            bool isSelected = selectedValue == option;
            Color tileColor =
                colorMap?[option] ??
                Colors.orange; // Use color from map or orange

            return Padding(
              padding: EdgeInsets.only(right: 8), // Space between tiles
              child: GestureDetector(
                onTap: () => onSelected(option), // Call function when tapped
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? tileColor
                        : Colors.grey[200], // Color based on selection
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // Rounded corners
                    border: Border.all(
                      color: isSelected ? tileColor : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

// Screen where workers log their work
// StatefulWidget because it has changing data (form fields)
class AddWorkScreen extends StatefulWidget {
  const AddWorkScreen({super.key});

  @override
  _AddWorkScreenState createState() => _AddWorkScreenState();
}

// The state (data) for AddWorkScreen
class _AddWorkScreenState extends State<AddWorkScreen> {
  // Form field variables - these store what the user enters
  String? selectedWorkType;
  String? selectedFootpathType;
  String metersSquare = '';
  String metersCubic = '';
  String metersTotal = '';
  String quantity = '';
  String hours = '';
  String? errorMessage;
  String? successMessage;
  // List of work types to show in the selector
  final List<String> workTypes = [
    'Footpaths',
    'Bases',
    'Foundations',
    'Kerbing',
    'Shuttering',
    'Manholes',
    'Day Works',
    'Base Prep',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Work'), backgroundColor: Colors.orange),
      body: Padding(
        padding: EdgeInsets.all(16), // Space around entire form
        child: Column(
          children: [
            // Work type selector (horizontal scrolling tiles)
            buildTileSelector(
              label: 'Work Type:',
              options: workTypes,
              selectedValue: selectedWorkType,
              onSelected: (value) {
                setState(() {
                  selectedWorkType = value;
                  successMessage =
                      null; // Clear messages when selecting new type
                  errorMessage = null;
                });
              },
              colorMap: {
                'Footpaths': Colors.blue,
                'Bases': Colors.orange,
                'Foundations': Colors.brown,
                'Kerbing': Colors.purple,
                'Shuttering': Colors.teal,
                'Manholes': Colors.indigo,
                'Day Works': Colors.green,
                'Base Prep': Colors.red,
              },
            ),

            // Success message box (shows after successful save)
            if (successMessage != null) ...[
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        successMessage!,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Show footpath-specific fields when Footpaths is selected
            if (selectedWorkType == 'Footpaths') ...[
              SizedBox(height: 20),
              buildTileSelector(
                label: 'Select Footpath Type:',
                options: ['Main', 'Housing'],
                selectedValue: selectedFootpathType,
                onSelected: (value) {
                  setState(() {
                    selectedFootpathType = value;
                  });
                },
                colorMap: {
                  'Main': Colors.blue[700]!,
                  'Housing': Colors.blue[400]!,
                },
              ),
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Square Meters (m²)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number, 
                onChanged: (value) {
                  metersSquare = value;
                },
              ),
              SizedBox(height:20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Cubic Meters (m³)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number, 
                onChanged: (value) {
                  metersCubic = value;
                },
              ),
            ],

            // Show bases-specific fields when Bases is selected
            if (selectedWorkType == 'Bases') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Cubic Meters (m³)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  metersCubic = value;
                },
              ),

              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = value;
                },
              ),
            ],

            if (selectedWorkType == 'Foundations') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Square Meters (m²)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  metersSquare = value;
                },
              ),

              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Cubic Meters (m³)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  metersCubic = value;
                },
              ),
            ],

            if (selectedWorkType == 'Kerbing') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Meters Total',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  metersTotal = value;
                },
              ),
            ],

            if (selectedWorkType == 'Shuttering') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Meters Total',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  metersTotal = value;
                },
              ),
            ],

            if (selectedWorkType == 'Manholes') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = value;
                },
              ),
            ],

            if (selectedWorkType == 'Day Works') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  hours = value;
                },
              ),
            ],

            if (selectedWorkType == 'Base Prep') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Square Meters (m²) - Insulation and Mesh',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  metersSquare = value;
                },
              ),
            ],

            // Show save button only when a work type is selected
            if (selectedWorkType != null) ...[
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Validation flags
                  bool canSave = true;
                  String error = '';

                  // Validate based on selected work type
                  if (selectedWorkType == 'Footpaths') {
                    if (selectedFootpathType == null) {
                      canSave = false;
                      error = 'Please enter footpath type';
                    } else if (metersSquare.isEmpty || metersCubic.isEmpty) {
                      canSave = false;
                      error = 'Please enter both square and cubic meters';
                    }
                  } else if (selectedWorkType == 'Bases') {
                    if (metersCubic.isEmpty || quantity.isEmpty) {
                      canSave = false;
                      error = 'Please enter both cubic meters and quantity';
                    }
                  } else if (selectedWorkType == 'Foundations') {
                    if (metersCubic.isEmpty || metersSquare.isEmpty) {
                      canSave = false;
                      error = 'Please enter both square and cubic meters';
                    }
                  } else if (selectedWorkType == 'Kerbing' || selectedWorkType == 'Shuttering') {
                    if (metersTotal.isEmpty) {
                      canSave = false;
                      error = 'Please enter meters total';
                    }
                  } else if (selectedWorkType == 'Manholes') {
                    if (quantity.isEmpty) {
                      canSave = false;
                      error = 'Please enter quantity';
                    } 
                  } else if (selectedWorkType == 'Day Works') {
                    if (hours.isEmpty) {
                      canSave = false;
                      error = 'Please enter hours';
                    }
                  } else if (selectedWorkType == 'Base Prep') {
                    if (metersSquare.isEmpty) {
                      canSave = false;
                      error = 'Please enter meters square';
                    }
                  }

                  if (canSave) {
                    // Store values before clearing (we need them for saving)
                    final savedWorkType = selectedWorkType;
                    final savedFootpathType = selectedFootpathType;
                    final savedMetersSquare = metersSquare;
                    final savedMetersCubic = metersCubic;
                    final savedMetersTotal = metersTotal;
                    final savedQuantity = quantity;
                    final savedHours = hours;

                    // Update UI - clear form and show success
                    setState(() {
                      errorMessage = null;
                      successMessage = 'Work entry saved!';

                      // Clear all form fields for next entry
                      selectedWorkType = null;
                      selectedFootpathType = null;
                      metersSquare = '';
                      metersCubic = '';
                      metersTotal = '';
                      quantity = '';
                      hours = '';
                    });

                    // Save to device storage
                    saveWorkEntry(
                      workType: savedWorkType!,
                      footpathType: savedFootpathType,
                      metersSquare: savedMetersSquare,
                      metersCubic: savedMetersCubic,
                      metersTotal: savedMetersTotal,
                      quantity: savedQuantity,
                      hours: savedHours,
                    );

                    // Hide success message after 2 seconds
                    Future.delayed(Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          successMessage = null;
                        });
                      }
                    });

                    // Debug prints
                    print('✅ Saving work entry...');
                    print('Work type: $savedWorkType');

                    if (savedWorkType == 'Footpaths') {
                      print('Footpath type: $savedFootpathType');
                      print('Meters Square: $savedMetersSquare, Cubic: $savedMetersCubic');
                    } else if (savedWorkType == 'Bases') {
                      print('Bases cubic: $savedMetersCubic, quantity: $savedQuantity');
                    } else if (savedWorkType == 'Foundations') {
                      print('Meters Square: $savedMetersSquare, Cubic: $savedMetersCubic');
                    } else if (savedWorkType == 'Kerbing') {
                      print('Meters Total: $savedMetersTotal');
                    } else if (savedWorkType == 'Manholes') {
                      print('Quantity: $savedQuantity');
                    } else if (savedWorkType == 'Day Works') {
                      print('Hours: $savedHours');
                    } else if (savedWorkType == 'Base Prep') {
                      print('Meters Square: $savedMetersSquare');
                    }
                  } else {
                    // Show error message 
                    setState(() {
                      errorMessage = error;
                    });
                    print('❌ Cannot save: $errorMessage');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                ),
                child: Text('SAVE ENTRY', style: TextStyle(fontSize: 18)),
              ),

              // Error message box (shows validation errors)
              if (errorMessage != null) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }


  // Function to save work entry to device storage
  Future<void> saveWorkEntry({
    required String workType,
    String? footpathType,
    String? metersSquare,
    String? metersCubic,
    String? metersTotal,
    String? quantity,
    String? hours,
  }) async {
    // Create a WorkEntry object with current time
    final entry = WorkEntry(
      workType: workType,
      footpathType: footpathType,
      metersSquare: metersSquare,
      metersCubic: metersCubic,
      metersTotal: metersTotal,
      quantity: quantity,
      hours: hours,
      dateTime: DateTime.now(),
    );

    // Get the storage instance (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();

    // Get existing saved entries (or empty list if none)
    final existingEntries = prefs.getStringList('work_entries') ?? [];

    // Add the new entry as a string
    existingEntries.add(entry.toStorageString());

    // Save the updated list back to storage
    await prefs.setStringList('work_entries', existingEntries);

    print('📱 Saved to device: ${entry.toStorageString()}');
  }
}

// Screen to view all saved work entries
class ViewWorkScreen extends StatefulWidget {
  const ViewWorkScreen({super.key});

  @override
  _ViewWorkScreenState createState() => _ViewWorkScreenState();
}

class _ViewWorkScreenState extends State<ViewWorkScreen> {
  List<WorkEntry> entries = []; // List to hold loaded entries
  bool isLoading = true; // Show loading indicator while reading

  @override
  void initState() {
    super.initState();
    loadEntries(); // Load entries when screen opens
  }

  // Load saved entries from storage
  Future<void> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEntries = prefs.getStringList('work_entries') ?? [];

      print('Loading ${savedEntries.length} entries'); // Debug print

      List<WorkEntry> parsedEntries = [];
      for (String entryString in savedEntries) {
        try {
          print('Parsing: $entryString');
          parsedEntries.add(WorkEntry.fromStorageString(entryString));
        } catch (e) {
          print('Error parsing entry: $e');
        }
      }

      setState(() {
        entries = parsedEntries.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading entries: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Format date for display
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    try {
      print('Building ViewWorkScreen - entries count: ${entries.length}');

      return Scaffold(
        appBar: AppBar(
          title: Text('Work Entries'),
          backgroundColor: Colors.orange,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : entries.isEmpty
            ? Center(
                child: Text(
                  'No work entries yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  try {
                    final entry = entries[index];
                    print('Building entry $index: ${entry.workType}');

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Simplified version for testing
                            Text(
                              'Type: ${entry.workType}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Date: ${formatDate(entry.dateTime)}'),

                            if (entry.workType == 'Footpaths') ...[
                              Text('Footpath Type: ${entry.footpathType ?? "N/A"}'),
                              Text('Square Meters: ${entry.metersSquare ?? "N/A"}'),
                              Text('Cubic Meters: ${entry.metersCubic ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Bases') ...[
                              Text('Cubic Meters: ${entry.metersCubic ?? "N/A"}'),
                              Text('Quantity: ${entry.quantity ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Foundations') ...[
                              Text('Square Meters: ${entry.metersSquare ?? "N/A"}'),
                              Text('Cubic Meters: ${entry.metersCubic ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Kerbing') ...[
                              Text('Meters Total: ${entry.metersTotal ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Shuttering') ...[
                              Text('Meters Total: ${entry.metersTotal ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Manholes') ...[
                              Text('Quantity: ${entry.quantity ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Day Works') ...[
                              Text('Hours: ${entry.hours ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Base Prep') ...[
                              Text('Square Meters: ${entry.metersSquare ?? "N/A"}'),
                            ],
                            
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to edit screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditWorkScreen(
                                          entry: entry,
                                          entryIndex: index,
                                        ),
                                      ),
                                    ).then((_) => loadEntries()); //Reload entries when returning
                                  },
                                  icon: Icon(Icons.edit, size: 16),
                                  label: Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Show delete confirmation dialog
                                    _showDeleteDialog(context, index);
                                  },
                                  icon: Icon(Icons.delete, size: 16),
                                  label: Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              );
                  } catch (e) {
                    print('Error building item $index: $e');
                    return Text('Error displaying entry');
                  }
                },
              ),
      );
    } catch (e) {
      print('Error in build method: $e');
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Error: $e')),
      );
    }
  }


  // Show delete confirmation dialog
  Future<void> _showDeleteDialog(BuildContext context,
    int index) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Work Entry'),
            content: Text('Are you sure you want to delete this work entry? This action cannot be undone.' ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await _deleteEntry(index);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    // Delete entry from storage
  Future<void> _deleteEntry(int index) async {
    try {
      final prefs = await
  SharedPreferences.getInstance();
      final savedEntries =
  prefs.getStringList('work_entries') ?? [];

      // Remove the entry at the specified index
      if (index >= 0 && index < entries.length) {
        // Since entries are reversed, calculate the actual index
        int actualIndex = savedEntries.length - 1 -
  index;
        savedEntries.removeAt(actualIndex);

        // Save the updated list
        await prefs.setStringList('work_entries',
  savedEntries);

        // Reload the entries to update the UI
        await loadEntries();
      }
    } catch (e) {
      print('Error deleting entry: $e');
    }
  }
}

// Screen to edit existing work entries
  class EditWorkScreen extends StatefulWidget {
    final WorkEntry entry;
    final int entryIndex;

    const EditWorkScreen({
      super.key,
      required this.entry,
      required this.entryIndex,
    });

    @override
    _EditWorkScreenState createState() => _EditWorkScreenState();
  }

  class _EditWorkScreenState extends State<EditWorkScreen> {
    // Form field variables
    late String selectedWorkType;
    String? selectedFootpathType;
    String metersSquare = '';
    String metersCubic = '';
    String metersTotal = '';
    String quantity = '';
    String hours = '';
    String? errorMessage;
    String? successMessage;

    @override
    void initState() {
      super.initState();
      // Initialize fields with existing entry data
      selectedWorkType = widget.entry.workType;
      selectedFootpathType = widget.entry.footpathType;
      metersSquare = widget.entry.metersSquare ?? '';
      metersCubic = widget.entry.metersCubic ?? '';
      metersTotal = widget.entry.metersTotal ?? '';
      quantity = widget.entry.quantity ?? '';
      hours = widget.entry.hours ?? '';
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Work Entry'),
          backgroundColor: Colors.orange,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Display the work type (read-only)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color:Colors.grey[400]!),
                ),
                child: Row(
                  children: [
                    Text(
                      'Work Type: ',
                      style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      selectedWorkType,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Work type specific fields
              if (selectedWorkType == 'Footpaths') ...[
                buildTileSelector(
                  label: 'Select Footpath Type:',
                  options: ['Main', 'Housing'],
                  selectedValue: selectedFootpathType,
                  onSelected: (value) {
                    setState(() {
                      selectedFootpathType = value;
                    });
                  },
                  colorMap: {
                    'Main': Colors.blue[700]!,
                    'Housing': Colors.blue[400]!,
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Square Meters (m²)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: metersSquare),
                  onChanged: (value) {
                    metersSquare = value;
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cubic Meters (m³)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: metersCubic),
                  onChanged: (value) {
                    metersCubic = value;
                  },
                ),
              ],

              if (selectedWorkType == 'Bases') ...[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cubic Meters (m³)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: metersCubic),
                  onChanged: (value) {
                    metersCubic = value;
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: quantity),
                  onChanged: (value) {
                    quantity = value;
                  },
                ),
              ],

              if (selectedWorkType == 'Foundations') ...[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Square Meters (m²)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: metersSquare),
                  onChanged: (value) {
                    metersSquare = value;
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cubic Meters (m³)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: metersCubic),
                  onChanged: (value) {
                    metersCubic = value;
                  },
                ),
              ],

              if (selectedWorkType == 'Kerbing' || selectedWorkType == 'Shuttering') ...[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Meters Total',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: metersTotal),
                  onChanged: (value) {
                    metersTotal = value;
                  },
                ),
              ],

              if (selectedWorkType == 'Manholes') ...[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: quantity),
                  onChanged: (value) {
                    quantity = value;
                  },
                ),
              ],

              if (selectedWorkType == 'Day Works') ...[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: hours),
                  onChanged: (value) {
                    hours = value;
                  },
                ),
              ],

              if (selectedWorkType == 'Base Prep') ...[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Square Meters (m²) - Insulation and Mesh',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: metersSquare),
                  onChanged: (value) {
                    metersSquare = value;
                  },
                ),
              ],

              // Update button
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  // Validation logic
                  bool canSave = true;
                  String error = '';

                  // Validate based on selected work type
                  if (selectedWorkType == 'Footpaths') {
                    if (selectedFootpathType == null) {
                      canSave = false;
                      error = 'Please select footpath type';
                    } else if (metersSquare.isEmpty || metersCubic.isEmpty) {
                      canSave = false;
                      error = 'Please enter both square and cubic meters';
                    }
                  } else if (selectedWorkType == 'Bases') {
                    if (metersCubic.isEmpty ||quantity.isEmpty) {
                      canSave = false;
                      error = 'Please enter both cubic meters and quantity';
                    }
                  } else if (selectedWorkType == 'Foundations') {
                    if (metersCubic.isEmpty || metersSquare.isEmpty) {
                      canSave = false;
                      error = 'Please enter both square and cubic meters';
                    }
                  } else if (selectedWorkType == 'Kerbing' || selectedWorkType == 'Shuttering') {
                    if (metersTotal.isEmpty) {
                      canSave = false;
                      error = 'Please enter meters total';
                    }
                  } else if (selectedWorkType == 'Manholes') {
                    if (quantity.isEmpty) {
                      canSave = false;
                      error = 'Please enter quantity';
                    }
                  } else if (selectedWorkType == 'Day Works') {
                    if (hours.isEmpty) {
                      canSave = false;
                      error = 'Please enter hours';
                    }
                  } else if (selectedWorkType == 'Base Prep') {
                    if (metersSquare.isEmpty) {
                      canSave = false;
                      error = 'Please enter square meters';
                    }
                  }

                  if (canSave) {
                    await _updateEntry();
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      errorMessage = error;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Text('UPDATE ENTRY', style: TextStyle(fontSize: 18)),
              ),

              // Error message display
              if (errorMessage != null) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red[700], fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }


    // Update entry in storage
    Future<void> _updateEntry() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEntries = prefs.getStringList('work_entries') ?? [];

        // Calculate actual index (accounting for  reversed display)
        int actualIndex = savedEntries.length - 1 - widget.entryIndex;

        // Create updated entry
        final updatedEntry = WorkEntry(
          workType: selectedWorkType,
          footpathType: selectedFootpathType,
          metersSquare: metersSquare.isEmpty ? null : metersSquare,
          metersCubic: metersCubic.isEmpty ? null : metersCubic,
          metersTotal: metersTotal.isEmpty ? null : metersTotal,
          quantity: quantity.isEmpty ? null : quantity,
          hours: hours.isEmpty ? null : hours,
          dateTime: widget.entry.dateTime, // Keep original timestamp
        );

        // Replace the entry
        savedEntries[actualIndex] = updatedEntry.toStorageString();

        // Save back to storage
        await prefs.setStringList('work_entries', savedEntries);

        print('✅ Entry updated successfully');
      } catch (e) {
        print('Error updating entry: $e');
      }
    }
  }

  class _TimeTrackerScreen extends StatefulWidget {
    @override
    _TimeTrackerScreenState createState() => _TimeTrackerScreenState();
  }

  class SiteManagementScreen extends StatefulWidget {
    @override
    _SiteManagementScreenState createState() => _SiteManagementScreenState();
  }

  class _SiteManagementScreenState extends State<SiteManagementScreen> {
    List<Site> sites = [];

    @override
    void initState() {
      super.initState();
      _loadSites();
    }

    Future<void> _loadSites() async {
      final prefs = await SharedPreferences.getInstance();
      final siteStrings = prefs.getStringList('sites') ?? [];
      setState(() {
        sites = siteStrings.map((s) => Site.fromStorageString(s)).toList();
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Manage Sites'),
          backgroundColor: Colors.purple,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: sites.length,
          itemBuilder: (context, index) {
            final site = sites[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: site.isActive ? Colors.green : Colors.grey,
                ),
                title: Text(site.siteName),
                subtitle: Text(site.address ?? 'No address'),
                trailing: Switch(
                  value: site.isActive,
                  onChanged: (value) {
                    // Toggle active status
                  },
                ),
                onTap: () {
                  // Edit site
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddSiteScreen()),
            ).then((_) => _loadSites());
          },
          backgroundColor: Colors.purple,
          child: Icon(Icons.add),
        ),
      );
    }
  }

  class AddSiteScreen extends StatefulWidget {
    @override
    _AddSiteScreenState createState() => _AddSiteScreenState();
  }

  class _AddSiteScreenState extends State<AddSiteScreen> {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController radiusController = TextEditingController(text:
  '100');

    Position? currentPosition;
    bool isLoading = false;

    Future<void> _getCurrentLocation() async {
      setState(() {
        isLoading = true;
      });

      if (await Permission.location.request().isGranted) {
        try {
          Position position = await Geolocator.getCurrentPosition();
          setState(() {
            currentPosition = position;
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }

    Future<void> _saveSite() async {
      if (nameController.text.isEmpty || currentPosition == null) {
        return;
      }

      final site = Site(
        siteId: DateTime.now().millisecondsSinceEpoch.toString(),
        siteName: nameController.text,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        radius: double.tryParse(radiusController.text) ?? 100,
        address: addressController.text.isEmpty ? null :
  addressController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      final sites = prefs.getStringList('sites') ?? [];
      sites.add(site.toStorageString());
      await prefs.setStringList('sites', sites);

      Navigator.pop(context);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Add Site'),
          backgroundColor: Colors.purple,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Site Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: radiusController,
                decoration: InputDecoration(
                  labelText: 'Detection Radius (meters)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              if (currentPosition == null)
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _getCurrentLocation,
                  icon: isLoading ? CircularProgressIndicator() :
  Icon(Icons.location_on),
                  label: Text('Get Current Location'),
                )
              else
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Location captured!'),
                        Text('Lat: ${currentPosition!.latitude.toStringAsFixed(6)}'),
                        Text('Lng: ${currentPosition!.longitude.toStringAsFixed(6)}'),
                      ],
                    ),
                  ),
                ),

              Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: currentPosition != null &&
  nameController.text.isNotEmpty
                    ? _saveSite
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.all(16),
                  ),
                  child: Text('SAVE SITE', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  class _TimeTrackerScreenState extends State<_TimeTrackerScreen> {
    DateTime selectedDate = DateTime.now();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String? selectedSiteId;
    String? selectedSiteName;
    int breakMinutes = 0;
    List<Site> sites = [];
    String? errorMessage;

    @override
    void initState() {
      super.initState();
      _loadSites();
      _checkCurrentSite();
    }

    Future<void> _loadSites() async {
      final prefs = await SharedPreferences.getInstance();
      final siteStrings = prefs.getStringList('sites') ?? [];
      setState(() {
        sites = siteStrings.map((s) => Site.fromStorageString(s)).where((s) => s.isActive).toList();
      });
    }

    Future<void> _checkCurrentSite() async {
      // Only auto-detect if date is today
      if (selectedDate.day == DateTime.now().day && selectedDate.month == DateTime.now().month && selectedDate.year == DateTime.now().year) {
        if (await Permission.location.request().isGranted) {
          Position position = await Geolocator.getCurrentPosition();

          for (Site site in sites) {
            double distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              site.latitude,
              site.longitude,
            );

            if (distance <= site.radius) {
              setState (() {
                selectedSiteId = site.siteId;
                selectedSiteName = site.siteName;
              });
              break;
            }
          }
        }
      }
    }

    @override 
    Widget build (BuildContext context) {
      return Scaffold(
        appBar : AppBar(
          title: Text('Time Tracker'),
          backgroundColor: Colors.green,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selector
              Card(
                child: ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Date'),
                  subtitle: Text(DateFormat('EEEE, MMMM, d, y').format(selectedDate)),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        selectedSiteId = null;
                        selectedSiteName = null;
                      });
                      _checkCurrentSite();
                    }
                  },
                ),
              ),

              SizedBox(height: 16),

              // Site selector
              Card(
                child: ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Site'),
                  subtitle: Text(selectedSiteName ?? 'Select site'),
                  onTap: () {
                    _showSiteSelector();
                  },
                ),
              ),

              // Time inputs
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.login),
                        title: Text('Start'),
                        subtitle: Text(
                          startTime != null
                          ? startTime!.format(context)
                          : 'Set time'
                        ),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: startTime ?? TimeOfDay(hour: 8, minute: 00),
                          );
                          if (picked != null) {
                            setState(() {
                              startTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('End'),
                        subtitle: Text(
                          endTime != null
                          ? endTime!.format(context)
                          : 'Set time'
                        ),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: endTime ?? TimeOfDay(hour: 17, minute: 00),
                          );
                          if (picked != null) {
                            setState(() {
                              endTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(height: 16),

              // Break time
              Card(
                child: ListTile(
                  leading: Icon(Icons.coffee),
                  title: Text('Break (minutes)'),
                  subtitle: Text('$breakMinutes minutes'),
                  onTap: () {
                    _showBreakSelector();
                  },
                ),
              ),

              SizedBox(height: 16),

              // Quick buttons
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        startTime = TimeOfDay(hour: 8, minute: 0);
                        endTime = TimeOfDay(hour: 17, minute: 00);
                        breakMinutes = 45;
                      });
                    },
                    child: Text('Copy Yesterday'),
                  ),
                ],
              ),

              Spacer(),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTimeEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.all(16),
                  ),
                  child: Text('SAVE TIME ENTRY', style: TextStyle(fontSize: 18)),
                ),
              ),
              if(errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red,)
                ),
              ),
            ]
          ),
        ),
      );
    }

    void _showSiteSelector() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Site'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sites.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: Icon(Icons.business),
                    title: Text('Office/No Site'),
                    onTap: () {
                      setState(() {
                        selectedSiteId = null;
                        selectedSiteName = 'Office';
                      });
                      Navigator.pop(context);
                    },
                  );
                }

                final site = sites[index -1];
                return ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(site.siteName),
                  subtitle: site.address != null ? Text(site.address!) : null,
                  onTap: () {
                    setState(() {
                      selectedSiteId = site.siteId;
                      selectedSiteName = site.siteName;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ),
          ),
        );
      }

      void _showBreakSelector() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Break Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [0, 15, 30, 45, 60].map((minutes) {
              return ListTile(
                title: Text('$minutes minutes'),
                onTap: () {
                  setState(() {
                    breakMinutes = minutes;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      );
    }

      Future<void> _saveTimeEntry() async {
        // Validation
        if (startTime == null || endTime == null) {
          setState(() {
            errorMessage = 'Please set start and end times';
          });
          return;
        }

        // Create Datetime objects
        final clockIn = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          startTime!.hour,
          startTime!.minute,
        );
        final clockOut = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          endTime!.hour,
          endTime!.minute,
        );

        // Create time entry
        final entry = TimeEntry(
          date: selectedDate,
          clockIn: clockIn,
          clockOut: clockOut,
          siteId: selectedSiteId,
          siteName: selectedSiteName,
          breakMinutes: breakMinutes,
        );

        // Save to storage
        final prefs = await SharedPreferences.getInstance();
        final existingEntries = prefs.getStringList('time_entries') ?? [];
        existingEntries.add(entry.toStorageString());
        await prefs.setStringList('time_entries', existingEntries);

        // Navigate back
        Navigator.pop(context);
      }
  }
