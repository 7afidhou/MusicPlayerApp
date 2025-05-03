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
import 'package:file/file.dart';
import 'package:file/local.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<Song> songs = [];
  List<Song> likedsongs = [];

  int index = 0;
  bool isPlaying = false;
  bool isLiked = false;
  bool hiddenData = true;
  int clickedTimes = 0;

  String singer = "Unknown Artist";
  String song = "No song selected";
  String audiopath = "";
  String imagepath = "assets/images/Music_logo.jpg";
  String lyrics = "";

  bool isLocalFile = true;
  String localPath = "";

  late AnimationController _controller;
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  Helper db = Helper();
  final FileSystem _fileSystem = const LocalFileSystem();

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
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    if (status.isGranted) {
      await _scanDeviceForAudioFiles();
    } else {
      // Handle case where permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Storage permission is required to access audio files"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanDeviceForAudioFiles() async {
    try {
      // This is a simplified approach - in a real app you'd want to properly scan directories
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          songs = result.files.map((file) => Song(
            name: p.basenameWithoutExtension(file.name),
            singer: "Unknown Artist",
            imagePath: "assets/images/Music_logo.jpg",
            audioPath: file.path!,
            lyrics: "",
          )).toList();

          if (songs.isNotEmpty) {
            index = 0;
            localPath = songs[0].audioPath;
            song = songs[0].name;
            isLocalFile = true;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error scanning files: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    if (songs.isEmpty) return;
    
    if (isPlaying) {
      _pauseMusic();
    } else {
      _player.play(DeviceFileSource(localPath)).then((_) {
        setState(() {
          isPlaying = true;
          hiddenData = false;
          clickedTimes++;
        });
      });
    }
  }

  Future<void> _pauseMusic() async {
    await _saveLastPosition();
    await _player.pause();
    setState(() => isPlaying = false);
  }

  Future<void> _resumeMusic() async {
    if (songs.isEmpty) return;
    
    await _player.play(DeviceFileSource(localPath), position: _position);
    setState(() => isPlaying = true);
  }

  void playNext() {
    if (songs.isEmpty || index >= songs.length - 1) return;
    
    setState(() {
      index++;
      localPath = songs[index].audioPath;
      song = songs[index].name;
      isPlaying = true;
      isLiked = likedsongs.any((s) => s.name == song && s.singer == singer);
    });
    
    _player.play(DeviceFileSource(localPath));
  }

  void playPrevious() {
    if (songs.isEmpty || index <= 0) return;
    
    setState(() {
      index--;
      localPath = songs[index].audioPath;
      song = songs[index].name;
      isPlaying = true;
      isLiked = likedsongs.any((s) => s.name == song && s.singer == singer);
    });
    
    _player.play(DeviceFileSource(localPath));
  }

  void toggleLike() async {
    if (songs.isEmpty) return;
    
    setState(() {
      isLiked = !isLiked;
    });

    if (isLiked) {
      await db.insertsong(Song(
        name: song,
        singer: singer,
        imagePath: imagepath,
        audioPath: localPath,
        lyrics: lyrics,
      ));
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
            if (songs.isEmpty) 
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "No songs found",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _scanDeviceForAudioFiles,
                      child: const Text("Scan for audio files"),
                    ),
                  ],
                ),
              ),
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
          Text("$song by $singer", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
          GestureDetector(
            onTap: songs.isNotEmpty ? toggleLike : null,
            onLongPress: goToFavorites,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border, 
              color: songs.isEmpty ? Colors.grey : (isLiked ? Colors.red : Colors.white), 
              size: 30),
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
          angle: isPlaying ? _controller.value * 2 * 3.1416 : 0,
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
        Text(song, 
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        Text(singer, 
            style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
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
          IconButton(
            onPressed: songs.isNotEmpty ? playPrevious : null,
            icon: Icon(Icons.skip_previous_outlined, size: 60, color: songs.isNotEmpty ? Colors.white : Colors.grey),
          ),
          IconButton(
            onPressed: songs.isNotEmpty ? togglePlayPause : null,
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, 
              size: 100, 
              color: songs.isNotEmpty ? const Color(0xff796EF8) : Colors.grey),
          ),
          IconButton(
            onPressed: songs.isNotEmpty ? playNext : null,
            icon: Icon(Icons.skip_next_outlined, size: 60, color: songs.isNotEmpty ? Colors.white : Colors.grey),
          ),
          IconButton(
            onPressed: _scanDeviceForAudioFiles,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}