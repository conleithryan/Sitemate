import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry.dart';
import 'edit_work_screen.dart';

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
                              Text(
                                'Square Meters: ${entry.metersSquare ?? "N/A"}',
                              ),
                              Text(
                                'Cubic Meters: ${entry.metersCubic ?? "N/A"}',
                              ),
                            ],

                            if (entry.workType == 'Bases') ...[
                              Text(
                                'Cubic Meters: ${entry.metersCubic ?? "N/A"}',
                              ),
                              Text('Quantity: ${entry.quantity ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Foundations') ...[
                              Text(
                                'Square Meters: ${entry.metersSquare ?? "N/A"}',
                              ),
                              Text(
                                'Cubic Meters: ${entry.metersCubic ?? "N/A"}',
                              ),
                            ],

                            if (entry.workType == 'Kerbing') ...[
                              Text(
                                'Meters Total: ${entry.metersTotal ?? "N/A"}',
                              ),
                            ],

                            if (entry.workType == 'Shuttering') ...[
                              Text(
                                'Meters Total: ${entry.metersTotal ?? "N/A"}',
                              ),
                            ],

                            if (entry.workType == 'Manholes') ...[
                              Text('Quantity: ${entry.quantity ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Day Works') ...[
                              Text('Hours: ${entry.hours ?? "N/A"}'),
                            ],

                            if (entry.workType == 'Base Prep') ...[
                              Text(
                                'Square Meters: ${entry.metersSquare ?? "N/A"}',
                              ),
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
                                    ).then(
                                      (_) => loadEntries(),
                                    ); //Reload entries when returning
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
  Future<void> _showDeleteDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Work Entry'),
          content: Text(
            'Are you sure you want to delete this work entry? This action cannot be undone.',
          ),
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
                  if (!mounted) return;
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
      final prefs = await SharedPreferences.getInstance();
      final savedEntries = prefs.getStringList('work_entries') ?? [];

      // Remove the entry at the specified index
      if (index >= 0 && index < entries.length) {
        // Since entries are reversed, calculate the actual index
        int actualIndex = savedEntries.length - 1 - index;
        savedEntries.removeAt(actualIndex);

        // Save the updated list
        await prefs.setStringList('work_entries', savedEntries);

        // Reload the entries to update the UI
        await loadEntries();
      }
    } catch (e) {
      print('Error deleting entry: $e');
    }
  }
}
