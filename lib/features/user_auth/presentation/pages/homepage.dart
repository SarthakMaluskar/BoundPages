// main.dart
import 'package:flutter/material.dart';
import 'mainpage.dart'; // Import the MainPage from mainpage.dart

void main() {
  runApp(GenreSelectionApp());
}

class GenreSelectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genre Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set the initial route to '/'
      initialRoute: '/',
      // Define routes
      routes: {
        '/': (context) => GenreSelectionScreen(),
        '/mainpage': (context) => MainPage(), // Route to MainPage
      },
    );
  }
}

class GenreSelectionScreen extends StatefulWidget {
  @override
  _GenreSelectionScreenState createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  List<String> genres = [
    "Fiction",
    "Non-Fiction",
    "Mystery",
    "Fantasy",
    "Biography",
    "Science Fiction",
    "Romance",
    "Thriller",
    "Horror",
    "Historical",
    "Adventure",
    "Self-Help",
    "Poetry"
  ];

  // To keep track of selected genres using a Set
  Set<String> selectedGenres = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Genres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose genres:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  String genre = genres[index];
                  bool isSelected = selectedGenres.contains(genre);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isSelected ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            selectedGenres.remove(genre);
                          } else {
                            selectedGenres.add(genre);
                          }
                        });
                      },
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Next button
            ElevatedButton(
              onPressed: selectedGenres.isNotEmpty
                  ? () {
                Navigator.pushNamed(context, '/mainpage'); // Navigate to mainpage
              }
                  : null, // Disable if no genres are selected
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedGenres.isNotEmpty
                    ? Colors.green
                    : Colors.grey, // Enable only if genres selected
                padding: const EdgeInsets.all(16.0),
              ),
              child: Text(
                'Next',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
