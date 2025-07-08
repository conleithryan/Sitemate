import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry.dart';
import '../widgets/tile_selector.dart';

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
                  } else if (selectedWorkType == 'Kerbing' ||
                      selectedWorkType == 'Shuttering') {
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
                      print(
                        'Meters Square: $savedMetersSquare, Cubic: $savedMetersCubic',
                      );
                    } else if (savedWorkType == 'Bases') {
                      print(
                        'Bases cubic: $savedMetersCubic, quantity: $savedQuantity',
                      );
                    } else if (savedWorkType == 'Foundations') {
                      print(
                        'Meters Square: $savedMetersSquare, Cubic: $savedMetersCubic',
                      );
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
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
