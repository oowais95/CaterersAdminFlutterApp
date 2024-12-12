import 'package:flutter/material.dart';

void main() {
  runApp(FoodCalculatorApp());
}

class FoodCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Quantity Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FoodCalculatorPage(),
    );
  }
}

class FoodCalculatorPage extends StatefulWidget {
  @override
  _FoodCalculatorPageState createState() => _FoodCalculatorPageState();
}

class _FoodCalculatorPageState extends State<FoodCalculatorPage> {
  int totalNumberOfGuests = 0;
  int myIndex = 0;

  final Map<String, Map<String, dynamic>> foodItems = {
    "Rice": {"price": 1800, "factor": 10},
    "Gravy": {"price": 1400, "factor": 8},
    "Sweet Dish": {"price": 1200, "factor": 8},
    "Naan Taftan": {"price": 400, "factor": 8},
    
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Quantity Calculator'),
      ),
      bottomNavigationBar: BottomNavigationBar(

        onTap: (index){
          setState(() {
            myIndex = index;
          });

        },
        currentIndex: myIndex,

        items: const[BottomNavigationBarItem(icon: Icon(Icons.food_bank_rounded), label: 'menu1'),
        BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'menu2'),
        BottomNavigationBarItem(icon: Icon(Icons.food_bank_sharp), label: 'menu3',),],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input for total number of guests
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Number of Guests',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        totalNumberOfGuests = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Table headers
            Row(
              children: [
                Expanded(child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            Divider(),
            // Food items list
            Expanded(
              child: ListView.builder(
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  String itemName = foodItems.keys.elementAt(index);
                  int price = foodItems[itemName]?['price'];
                  int factor = foodItems[itemName]?['factor'];

                  int quantity = (totalNumberOfGuests / factor).ceil();
                  int total = quantity * price;

                  return Row(
                    children: [
                      Expanded(child: Text(itemName)),
                      Expanded(child: Text(quantity.toString())),
                      Expanded(child: Text(price.toString())),
                      Expanded(child: Text(total.toString())),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
