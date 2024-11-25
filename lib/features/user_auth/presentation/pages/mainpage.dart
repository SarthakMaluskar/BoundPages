import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:boundpages_final/features/user_auth/presentation/pages/profile_page.dart'; // Ensure this import is correct
import 'package:boundpages_final/features/user_auth/presentation/pages/settings_page.dart'; // Ensure this import is correct
import 'package:boundpages_final/features/user_auth/presentation/pages/GenreBooksPage.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/cart_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:boundpages_final/features/user_auth/presentation/pages/profile_page.dart'; // Ensure this import is correct
import 'package:boundpages_final/features/user_auth/presentation/pages/settings_page.dart'; // Ensure this import is correct
import 'package:boundpages_final/features/user_auth/presentation/pages/GenreBooksPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import'reading_time_manager.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  late String userId;
  late ReadingTimerManager _readingTimerManager;
  int _currentReadingTime = 0; // Holds the current reading time in seconds
  List<dynamic> _bookResults = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeUserId(); // Fetch the user ID
  }

  // Fetch the authenticated user's ID and initialize the ReadingTimerManager
  Future<void> _initializeUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user's UID
      });
      _readingTimerManager = ReadingTimerManager(userId: userId);
      _fetchLiveCurrentReadingTime(); // Fetch the current reading time
    } else {
      // Handle the case where the user is not logged in
      // For example, navigate to a login screen
      print('User not logged in');
    }
  }

  // Fetch the current reading time from Firestore
  void _fetchLiveCurrentReadingTime() {
    FirebaseFirestore.instance
        .collection('reading_sessions')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final liveCurrentTime = data['current_time'] ?? 0;

        setState(() {
          _currentReadingTime = liveCurrentTime; // Update the UI with the live time
        });
      }
    });
  }


  // Convert seconds to a readable format
  String _formatReadingTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final hours = (minutes / 60).floor();
    return hours > 0
        ? '${hours}h ${minutes % 60}m'
        : '${minutes}m ${seconds % 60}s';
  } // Declare selectedIndex variable

  // Function to fetch books using Google Books API
  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _bookResults.clear(); // Clear results if the search query is empty
      });
      return;
    }

    final String url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=10';
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _bookResults = json.decode(response.body)['items'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load books');
    }
  }

  // Widget for Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white), // Set the text color to white
        decoration: InputDecoration(
          hintText: 'Search for books...',
          hintStyle: TextStyle(color: Colors.grey), // Hint text in grey
          filled: true,
          fillColor: Colors.white12,
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) {
          _searchBooks(query);
        },
        onSubmitted: (query) {
          _searchBooks(query);
        },
      ),
    );
  }

  // Widget to display book search results in a floating scrollable widget
  Widget _buildFloatingBookSuggestions() {
    if (_bookResults.isEmpty) return SizedBox.shrink(); // Return an empty widget if there are no results

    return Positioned(
      top: 100, // Position it just below the search bar
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[850]?.withOpacity(0.9), // Slightly transparent background
            borderRadius: BorderRadius.circular(10),
          ),
          height: MediaQuery.of(context).size.height / 2, // Half of the screen height
          child: Column(
            children: [
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: _bookResults.length,
                  itemBuilder: (context, index) {
                    final book = _bookResults[index]['volumeInfo'];
                    return ListTile(
                      leading: book['imageLinks'] != null
                          ? Image.network(
                        book['imageLinks']['thumbnail'],
                        height: 50,
                        width: 50,
                      )
                          : Icon(Icons.book, color: Colors.white, size: 50),
                      title: Text(book['title'], style: TextStyle(color: Colors.white)),
                      subtitle: Text(book['authors']?.join(', ') ?? 'Unknown Author', style: TextStyle(color: Colors.white70)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Main UI Structure with logo, streak, categories, and challenges
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard and clear search results on tapping outside
        setState(() {
          _bookResults.clear(); // Clear results when tapping outside
        });
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('BoundPages', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    _buildSearchBar(),
                    SizedBox(height: 20),

                    // Logo and App Name
                    Center(
                      child: Column(
                        children: [
                          // Image.asset('assets/aloneDark2.jpg', height: 50),
                          Text(
                            'BoundPages',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Streak Widget
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.orange),
                              SizedBox(height: 5),
                              Text('Streak', style: TextStyle(color: Colors.white)),
                              Text('10 Days', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.timer, color: Colors.yellow),
                              SizedBox(height: 5),
                              Text('Minutes Read', style: TextStyle(color: Colors.white)),
                              Text(_formatReadingTime(_currentReadingTime), style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.bookmark, color: Colors.green),
                              SizedBox(height: 5),
                              Text('Key Points', style: TextStyle(color: Colors.white)),
                              Text('5', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.insights, color: Colors.blue),
                              SizedBox(height: 5),
                              Text('Insights', style: TextStyle(color: Colors.white)),
                              Text('3', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Free Daily Summary Widget (Placeholder)
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: AssetImage('assets/aloneDark.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Free Daily Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Categories Widget
                    Text(
                      'Categories You\'re Interested In',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Add your onTap logic here for Health
                              print('Health tapped!');
                            },
                            child: CategoryChip('Health'),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Add your onTap logic here for Money & Investments
                              print('Money & Investments tapped!');
                            },
                            child: CategoryChip('Money & Investments'),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Add your onTap logic here for Happiness
                              print('Happiness tapped!');
                            },
                            child: CategoryChip('Happiness'),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Add your onTap logic here for Business & Career
                              print('Business & Career tapped!');
                            },
                            child: CategoryChip('Business & Career'),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Add your onTap logic here for Sports & Fitness
                              print('Sports & Fitness tapped!');
                            },
                            child: CategoryChip('Sports & Fitness'),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Add your onTap logic here for Spirituality
                              print('Spirituality tapped!');
                            },
                            child: CategoryChip('Spirituality'),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Personalized Challenges Widget
                    Text(
                      'Personalized Challenges',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Container(
                      height: 100,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ChallengeCard('Morning Routine Challenge'),
                          ChallengeCard('Self Discovery Challenge'),
                          ChallengeCard('Joyful Challenge'),
                          ChallengeCard('Success Challenge'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Add Search Results
            _buildFloatingBookSuggestions(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.white70,
          selectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex, // Set the current index
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Update selected index
            });

            // Navigate to the corresponding page based on the selected index
            switch (index) {
              case 0:
              // Home (current page)
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profilepage()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );

                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
                break;
              case 4:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
                break;
            }
          },
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
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;

  CategoryChip(this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the GenreBooksPage with the selected genre
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GenreBooksPage(genre:label)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Chip(
          label: Text(label, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
        ),
      ),
    );
  }
}
// Challenge Card Widget
class ChallengeCard extends StatelessWidget {
  final String title;

  ChallengeCard(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
