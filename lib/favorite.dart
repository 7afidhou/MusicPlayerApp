import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, String>> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteSongsData =
        prefs.getStringList('favorite_songs') ?? [];

    setState(() {
      favoriteSongs = favoriteSongsData
          .map((song) => Map<String, String>.from(jsonDecode(song)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181787),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181787),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const Text("Favorites", style: TextStyle(color: Colors.white)),
      ),
      body: favoriteSongs.isEmpty
          ? const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: favoriteSongs.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white10,
                          child: ListTile(
                            leading: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, // Makes it round
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 7,
                                    blurRadius: 10,
                                    offset: const Offset(4, 4),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage(favoriteSongs[index]
                                          ['imagePath'] ??
                                      'assets/images/song1.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              favoriteSongs[index]['name'] ?? 'Unknown Song',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              favoriteSongs[index]['singer'] ??
                                  'Unknown Artist',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
