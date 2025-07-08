import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/site.dart';
import '../models/time_entry.dart';

class TimeTrackerScreen extends StatefulWidget {
  const TimeTrackerScreen({super.key});

  @override
  _TimeTrackerScreenState createState() => _TimeTrackerScreenState();
}

class _TimeTrackerScreenState extends State<TimeTrackerScreen> {
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
      sites = siteStrings
          .map((s) => Site.fromStorageString(s))
          .where((s) => s.isActive)
          .toList();
    });
  }

  Future<void> _checkCurrentSite() async {
    // Only auto-detect if date is today
    if (selectedDate.day == DateTime.now().day &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.year == DateTime.now().year) {
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
            setState(() {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                subtitle: Text(
                  DateFormat('EEEE, MMMM, d, y').format(selectedDate),
                ),
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
                            : 'Set time',
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime:
                              startTime ?? TimeOfDay(hour: 8, minute: 00),
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
                        endTime != null ? endTime!.format(context) : 'Set time',
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime:
                              endTime ?? TimeOfDay(hour: 17, minute: 00),
                        );
                        if (picked != null) {
                          setState(() {
                            endTime = picked;
                          });
                        }
                      },
                    ),
                  ),
                ),
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
                  onPressed: () {
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
            if (errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
          ],
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

              final site = sites[index - 1];
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
            },
          ),
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

    if (!mounted) return;
    Navigator.pop(context);
  }
}
