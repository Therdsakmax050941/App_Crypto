import 'package:flutter/material.dart';
import 'package:go_api_auth_app/screens/login_screen.dart';
import 'package:go_api_auth_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_api_auth_app/screens/trading_simulator.dart';
import 'package:go_api_auth_app/screens/top_crypto.dart';
import 'package:go_api_auth_app/screens/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: token == null ? LoginScreen() : BottomNavigationBarExample(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => BottomNavigationBarExample(),
      },
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TopCrypto(),
    TradingSimulator(),
    SettingsScreen(), // Make sure SettingsScreen is properly imported
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), // Changed to dashboard icon for Home
            label: 'News', // Updated label
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart), // Changed to chart icon for Top Crypto
            label: 'Top Crypto', // Updated label
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up), // Changed to trending up icon for Trading Simulator
            label: 'Trading', // Updated label
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Kept the same icon for Settings
            label: 'Settings', // Updated label
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber, // Highlight color for the selected item
        unselectedItemColor: Colors.white, // Color for unselected items
        onTap: _onItemTapped,
      ),
    );
  }
}
