// genrebookspage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
                        builder: (context) => PDFViewerPage(filePath: file.path),
                      ),
                    );
                  }
                },
                child: Text('Read Book'),
              )
                  : Text('PDF not available'),
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
}

class PDFViewerPage extends StatelessWidget {
  final String filePath;

  PDFViewerPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read Book'),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
