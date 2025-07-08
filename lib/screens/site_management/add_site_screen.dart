import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/site.dart';

class AddSiteScreen extends StatefulWidget {
  const AddSiteScreen({super.key});

  @override
  _AddSiteScreenState createState() => _AddSiteScreenState();
}

class _AddSiteScreenState extends State<AddSiteScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController radiusController = TextEditingController(
    text: '100',
  );

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
      address: addressController.text.isEmpty ? null : addressController.text,
    );

    final prefs = await SharedPreferences.getInstance();
    final sites = prefs.getStringList('sites') ?? [];
    sites.add(site.toStorageString());
    await prefs.setStringList('sites', sites);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Site'), backgroundColor: Colors.purple),
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
                icon: isLoading
                    ? CircularProgressIndicator()
                    : Icon(Icons.location_on),
                label: Text('Get Current Location'),
              )
            else
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Location captured!'),
                      Text(
                        'Lat: ${currentPosition!.latitude.toStringAsFixed(6)}',
                      ),
                      Text(
                        'Lng: ${currentPosition!.longitude.toStringAsFixed(6)}',
                      ),
                    ],
                  ),
                ),
              ),

            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    currentPosition != null && nameController.text.isNotEmpty
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
