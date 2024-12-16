import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class FoodCalculatorForm extends StatelessWidget {
  final Function calculateTotals;

  FoodCalculatorForm({required this.calculateTotals});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter Total Number of Guests',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              int totalGuests = int.tryParse(value) ?? 0;
              calculateTotals(totalGuests); // Trigger the calculation
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,  // Adjust based on your menu length
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Menu Item $index'),
                  subtitle: Text('Price: Rs. 500'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
