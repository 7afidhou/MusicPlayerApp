import 'package:flutter/material.dart';
import 'favorite.dart';
// import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool isPlaying = false;
  bool isLiked = false;
  bool hiddenData = true;
  int clickedTimes = 0;
  String singer = "Marwan Khouri";
  String song = "Akbar Anani";
  late AnimationController _controller;
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero; // Total song duration
  Duration _position = Duration.zero; // Current position in song

  
   @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

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
      _resumeMusic();
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
      _player.play(AssetSource('audios/song.mp3'));
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

  Future<void> _resumeMusic() async {
    await _player.play(AssetSource('audios/song.mp3'), position: _position);
        setState(() {
      isPlaying = true;
    });
  }
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritePage()),
    );
  }

  void playNext() {}
  void playPrevious() {}

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

                // Music Image
                // Center(
                //   child: Image.asset(
                //     'assets/images/Music.jpg',
                //     width: orientation == Orientation.portrait ? 200 : 150,
                //     height: orientation == Orientation.portrait ? 200 : 150,
                //   ),
                // ),
                const SizedBox(height: 40),

                // Music Controls
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     if (!hiddenData) ...[
                //       IconButton(
                //         onPressed: playPrevious,
                //         icon: const Icon(Icons.skip_previous,
                //             size: 80, color: Colors.blue),
                //       ),
                //     ],
                //     const SizedBox(width: 20),
                //     IconButton(
                //       onPressed: togglePlayPause,
                //       icon: Icon(
                //         isPlaying ? Icons.pause : Icons.play_arrow,
                //         size: 90,
                //         color: Colors.blue,
                //       ),
                //     ),
                //     const SizedBox(width: 20),
                //     if (!hiddenData) ...[
                //       IconButton(
                //         onPressed: playNext,
                //         icon: const Icon(Icons.skip_next,
                //             size: 80, color: Colors.blue),
                //       ),
                //     ],
                //   ],
                // ),

                // Like Button & Song Info (only visible after clicking play)
                // if (!hiddenData) ...[
                //   const SizedBox(height: 20),
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       IconButton(
                //         onPressed: toggleLike,
                //         icon: Icon(
                //           isLiked ? Icons.favorite : Icons.favorite_border,
                //           color: isLiked ? Colors.red : Colors.grey,
                //           size: 40,
                //         ),
                //       ),
                //       Text(
                //         "$singer - $song",
                //         style: const TextStyle(fontSize: 20),
                //       )
                //     ],
                //   ),
                // ],
                const SizedBox(height: 30),
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
              color: Color(0xff796EF8),
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

   Padding _progresssection() {
    double progress = _duration.inSeconds > 0
        ? _position.inSeconds / _duration.inSeconds
        : 0.0; // Calculate progress

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress, // Dynamic progress
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff796EF8)),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTime(_position), // Current time
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Text(
                formatTime(_duration), // Total duration
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ],
      ),
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
              image: const DecorationImage(
                image: AssetImage('assets/images/Music.jpg'),
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
