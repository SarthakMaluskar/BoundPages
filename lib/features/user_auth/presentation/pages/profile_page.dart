import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/settings_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/cart_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/notifications_page.dart';

class Profilepage extends StatefulWidget {
  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _username = 'Loading...';
  String _email = 'Loading...';
  int _selectedIndex = 1; // Set the initial index to Profile
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // Function to fetch user information from Firestore
  Future<void> _getUserInfo() async {
    _user = _auth.currentUser;

    if (_user != null) {
      // Get the user's email
      _email = _user!.email!;

      // Get the user's profile data from Firestore using their UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username']; // Assuming 'username' field exists in Firestore
        });
      }
    }
  }

  // Function to handle updating username
  Future<void> _updateUsername(String newUsername) async {
    if (_user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'username': newUsername});

      setState(() {
        _username = newUsername;
      });
    }
  }

  // Function to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/mainpage'); // Navigate to Home page
        break;
      case 1:
      // Already on Profile page, no need to navigate
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartPage()),
        );
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );// Navigate to Settings page
        break;
    }
  }

  // Show dialog to edit username
  void _showEditUsernameDialog() {
    _usernameController.text = _username; // Set the current username as the default value
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: 'Enter new username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newUsername = _usernameController.text.trim();
                if (newUsername.isNotEmpty) {
                  _updateUsername(newUsername);
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20), // Space between avatar and text
            Text(
              _username, // Username from Firestore
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 10), // Space between name and email
            Text(
              _email, // Email from Firebase Auth
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20), // Space below email
            ElevatedButton(
              onPressed: _showEditUsernameDialog, // Show the edit username dialog
              child: Text('Edit Username'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button background color
                foregroundColor: Colors.white, // Button text color
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, // Set the current index to the selected page
        onTap: _onItemTapped, // Handle taps
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
