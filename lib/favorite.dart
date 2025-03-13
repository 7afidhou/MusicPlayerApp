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
        title: const Text("Favorites", style: TextStyle(color: Colors.white,fontFamily: 'Nunito',fontWeight: FontWeight.bold)),
      ),
      body: favoriteSongs.isEmpty
          ? const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top:0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: favoriteSongs.length,
                      itemBuilder: (context, index) {
                        return
                        Padding(
                          padding: const EdgeInsets.only(left: 0, right: 0, top: 10),
                          child:Card(
                          color:  const Color(0xFF181787),
                          child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0), // Add padding around the ListTile

                            leading: Container(
                              width: 100,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                 
                                // Makes it round
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
                              style: const TextStyle(color: Colors.white, fontSize: 18,fontFamily: 'Nunito',fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              favoriteSongs[index]['singer'] ??
                                  'Unknown Artist',
                              style: const TextStyle(color: Colors.grey,fontSize: 12,fontFamily: 'Nunito',fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
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
