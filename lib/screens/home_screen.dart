import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/site.dart';
import 'add_work_screen.dart';
import 'view_work_screen.dart';
import 'time_tracker_screen.dart';
import 'site_management/site_management_screen.dart';
import 'view_time_entries_screen.dart'; // <--- NEW IMPORT

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
      appBar: AppBar(title: Text('Jobsy'), backgroundColor: Colors.orange),
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
                    currentSiteName != null
                        ? 'At: $currentSiteName'
                        : 'No site detected',
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
                  MaterialPageRoute(builder: (context) => TimeTrackerScreen()),
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
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            SizedBox(height: 20),

            // View time entries <--- NEW BUTTON
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewTimeEntriesScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'VIEW TIME ENTRIES',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Manage sites button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SiteManagementScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('MANAGE SITES', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
