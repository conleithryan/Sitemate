import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/time_entry.dart'; // Import the TimeEntry model

class ViewTimeEntriesScreen extends StatefulWidget {
  const ViewTimeEntriesScreen({super.key});

  @override
  _ViewTimeEntriesScreenState createState() => _ViewTimeEntriesScreenState();
}

class _ViewTimeEntriesScreenState extends State<ViewTimeEntriesScreen> {
  List<TimeEntry> entries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeEntries();
  }

  Future<void> _loadTimeEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEntries = prefs.getStringList('time_entries') ?? [];

      List<TimeEntry> parsedEntries = [];
      for (String entryString in savedEntries) {
        try {
          parsedEntries.add(TimeEntry.fromStorageString(entryString));
        } catch (e) {
          print('Error parsing time entry: \$e');
        }
      }

      setState(() {
        entries = parsedEntries.reversed.toList(); // Show newest first
        isLoading = false;
      });
    } catch (e) {
      print('Error loading time entries: \$e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Entries'),
        backgroundColor: Colors.green, // Matching TimeTrackerScreen color
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? const Center(
                  child: Text(
                    'No time entries yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${_formatDate(entry.date)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Site: ${entry.siteName ?? "Not specified"}'),
                            Text('Clock In: ${_formatDateTime(entry.clockIn)}'),
                            Text('Clock Out: ${_formatDateTime(entry.clockOut)}'),
                            Text('Break: ${entry.breakMinutes} minutes'),
                            Text('Total Hours: ${entry.totalHours.toStringAsFixed(2)}'),
                            // TODO: Add edit/delete functionality if needed later
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
