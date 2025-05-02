import 'dart:async';
import 'favorite.dart';
import 'song.dart';
import 'db.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:marquee/marquee.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final List<Song> songs = songList;
  List<Song> likedsongs = [];

  int index = 0;
  bool isPlaying = false;
  bool isLiked = false;
  bool hiddenData = true;
  int clickedTimes = 0;

  String singer = songList[0].singer;
  String song = songList[0].name;
  String audiopath = songList[0].audioPath;
  String imagepath = songList[0].imagePath;
  String lyrics = songList[0].lyrics;

  bool isLocalFile = false;
  String localPath = "";

  late AnimationController _controller;
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  Helper db = Helper();

  StreamSubscription? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();
  final double shakeThreshold = 15.0;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadFavorites();
    _loadLastPosition();
    _startListeningToShake();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    WidgetsBinding.instance.addObserver(this);

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _player.dispose();
    _accelerometerSubscription?.cancel();
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

void _startListeningToShake() {
  _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
    double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (acceleration > shakeThreshold) {
      DateTime now = DateTime.now();
      if (now.difference(_lastShakeTime).inMilliseconds > 2000) {
        _lastShakeTime = now;
        togglePlayPause();
      }
    }
  });
}

  Future<void> _requestPermission() async {
    await Permission.storage.request();
  }

  Future<void> _loadFavorites() async {
    List<Map> songsfetched = await db.readsongs();
    setState(() {
      likedsongs = songsfetched.map((song) => Song(
        name: song['name'],
        singer: song['singer'],
        imagePath: song['imagePath'],
        audioPath: song['audioPath'],
        lyrics: song['lyrics'],
      )).toList();

      isLiked = likedsongs.any((s) => s.name == song && s.singer == singer);
    });
  }

  Future<void> _loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    int lastPosition = prefs.getInt('last_position') ?? 0;
    _position = Duration(milliseconds: lastPosition);
  }

  Future<void> _saveLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_position', _position.inMilliseconds);
  }

  void togglePlayPause() {
    if (isPlaying) {
      _pauseMusic();
    } else {
      if (isLocalFile) {
        _player.play(DeviceFileSource(localPath)).then((_) {
          setState(() {
            isPlaying = true;
            hiddenData = false;
            clickedTimes++;
          });
        });
      } else {
        _player.play(AssetSource(audiopath)).then((_) {
          setState(() {
            isPlaying = true;
            hiddenData = false;
            clickedTimes++;
          });
        });
      }
    }
  }

  Future<void> _pauseMusic() async {
    await _saveLastPosition();
    await _player.pause();
    setState(() => isPlaying = false);
  }

  Future<void> _resumeMusic() async {
    if (isLocalFile) {
      await _player.play(DeviceFileSource(localPath), position: _position);
    } else {
      await _player.play(AssetSource(audiopath), position: _position);
    }
    setState(() => isPlaying = true);
  }

  void playNext() {
    if (index < songs.length - 1) {
      index++;
      updateSongDetails();
      _player.play(AssetSource(audiopath));
    }
  }

  void playPrevious() {
    if (index > 0) {
      index--;
      updateSongDetails();
      _player.play(AssetSource(audiopath));
    }
  }

  void updateSongDetails() {
    final current = songs[index];
    setState(() {
      singer = current.singer;
      song = current.name;
      audiopath = current.audioPath;
      imagepath = current.imagePath;
      lyrics = current.lyrics;
      isLocalFile = false;
      isPlaying = true;
      isLiked = likedsongs.any((s) => s.name == song && s.singer == singer);
    });
  }
void pickAudioFile() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.audio);
  if (result != null && result.files.single.path != null) {
    localPath = result.files.single.path!;
    isLocalFile = true;

    await _player.setSource(DeviceFileSource(localPath));
    _player.getDuration().then((d) {
      final filename = p.basenameWithoutExtension(localPath); // Extract filename without extension

      setState(() {
        _duration = d ?? Duration.zero;
        song = filename; // Use filename as song title
        singer = "Local Artist";
        imagepath = "assets/images/Music_logo.jpg";
      });

      togglePlayPause(); // Play the uploaded song
    });
  }
}


  void toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      songs[index].isFavorite = isLiked;
    });

    if (isLiked) {
      await db.insertsong(songs[index]);
    } else {
      await db.deletesongByNameAndSinger(song, singer);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLiked ? "Added to Liked Songs" : "Removed from Liked Songs",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isLiked ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void goToFavorites() {
    _pauseMusic();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritePage())).then((_) {
      _resumeMusic();
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181787),
      body: SingleChildScrollView(
        child: Column(
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
      ),
    );
  }

  Padding _appheader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30)),
          Text("$song by $singer", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          GestureDetector(
            onTap: toggleLike,
            onLongPress: goToFavorites,
            child: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  AnimatedBuilder _photosection() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.1416,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 7, blurRadius: 10)],
              image: DecorationImage(image: AssetImage(imagepath), fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  Column _songdatasection() {
    return Column(
      children: [
        Text(song, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        Text(singer, style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Column _progresssection() {
    return Column(
      children: [
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
            onChanged: (value) => setState(() {
              _position = Duration(milliseconds: value.toInt());
            }),
            onChangeEnd: (value) {
              _player.seek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatTime(_position), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(formatTime(_duration), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Padding _controlsection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: playPrevious, icon: const Icon(Icons.skip_previous_outlined, size: 60, color: Colors.white)),
          IconButton(
            onPressed: togglePlayPause,
            icon: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, size: 100, color: const Color(0xff796EF8)),
          ),
          IconButton(onPressed: playNext, icon: const Icon(Icons.skip_next_outlined, size: 60, color: Colors.white)),
          IconButton(onPressed: pickAudioFile, icon: const Icon(Icons.upload_file, color: Colors.white)),
        ],
      ),
    );
  }
}
