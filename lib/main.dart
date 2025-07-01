import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Package for storing data on device

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