import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Package for storing data on device

// Entry point of the app - this runs first
void main() {
  runApp(const Sitemate());
}

// Class to represent a single work entry (like a form that was filled out)
class WorkEntry {
  final String workType; // Which type of work (Footpaths, Bases, etc)
  final String? footpathType; // Main or Housing (only for footpaths)
  final String? metersCompleted; // How many meters (only for footpaths)
  final String? basesQuantity; // How many bases (only for bases)
  final DateTime dateTime; // When this entry was created

  // Constructor - creates a new WorkEntry object
  WorkEntry({
    required this.workType, // required = must be provided
    this.footpathType, // optional (no required)
    this.metersCompleted, // optional
    this.basesQuantity, // optional
    required this.dateTime,
  });

  // Converts the work entry to a string so we can save it
  // Example output: "Footpaths|Main|50|null|2024-01-15T10:30:00"
  String toStorageString() {
    return '${workType}|${footpathType ?? ""}|${metersCompleted ?? ""}|${basesQuantity ?? ""}|${dateTime.toIso8601String()}';
  }

  // Creates a WorkEntry from a saved string (opposite of toStorageString)
  static WorkEntry fromStorageString(String data) {
    final parts = data.split('|'); // Split by | character
    return WorkEntry(
      workType: parts[0],
      footpathType: parts[1].isEmpty
          ? null
          : parts[1], // Convert 'null' string back to null
      metersCompleted: parts[2].isEmpty ? null : parts[2],
      basesQuantity: parts[3].isEmpty ? null : parts[3],
      dateTime: DateTime.parse(parts[4]), // Convert string back to DateTime
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

// Home screen with the START WORK LOG button
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sitemate'), backgroundColor: Colors.orange),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, //Center Vertically
          children: [
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

            SizedBox(height: 20), // Space between buttons
            // View work entries
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewWorkScreen()),
                    )
                    .then((_) {
                      // This runs when returning from ViewWorkScreen
                      print('Returned from ViewWorkScreen');
                    })
                    .catchError((error) {
                      print('Navigation error: $error');
                    });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'VIEW WORK ENTRIES',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  String metersCompleted = '';
  String basesQuantity = '';
  String? errorMessage;
  String? successMessage;
  // List of work types to show in the selector
  final List<String> workTypes = [
    'Footpaths',
    'Bases',
    'Foundations',
    'Kerbing',
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

              // Footpath type selector (Main or Housing)
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

              // Meters input field
              TextField(
                decoration: InputDecoration(
                  labelText: 'Meters Completed',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20), // Big touch target
                ),
                keyboardType: TextInputType.number, // Number keyboard
                onChanged: (value) {
                  metersCompleted = value; // Store what user types
                },
              ),
            ],

            // Show bases-specific fields when Bases is selected
            if (selectedWorkType == 'Bases') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Number of Bases Completed',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  basesQuantity = value;
                  print(
                    'Number of Bases Completed: $basesQuantity',
                  ); // Debug print
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
                    } else if (metersCompleted.isEmpty) {
                      canSave = false;
                      error = 'Please enter meters completed';
                    }
                  } else if (selectedWorkType == 'Bases') {
                    if (basesQuantity.isEmpty) {
                      canSave = false;
                      error = 'Please enter number of bases';
                    }
                  }

                  if (canSave) {
                    // Store values before clearing (we need them for saving)
                    final savedWorkType = selectedWorkType;
                    final savedFootpathType = selectedFootpathType;
                    final savedMeters = metersCompleted;
                    final savedBases = basesQuantity;

                    // Update UI - clear form and show success
                    setState(() {
                      errorMessage = null;
                      successMessage = 'Work entry saved!';

                      // Clear all form fields for next entry
                      selectedWorkType = null;
                      selectedFootpathType = null;
                      metersCompleted = '';
                      basesQuantity = '';
                    });

                    // Save to device storage
                    saveWorkEntry(
                      workType: savedWorkType!,
                      footpathType: savedFootpathType,
                      metersCompleted: savedMeters,
                      basesQuantity: savedBases,
                    );

                    // Hide success message after 2 seconds
                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        successMessage = null;
                      });
                    });

                    // Debug prints
                    print('✅ Saving work entry...');
                    print('Work type: $savedWorkType');

                    if (savedWorkType == 'Footpaths') {
                      print('Footpath type: $savedFootpathType');
                      print('Meters: $savedMeters');
                    } else if (savedWorkType == 'Bases') {
                      print('Bases quantity: $savedBases');
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
                  ), // Big button
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

  // Function to save work entry to device storage
  Future<void> saveWorkEntry({
    required String workType,
    String? footpathType,
    String? metersCompleted,
    String? basesQuantity,
  }) async {
    // Create a WorkEntry object with current time
    final entry = WorkEntry(
      workType: workType,
      footpathType: footpathType,
      metersCompleted: metersCompleted,
      basesQuantity: basesQuantity,
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
                              Text(
                                'Footpath Type: ${entry.footpathType ?? "N/A"}',
                              ),
                              Text('Meters: ${entry.metersCompleted ?? "N/A"}'),
                            ],
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

  // Helper to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Get color for work type (matching your selector colors)
  Color _getColorForWorkType(String workType) {
    switch (workType) {
      case 'Footpaths':
        return Colors.blue;
      case 'Bases':
        return Colors.orange;
      case 'Foundations':
        return Colors.brown;
      case 'Kerbing':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
