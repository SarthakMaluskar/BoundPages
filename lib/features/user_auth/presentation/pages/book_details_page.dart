import 'package:flutter/material.dart';

class BookDetailsPage extends StatelessWidget {
  final String title;
  final String authors;
  final String imageUrl;
  final String description; // Add description or any other details you want

  BookDetailsPage({required this.title, required this.authors, required this.imageUrl, this.description = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Authors: $authors',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
