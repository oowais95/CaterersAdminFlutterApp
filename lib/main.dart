import 'package:flutter/material.dart';

void main() {
  runApp(FoodCalculatorApp());
}

class FoodCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lavish Food Quantity Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color.fromARGB(255, 216, 124, 124),
          selectedItemColor: const Color.fromARGB(255, 252, 106, 106),
          unselectedItemColor: const Color.fromARGB(255, 252, 144, 144),
        ),
      ),
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

  final List<Map<String, Map<String, dynamic>>> menus = [
    {
      "Beef Biryani / Pulao": {"price": 2500, "factor": 12.5},
      "Chicken Karahi / Qorma": {"price": 1400, "factor": 8},
      "Rabri Kheer  / Lab e sheren": {"price": 1200, "factor": 8},
      "Naan Taftan": {"price": 400, "factor": 8},
      "Salad Raita": {"price": 300, "factor": 10},
    },
    {
      "Chicken Tikka (Bihari/Malai/Balochi)": {"price": 1300, "factor": 4},
      "Beef Biryani / Pulao": {"price": 2500, "factor": 12},
      "Chicken Karahi / Qorma": {"price": 1400, "factor": 8},
      "Rabri Kheer  / Lab e sheeren": {"price": 1200, "factor": 8},
      "Naan Taftan": {"price": 400, "factor": 8},
      "Salad Raita": {"price": 300, "factor": 10},
    },
    {
      "Chicken Tikka (Bihari/Malai/Balochi)": {"price": 1300, "factor": 4},
      "Beef Biryani / Pulao": {"price": 2500, "factor": 12},
      "Chicken Karahi / Qorma": {"price": 1400, "factor": 8},
      "Gajar ka Halwa": {"price": 1500, "factor": 8},
      "Wonton / ": {"price": 25, "factor": 1},
      "Naan Taftan": {"price": 400, "factor": 8},
      "Salad Raita": {"price": 300, "factor": 10},
    },
    {
      "Ch Reshmi Kabab": {"price": 1400, "factor": 6},
      "Ch Dynamite Fry": {"price": 1600, "factor": 7},
      "Beef Yakhni Pulao/ Biryani": {"price": 2400, "factor": 12},
      "Ch Boneless Handi": {"price": 1600, "factor": 10},
      "Rabri Kheer / ..": {"price": 1200, "factor": 10},
      "Gulab Jamun": {"price": 400, "factor": 10},
      "Salad Raita": {"price": 300, "factor": 15},
    }
  ];

  @override
  Widget build(BuildContext context) {
    int totalSum = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lavish Food Quantity Calculator'),
        backgroundColor: const Color.fromARGB(255, 228, 189, 189),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.food_bank_rounded), label: 'Menu 1'),
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Menu 2'),
          BottomNavigationBarItem(
              icon: Icon(Icons.food_bank_sharp), label: 'Menu 3'),
          BottomNavigationBarItem(
              icon: Icon(Icons.food_bank_sharp), label: 'Menu 4'),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lavishAppbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
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
                        labelText: 'Enter Total Number of Guests',
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
              Table(
                border: TableBorder.all(color: Colors.black),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Item',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Quantity (Kgs)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Price (Rs)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              // Food items list
              Expanded(
                child: ListView.builder(
                  itemCount: menus[myIndex].length,
                  itemBuilder: (context, index) {
                    String itemName = menus[myIndex].keys.elementAt(index);
                    int price = menus[myIndex][itemName]?['price'];
                    double factor = menus[myIndex][itemName]?['factor'];

                    int quantity = (totalNumberOfGuests / factor).ceil();
                    int total = quantity * price;

                    totalSum += total;

                    return Table(
                      border: TableBorder.all(color: Colors.black,  width: 1,),
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(itemName,style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(quantity.toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(price.toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(total.toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(),
              // Total cost and per-head cost
              Table(
                border: TableBorder.all(color: Colors.black),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Total Cost:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(totalSum.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Per Head Cost:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          totalNumberOfGuests > 0
                              ? (totalSum / totalNumberOfGuests)
                                  .toStringAsFixed(2)
                              : '0.00',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
