import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:boundpages_final/features/user_auth/presentation/pages/mainpage.dart'; // Make sure to import your ProfilePage
import 'package:boundpages_final/features/user_auth/presentation/pages/books_page.dart'; // Import your BooksPage
import 'package:boundpages_final/features/user_auth/presentation/pages/profile_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/notifications_page.dart'; // Import your NotificationsPage

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = true; // Toggle for Dark/Light Mode

  int _selectedIndex = 4; // Ensure Settings page is selected by default

  // Method to handle navigation based on the selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });

    // Navigate to the corresponding page based on the selected index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()), // Replace with your HomePage
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profilepage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BooksPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
        break;
      case 4:
      // Already on SettingsPage, do nothing
        break;
    }
  }

  // Method to sign out the user
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Redirect to login after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)), // Title changed to 'Settings'
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // No back button
      ),
      backgroundColor: Colors.black, // Black background
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person, color: Colors.white), // Profile icon
            title: Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              _onItemTapped(1); // Navigate to Profile page
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.white), // Favorites icon
            title: Text('Favorites', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Favorites page
            },
          ),
          ListTile(
            leading: Icon(Icons.download, color: Colors.white), // Downloads icon
            title: Text('Downloads', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Downloads page
            },
          ),
          ListTile(
            leading: Icon(Icons.brightness_6, color: Colors.white), // Dark/Light Mode icon
            title: Text('Dark/Light Mode', style: TextStyle(color: Colors.white)),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value; // Toggle dark/light mode
                  // Add functionality to change the theme
                });
              },
              activeColor: Colors.white,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.white70,
            ),
          ),
          ListTile(
            leading: Icon(Icons.language, color: Colors.white), // Language icon
            title: Text('Language', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Language settings
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.white), // About icon
            title: Text('About', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to About page
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red), // Logout icon
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout, // Call the logout method
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, // Set the current index
        onTap: _onItemTapped, // Call the navigation method
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
