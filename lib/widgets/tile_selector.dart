import 'package:flutter/material.dart';

Widget buildTileSelector({
  required String label, // Text above tiles
  required List<String> options, // List of choices
  required String? selectedValue, // Currently selected option
  required Function(String) onSelected, // What to do when tile tapped
  Map<String, Color>? colorMap, // Colors for each option
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align label to left
    children: [
      // Label text
      Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(height: 10),

      // Horizontal scrolling list of tiles
      SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Scroll left/right
          itemCount: options.length,
          itemBuilder: (context, index) {
            String option = options[index];
            bool isSelected = selectedValue == option;
            Color tileColor =
                colorMap?[option] ??
                Colors.orange; // Use color from map or orange

            return Padding(
              padding: EdgeInsets.only(right: 8), // Space between tiles
              child: GestureDetector(
                onTap: () => onSelected(option), // Call function when tapped
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? tileColor
                        : Colors.grey[200], // Color based on selection
                    borderRadius: BorderRadius.circular(30), // Rounded corners
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
