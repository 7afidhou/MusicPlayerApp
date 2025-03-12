import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}


class _FavoritePageState extends State<FavoritePage> {
   static Future<List<Map<String, String>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteSongs = prefs.getStringList('favorite_songs') ?? [];
    return favoriteSongs.map((song) => Map<String, String>.from(jsonDecode(song))).toList();
  }

  @override
  void initState() {
    super.initState();
    getFavorites().then((favorites) {
      print(favorites);
    });
    }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color(0xFF181787),
      appBar:  AppBar(
        backgroundColor: const Color(0xFF181787),
        iconTheme: const IconThemeData(color: Colors.white,size: 30),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.favorite,
              size: 100,
              color: Colors.red,
            ),
            Text(
              "Favorite Page",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}