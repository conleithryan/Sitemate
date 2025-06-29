import 'package:flutter/material.dart';

void main() {
  runApp(const Sitemate());
}

class Sitemate extends StatelessWidget {
  const Sitemate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.orange),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sitemate'), backgroundColor: Colors.orange),
      body: Center(
        child: ElevatedButton(
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
      ),
    );
  }
}

class AddWorkScreen extends StatefulWidget {
  @override
  _AddWorkScreenState createState() => _AddWorkScreenState();
}

class _AddWorkScreenState extends State<AddWorkScreen> {
  String? selectedWorkType;
  String? selectedFootpathType;
  String metersCompleted = '';
  String basesQuantity = '';
  String dayWorksHours = '';
  String? errorMessage;
  String? successMessage;

  final List<String> workTypes = [
    'Footpaths',
    'Bases',
    'Foundations',
    'Kerbing',
    'Shuttering',
    'Manholes',
    'Day Works',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Work'), backgroundColor: Colors.orange),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildTileSelector(
              label: 'Work Type:',
              options: workTypes,
              selectedValue: selectedWorkType,
              onSelected: (value) {
                setState(() {
                  selectedWorkType = value;
                  successMessage = null;
                  errorMessage = null;
                });
              },
              colorMap: {
                'Footpaths': Colors.blue,
                'Bases': Colors.orange,
                'Foundations': Colors.brown,
                'Kerbing': Colors.purple,
                'Shuttering': Colors.green,
                'Manholes': Colors.red,
                'Day Works': Colors.teal,
              },
            ),

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
                      Icon(Icons.error, color: Colors.green),
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
                  labelText: 'Meters Completed',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  metersCompleted = value;
                },
              ),
            ],

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
                  print('Number of Bases Completed: $basesQuantity');
                },
              ),
            ],

            if (selectedWorkType == 'Day Works') ...[
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Hours Worked',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  dayWorksHours = value;
                  print('Day Work hours: $dayWorksHours');
                },
              ),
            ],

            if (selectedWorkType != null) ...[
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  bool canSave = true;
                  String error = '';

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
                  } else if (selectedWorkType == 'Day Works') {
                    if (dayWorksHours.isEmpty) {
                      canSave = false;
                      error = 'Please enter hours worked';
                    }
                  }

                  if (canSave) {
                    setState(() {
                      errorMessage = null;
                      successMessage = 'Work entry saved!';

                      selectedWorkType = null;
                      selectedFootpathType = null;
                      metersCompleted = '';
                      basesQuantity = '';
                      dayWorksHours = '';
                    });

                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        successMessage = null;
                      });
                    });
                    print('✅ Saving work entry...');
                    print('Work type: $selectedWorkType');

                    if (selectedWorkType == 'Footpaths') {
                      print('Footpath type: $selectedFootpathType');
                      print('Meters: $metersCompleted');
                    } else if (selectedWorkType == 'Bases') {
                      print('Bases quantity: $basesQuantity');
                    } else if (selectedWorkType == 'Day Works') {
                      print('Hours: $dayWorksHours');
                    }
                  } else {
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

  Widget buildTileSelector({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
    Map<String, Color>? colorMap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              String option = options[index];
              bool isSelected = selectedValue == option;
              Color tileColor = colorMap?[option] ?? Colors.orange;

              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelected(option),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? tileColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
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
}
