import 'package:flutter/material.dart';
import 'songdetails.dart';
import 'db.dart';
class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Helper db = Helper();

  List<Map<String, dynamic>> favoriteSongs = [];
  Map<String, dynamic>? _selectedSong;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    List<Map<String, dynamic>> songList = await db.readData("SELECT * FROM items");
    setState(() {
      favoriteSongs = songList.map((song) {
        return {
          'name': song['name'] ?? 'Unknown Song',
          'singer': song['singer'] ?? 'Unknown Artist',
          'imagePath': song['imagePath'] ?? 'assets/images/song1.jpg',
          'audioPath': song['audioPath'] ?? 'audios/Song1.mp3',
          'lyrics': song['lyrics'] ?? 'No lyrics available',
        };
      }).toList();
      
}); 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFF181787),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181787),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const Text("Favorites", style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _buildPortraitLayout();
          } else {
            return _buildLandscapeLayout();
          }
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return favoriteSongs.isEmpty
        ? const Center(
            child: Text(
              "No favorites yet!",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 0),
            child: ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongDetailPage(
                          song: favoriteSongs[index],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color(0xFF181787),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      leading: Container(
                        width: 100,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: AssetImage(favoriteSongs[index]['imagePath'] ?? 'assets/images/song1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        favoriteSongs[index]['name'] ?? 'Unknown Song',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        favoriteSongs[index]['singer'] ?? 'Unknown Artist',
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

   Widget _buildLandscapeLayout() {
    return favoriteSongs.isEmpty
        ? const Center(
            child: Text(
              "No favorites yet!",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
        : Row(
            children: [
              // Left side: List of favorite songs
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: favoriteSongs.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSong = favoriteSongs[index];
                        });
                      },
                      child: Card(
                        color: const Color(0xFF181787),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0),
                          leading: Container(
                            width: 100,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                image: AssetImage(favoriteSongs[index]['imagePath'] ?? 'assets/images/song1.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            favoriteSongs[index]['name'] ?? 'Unknown Song',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            favoriteSongs[index]['singer'] ?? 'Unknown Artist',
                            style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Right side: Display song details (including lyrics)
              Expanded(
                flex: 3,
                child: _selectedSong != null
                    ? SingleChildScrollView( // Make lyrics scrollable
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedSong!['lyrics'] ?? 'No lyrics available',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "Select a song to view lyrics.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ],
          );
  }
}

