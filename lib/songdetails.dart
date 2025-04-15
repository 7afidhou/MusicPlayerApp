import 'package:flutter/material.dart';

class SongDetailPage extends StatelessWidget {
  final Map<String, dynamic> song;

  const SongDetailPage({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181787),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181787),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const Text("Song Lyrics", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(  // Wrapping the body in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,  // Optional, just for alignment
            children: [
              // Optionally add an image
              // Image.asset(song['imagePath'] ?? 'assets/images/song1.jpg'),
              // SizedBox(height: 20),
              Text(
                song['lyrics']=="" ? 'No lyrics available':song['lyrics']!,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 10),
              // You can add more details here
            ],
          ),
        ),
      ),
    );
  }
}
