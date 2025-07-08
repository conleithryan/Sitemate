import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry.dart';
import '../widgets/tile_selector.dart';

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
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Row(
                children: [
                  Text(
                    'Work Type: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(selectedWorkType, style: TextStyle(fontSize: 18)),
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

            if (selectedWorkType == 'Kerbing' ||
                selectedWorkType == 'Shuttering') ...[
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
                    error = 'Please enter square meters';
                  }
                }

                if (canSave) {
                  await _updateEntry();
                  if (!mounted) return;
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
