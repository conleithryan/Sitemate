import 'package:flutter/material.dart';

void main() {
  runApp(const Sitemate());
}

class Sitemate extends StatelessWidget {
  const Sitemate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold (
      appBar: AppBar(
        title: Text('Sitemate'),
        backgroundColor: Colors.orange,
      ),
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
            child: Text(
              'START WORK LOG',
              style: TextStyle(fontSize: 20),
            ),
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
      appBar: AppBar(
        title: Text('Log Work'),
      backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildTileSelector(
              label: 'Selector Work Type:',
              options: workTypes,
              selectedValue: selectedWorkType,
              onSelected: (value) {
                setState(() {
                  selectedWorkType = value;
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
            
            if (selectedWorkType == 'Footpaths') ...[
              SizedBox(height: 20),
              
              buildTileSelector(
                label: 'Select Footpath Type:',
                options: ['Main','Housing'],
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
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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