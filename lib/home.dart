import 'dart:convert';
import 'package:flutter/material.dart';
import 'favorite.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'song.dart';
import 'db.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<Song> likedsongs=[];
  List<Song> songs= songList;
  int index=0;
  bool isPlaying = false;
  bool isLiked = false;
  bool hiddenData = true;
  int clickedTimes = 0;
  String singer = songList[0].singer;
  String song = songList[0].name;
  String audiopath = songList[0].audioPath;
  String imagepath = songList[0].imagePath;
  String lyrics = songList[0].lyrics;
  late AnimationController _controller;
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero; 
  Duration _position = Duration.zero; 
  Helper db = Helper();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _loadFavorites();
    _loadLastPosition();

    _player.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _player.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    _player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        _position = Duration.zero;
      });
    });

      

    
   
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      _resumeMusic(audiopath);
    }
  }

void _loadFavorites() async {
 // Fetch all songs from DB
   List<Map> songsfetched = await db.readsongs();
   songsfetched.map((song){
    likedsongs.add(Song(name: song['name'], singer: song['singer'], imagePath: song['imagePath'], audioPath: song['audioPath'], duration: song['duration'], lyrics: song['lyrics']));
   });

  bool songExists = likedsongs.any((song) =>song.name == song && song.singer== singer);
 if (songExists){
   isLiked = true;}
  else {
   isLiked = false;
  }
 
}


  Future<void> _loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    int lastPosition = prefs.getInt('last_position') ?? 0;
    setState(() {
      _position = Duration(milliseconds: lastPosition);
    });
  }

  Future<void> _saveLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_position', _position.inMilliseconds);
  }

  void togglePlayPause() {
    if (isPlaying) {
      _player.pause();
    } else {
      _player.play(AssetSource(audiopath));
    }
    setState(() {
      isPlaying = !isPlaying;
      clickedTimes++;
      if (clickedTimes > 0) hiddenData = false;
    });
  }

  Future<void> _pauseMusic() async {
    await _saveLastPosition();
    await _player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _resumeMusic(String path) async {
    await _player.play(AssetSource(path), position: _position);
    setState(() {
      isPlaying = true;
    });
  }

  void toggleLike() async {
  setState(() {
    isLiked = !isLiked;
    songs[index].isFavorite = isLiked; // Update isFavorite in songs list
  });

  if (isLiked) {
    // Add song to favorites
    await db.insertsong(songs[index]); // Save to database
 // Debugging line to check song list
  } else {
    await db.deletesongByNameAndSinger(song, singer);

  }



    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLiked ? "Added to Liked Songs" : "Removed from Liked Songs",
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isLiked
            ? Colors.green
            : Colors.red, // Different colors for like/unlike
        behavior: SnackBarBehavior.floating, // Floating effect
        elevation: 6.0, // Shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        duration:
            const Duration(seconds: 1), // Controls how long it stays visible
      ),
    );
  }

void goToFavorites() {
  _player.pause(); // Pause when navigating

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const FavoritePage()),
  ).then((_) {
    _player.resume();
     // Resume when coming back
     setState(() {
       isPlaying = true;
        // Set isPlaying to true when coming back
     }); // Set isPlaying to true when coming back
  });
}


void playNext() {
  if (index < songs.length - 1) {
    setState(() { 
      index++;  // Move index inside setState for UI updates
      updateSongDetails();
    });
    _player.play(AssetSource(audiopath));
  }
}

void playPrevious() {
  if (index > 0) {
    setState(() { 
      index--;  // Move index inside setState for UI updates
      updateSongDetails();
    });
    _player.play(AssetSource(audiopath));
  }
}

// Helper function to update song details
void updateSongDetails() {
  singer = songs[index].singer;
  song = songs[index].name;
  audiopath = songs[index].audioPath;
  imagepath = songs[index].imagePath;
  lyrics = songs[index].lyrics;
  isPlaying = true;

 bool songExists = likedsongs.any((song) =>song.name == song && song.singer== singer);
 if (songExists){
   setState(() {
    isLiked = true; // Update isLiked based on the song's existence in favorites
   });
   
  }
  else {
   setState(() {
    isLiked = false; // Update isLiked based on the song's existence in favorites
   });
  }
}

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181787),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _appheader(),
                const SizedBox(height: 45),
                _photosection(),
                const SizedBox(height: 20),
                _songdatasection(),
                const SizedBox(height: 40),
                _progresssection(),
                const SizedBox(height: 40),
                _controlsection(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Padding _controlsection() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: playPrevious,
            icon: const Icon(Icons.skip_previous_outlined,
                size: 60, color: Colors.white),
          ),
          IconButton(
            onPressed: togglePlayPause,
            icon: Icon(
              isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              size: 100,
              color: const Color(0xff796EF8),
            ),
          ),
          IconButton(
            onPressed: playNext,
            icon: const Icon(Icons.skip_next_outlined,
                size: 60, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Column _progresssection() {
    // double progress = _duration.inSeconds > 0
    //     ? _position.inSeconds / _duration.inSeconds
    //     : 0.0; // Calculate progress

return Column(
  children:
  [
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          activeTrackColor: const Color(0xff796EF8),
          inactiveTrackColor: Colors.white,
          thumbColor: const Color(0xff796EF8),
        ),
        child: Slider(
          min: 0,
          max: _duration.inMilliseconds.toDouble(),
          value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
          onChanged: (value) {
            // Set new position but don't seek yet
            setState(() {
              _position = Duration(milliseconds: value.toInt());
            });
          },
          onChangeEnd: (value) {
            // Actually seek the audio
            _player.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      ),
      const SizedBox(height: 3),
      Padding(padding:const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formatTime(_position),
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Text(
            formatTime(_duration),
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ],
      ),)

      
    ]
    );
  }

  Column _songdatasection() {
    return Column(
      children: [
        Text(
          song,
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        Text(
          singer,
          style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ],
    );
  }

  AnimatedBuilder _photosection() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.1416, // Rotates 360 degrees
          child: Container(
            width: 200,
            height: 200,
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
                image: AssetImage(imagepath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Padding _appheader() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {}, // Back button functionality
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
          ),
          Text(
            "$song by $singer",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: toggleLike, // Short tap toggles like
            onLongPress: goToFavorites, // Long press navigates to FavoritePage
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
