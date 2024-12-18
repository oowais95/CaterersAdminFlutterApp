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
  int grandTotal = 0;
  double perHeadCost = 0.0;
  int myIndex = 0;
  int selectedPage = 1;

  final List<Map<String, Map<String, dynamic>>> menus = [
    {
      "Beef Biryani / Pulao": {"price": 2500, "factor": 13},
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
      "Ch Dynamite Fry": {"price": 1600, "factor": 8},
      "Beef Yakhni Pulao/ Biryani": {"price": 2400, "factor": 12},
      "Ch Boneless Handi": {"price": 1600, "factor": 10},
      "Rabri Kheer / ..": {"price": 1200, "factor": 10},
      "Gulab Jamun": {"price": 400, "factor": 10},
      "Salad Raita": {"price": 300, "factor": 15},
    }
  ];

  void calculateTotals() {
    int tempGrandTotal = 0;

    menus[myIndex].forEach((itemName, details) {
      int price = details['price'];
      int factor = details['factor'];
      int quantity = (totalNumberOfGuests / factor).ceil();
      tempGrandTotal += quantity * price;
    });

    setState(() {
      grandTotal = tempGrandTotal;
      perHeadCost =
          totalNumberOfGuests > 0 ? grandTotal / totalNumberOfGuests : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lavish Cateres'),
        backgroundColor: const Color.fromARGB(255, 228, 189, 189),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 125, 125),
              ),
              child: Text('Lavish Caterers - 03008292033', style: TextStyle(color: Colors.white)),
              
            ),
            ListTile(
              title: Text('Calculator'),
              onTap: () {
                setState(() {
                  selectedPage = 1;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Packages (Per Head Groups)'),
              onTap: () {
                setState(() {
                  selectedPage = 2;
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: selectedPage == 1
          ? BottomNavigationBar(
              onTap: (index) {
                setState(() {
                  myIndex = index;
                  calculateTotals();
                });
              },
              currentIndex: myIndex,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.food_bank_rounded), label: 'Menu 1'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.food_bank), label: 'Menu 2'),
                     BottomNavigationBarItem(
                    icon: Icon(Icons.food_bank), label: 'Menu 3'),
                     BottomNavigationBarItem(
                    icon: Icon(Icons.food_bank), label: 'Menu 4'),
                    
              ],
            )
          : null,
      body: selectedPage == 1 ? _buildDefaultBody() : _buildHardcodedPackagesPage(),
    );
  }

  Widget _buildDefaultBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
                      calculateTotals();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: menus[myIndex].length,
              itemBuilder: (context, index) {
                String itemName = menus[myIndex].keys.elementAt(index);
                int price = menus[myIndex][itemName]?['price'];
                int factor = menus[myIndex][itemName]?['factor'];

                int quantity = (totalNumberOfGuests / factor).ceil();
                int total = quantity * price;

                return Card(
                  child: ListTile(
                    title: Text(itemName),
                    subtitle: Text(
                        'Quantity: $quantity, Price: $price, Total: $total'),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Text('Grand Total: $grandTotal'),
          Text('Per Head Cost: ${perHeadCost.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildHardcodedPackagesPage() {
    final Map<int, List<List<String>>> packageOptions = {
      1000: [
        ['Beef Biryani', 'Chicken Karahi', 'Naan', 'Raita'],
        ['Chicken Pulao', 'Gajar Ka Halwa', 'Taftan', 'Salad'],
      ],
      1200: [
        ['Chicken Biryani', 'Chicken Tikka', 'Rabri Kheer', 'Naan'],
        ['Beef Pulao', 'Chicken Handi', 'Gulab Jamun', 'Taftan'],
         ['Chicken Qorma', 'Mutton Karahi', 'Fruit Trifle', 'Raita'],
      ],
      1500: [
        ['Mutton Biryani', 'Mutton Karahi', 'Shahi Tukda', 'Naan'],
        [
          'Chicken Dynamite Fry',
          'Beef Yakhni Pulao',
          'Gajar Ka Halwa',
          'Salad'
        ],
      ],
          };

    return ListView(
      padding: EdgeInsets.all(16.0),
      children: packageOptions.entries.map((entry) {
        return Card(
          child: ExpansionTile(
            title: Text('Per Head: Rs ${entry.key}'),
            children: entry.value.map((package) {
              return ListTile(
                title: Text(package.join(', ')),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
