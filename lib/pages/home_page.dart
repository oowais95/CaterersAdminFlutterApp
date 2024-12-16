import 'package:flutter/material.dart';
import 'food_calculator_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lavish Food Quantity Calculator'),
        backgroundColor: const Color.fromARGB(255, 228, 189, 189),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Navigation', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Page 1'),
              onTap: () {
                setState(() {
                  selectedPage = 1;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Page 2'),
              onTap: () {
                setState(() {
                  selectedPage = 2;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Page 3'),
              onTap: () {
                setState(() {
                  selectedPage = 3;
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
      body: FoodCalculatorPage(pageNumber: selectedPage),
    );
  }
}
