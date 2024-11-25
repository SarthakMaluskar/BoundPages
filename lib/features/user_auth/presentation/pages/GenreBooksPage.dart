import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'cart_page.dart'; // Import the CartPage

  import 'dart:io';

import 'reading_time_manager.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
class GenreBooksPage extends StatelessWidget {
  final String genre;

  GenreBooksPage({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$genre Books'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('books')
            .doc(genre.toLowerCase())
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No books found in this genre'));
          }

          var data = snapshot.data!;
          String title = data['title'] ?? 'No title available';
          String author = data['author'] ?? 'Unknown author';
          String description = data['description'] ?? 'No description available';
          String pdfURL = data['pdfURL'] ?? '';
          double price = (data['price'] ?? 0).toDouble(); // Get the price

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'by $author',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              pdfURL.isNotEmpty
                  ? ElevatedButton(
                onPressed: () async {
                  final file = await _downloadPDF(pdfURL);
                  if (file != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PDFViewerPage(filePath: file.path),
                      ),
                    );
                  }
                },
                child: Text('Read Book'),
              )
                  : Text('PDF not available'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Call the _addToCart function and wait for it to complete
                  await _addToCart(title, price);

                  // Display a success message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Book added to cart successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Ensure no additional operations attempt to use the result of showSnackBar
                },
                child: Text('Buy Book'),
              ),



            ],
          );
        },
      ),
    );
  }

  Future<File?> _downloadPDF(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp_book.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print("Error downloading PDF: $e");
      return null;
    }
  }

  // Add the _addToCart function here
  Future <void> _addToCart(String title, double price) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If user is not logged in, show a message or prompt login
      print('User not logged in!');
      return;
    }

    final userId = user.uid;  // Get the user's ID
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)  // User document
        .collection('cart');  // Cart subcollection

    // Check if the book is already in the cart by title
    final querySnapshot = await cartRef
        .where('title', isEqualTo: title)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If the book is not in the cart, add it
      await cartRef.add({
        'title': title,
        'price': price,
        'addedAt': FieldValue.serverTimestamp(), // Add timestamp
        'email': user.email,
        'username': user.displayName ?? 'Unknown',
      }).then((value) {
        print('Book added to cart successfully');
      }).catchError((error) {
        print('Failed to add book to cart: $error');
      });
    } else {
      // Book already exists in the cart
      print('This book is already in your cart.');
    }
  }
}
class PDFViewerPage extends StatefulWidget {
  final String filePath;

  PDFViewerPage({required this.filePath});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  ReadingTimerManager? _timerManager; // Make nullable initially
  Timer? _timer;
  Duration _currentSessionDuration = Duration.zero;
  bool _isTimerInitialized = false; // Flag to track timer initialization

  @override
  void initState() {
    super.initState();
    _initializeTimerManager();
  }

  Future<void> _initializeTimerManager() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid; // Get the user's UID
      _timerManager = ReadingTimerManager(userId: uid);
      await _timerManager!.startTracking(); // Start tracking reading time in Firestore
      setState(() {
        _isTimerInitialized = true; // Mark timer as initialized
      });
      _startLiveTimer(); // Start the live timer after initialization
    } else {
      // Handle case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User not logged in')),
      );
      Navigator.pop(context); // Optionally navigate back
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer
    _timerManager?.stopTracking(); // Stop tracking reading time in Firestore
    super.dispose();
  }

  void _startLiveTimer() {
    if (_isTimerInitialized && _timer == null) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        if (_timerManager != null) {
          final totalTime = await _timerManager!.getTotalReadingTime();
          setState(() {
            _currentSessionDuration = totalTime;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _checkForRewards() async {
    if (_timerManager != null) {
      final rewarded = await _timerManager!.checkForReward();
      if (rewarded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Congratulations! You’ve earned a reward!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read Book'),
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: _checkForRewards, // Check for rewards
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Reading Time: ${_formatDuration(_currentSessionDuration)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: PDFView(
              filePath: widget.filePath,
            ),
          ),
        ],
      ),
    );
  }
}