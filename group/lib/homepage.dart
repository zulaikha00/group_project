import 'package:flutter/material.dart';
import 'profile.dart';
import 'map.dart';
import 'about_us.dart';
import 'login.dart'; // Make sure you have the login screen imported

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation with OpenStreetMap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(userName: ''), // Initialize with an empty string
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName; // Store the user's name passed from Login

  const HomePage(
      {super.key, required this.userName}); // Accept userName as a parameter

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Pages for navigation
  final List<Widget> _pages = [
    MapPage(),
    AboutUsPage(),
    ProfilePage(),
  ];

  // Change selected page based on navigation menu selection
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Logout function with confirmation dialog
  void _logout() async {
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Don't logout
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Do logout
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      // Navigate back to Login page after sign out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginScreen()), // Assuming LoginPage() is your login screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${widget.userName}'), // Display the user's name
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app), // Logout icon
            onPressed: _logout, // Call the logout function
          ),
        ],
      ),
      body: _pages[_currentIndex], // Display the current page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
