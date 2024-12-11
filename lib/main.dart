import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SumCalculator(),
    );
  }
}

class SumCalculator extends StatefulWidget {
  @override
  _SumCalculatorState createState() => _SumCalculatorState();
}

class _SumCalculatorState extends State<SumCalculator> {
  
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemName2 = TextEditingController();
  final TextEditingController itemName3 = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  int _sum = 0;
  int _sum2 = 0;

  void _multiply() {
    final int num1 = int.tryParse(_controller1.text) ?? 0;
    final int num2 = int.tryParse(_controller2.text) ?? 0;

    setState(() {
      _sum = num1 * num2;
    });
  }
  
   void _multiply2() {
    final int num1 = int.tryParse(_controller3.text) ?? 0;
    final int num2 = int.tryParse(_controller4.text) ?? 0;

    setState(() {
      _sum2 = num1 * num2;
    });
  }
  

   // create a separate multiply for second line

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Sum Calculator'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemName..text = "Chicken Biryani",
                    keyboardType: TextInputType.text,
                    readOnly: true, // Makes the TextField non-editable without blurring
                    decoration: InputDecoration(
                      labelText: 'CH Biryani',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8), // Space between fields
                Expanded(
                  child: TextField(
                    controller: _controller1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter first number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _multiply(),
                  ),
                ),
                SizedBox(width: 8), // Space between fields
                Expanded(
                  child: TextField(
                    controller: _controller2,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter second number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _multiply(),
                  ),
                ),
                SizedBox(width: 8), // Space between fields
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _sum.toString()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // Space between rows
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemName2..text = "Beef Biryani",
                    keyboardType: TextInputType.text,
                    readOnly: true, // Makes the TextField non-editable without blurring
                    decoration: InputDecoration(
                      labelText: 'BF Biryani',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8), // Space between fields
                Expanded(
                  child: TextField(
                    controller: _controller3,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter first number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _multiply(),
                  ),
                ),
                SizedBox(width: 8), // Space between fields
                Expanded(
                  child: TextField(
                    controller: _controller4,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter second number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _multiply2(),
                  ),
                ),
                SizedBox(width: 8), // Space between fields
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _sum2.toString()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

}
