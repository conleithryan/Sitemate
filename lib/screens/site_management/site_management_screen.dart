import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/site.dart';
import 'add_site_screen.dart';

class SiteManagementScreen extends StatefulWidget {
  const SiteManagementScreen({super.key});
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
