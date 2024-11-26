import 'package:flutter/material.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/mainpage.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/profile_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/notifications_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/cart_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/settings_page.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _selectedIndex = 0; // About page corresponds to index 0

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
          MaterialPageRoute(builder: (context) => CartPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Bound Pages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Bound Pages is a platform for book lovers to discover, explore, '
                  'and purchase their favorite books from various genres. Our goal '
                  'is to provide a seamless experience for readers to access and enjoy literature.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Developers:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• Sarthak Maluskar (202351077)',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '• Manav Kumar (202351078)',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '• Siddhikesh Gavit (202351040)',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '• Shreyash Borkar (202351132)',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '• Soham Naukudkar (202351135)',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            Spacer(),
            Center(
              child: Text(
                '© 2024 Bound Pages. All rights reserved.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
