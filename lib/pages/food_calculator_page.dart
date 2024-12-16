import 'package:flutter/material.dart';
import '../services/calculation_service.dart';
import '../widgets/food_calculator_form.dart';
import '../widgets/side_navigation.dart';

class FoodCalculatorPage extends StatefulWidget {
  final int pageNumber;

  FoodCalculatorPage({required this.pageNumber});

  @override
  _FoodCalculatorPageState createState() => _FoodCalculatorPageState();
}

class _FoodCalculatorPageState extends State<FoodCalculatorPage> {
  int totalNumberOfGuests = 0;
  int grandTotal = 0;
  double perHeadCost = 0.0;
  int selectedMenuIndex = 0;

  // Call the calculation service when page changes
  void calculateTotals(List<Map<String, Map<String, dynamic>>> menus) {
    final calculationService = CalculationService();
    final totals = calculationService.calculateTotal(
      menus[selectedMenuIndex],
      totalNumberOfGuests,
    );

    setState(() {
      grandTotal = totals['grandTotal'];
      perHeadCost = totals['perHeadCost'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lavishAppbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Text('Current Page: ${widget.pageNumber}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(child: FoodCalculatorForm(calculateTotals: calculateTotals)),
          ],
        ),
      ),
    );
  }
}
