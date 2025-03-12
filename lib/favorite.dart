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
    List<String> favoriteSongsData = prefs.getStringList('favorite_songs') ?? [];

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
                            title: Text(
                              favoriteSongs[index]['singer'] ?? 'Unknown Title',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              favoriteSongs[index]['name'] ?? 'Unknown Artist',
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
