import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _player = AudioPlayer();
  List<File> _songs = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _permissionGranted = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  
  static const platform = MethodChannel('com.example.blankproject/shake');
  late StreamSubscription<void> _shakeSubscription;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _initPlayer();
    _checkPermissions();
    _initShakeDetection();
  }

  void _initShakeDetection() {
    _shakeSubscription = EventChannel('com.example.blankproject/shake_event')
        .receiveBroadcastStream()
        .listen((_) => _handleShake());
    
    // Start native shake detection
    platform.invokeMethod('startShakeDetection');
  }

  void _handleShake() {
    final now = DateTime.now();
    if (_lastShakeTime == null || 
        now.difference(_lastShakeTime!) > const Duration(seconds: 2)) {
      _lastShakeTime = now;
      _togglePlayPause();
      
      // Visual feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPlaying ? 'Paused by shake' : 'Playing by shake'),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pauseMusic();
    } else if (_songs.isNotEmpty) {
      _playMusic();
    }
  }

  Future<void> _initPlayer() async {
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerComplete.listen((_) {
      setState(() => _isPlaying = false);
      _playNext();
    });
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);
    
    if (await Permission.audio.isGranted || 
        await Permission.audio.request().isGranted) {
      await _handlePermissionGranted();
      return;
    }
    
    if (await Permission.storage.isGranted || 
        await Permission.storage.request().isGranted) {
      await _handlePermissionGranted();
      return;
    }

    setState(() => _isLoading = false);
    
    if (await Permission.storage.isPermanentlyDenied || 
        await Permission.audio.isPermanentlyDenied) {
      await _showPermissionDeniedDialog();
    }
  }

  Future<void> _handlePermissionGranted() async {
    setState(() {
      _permissionGranted = true;
      _isLoading = false;
    });
    await _scanDeviceForAudioFiles();
  }

  Future<void> _scanDeviceForAudioFiles() async {
    try {
      setState(() => _isLoading = true);
      
      List<Directory> directoriesToScan = [
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Music'),
        Directory('/storage/emulated/0/Documents'),
        Directory('/storage/emulated/0/Media'),
        Directory('/storage/emulated/0/Android/media'),
      ];

      List<File> audioFiles = [];
      
      for (var dir in directoriesToScan) {
        if (await dir.exists()) {
          try {
            await for (var entity in dir.list(recursive: true)) {
              if (entity is File && _isAudioFile(entity.path)) {
                audioFiles.add(entity);
              }
            }
          } catch (e) {
            debugPrint("Error scanning ${dir.path}: $e");
          }
        }
      }

      audioFiles = audioFiles.toSet().toList();

      setState(() {
        _songs = audioFiles;
        if (_songs.isNotEmpty) {
          _currentIndex = 0;
          _playMusic();
        }
      });
    } catch (e) {
      debugPrint("Error scanning files: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error scanning music: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isAudioFile(String path) {
    final ext = p.extension(path).toLowerCase();
    return ['.mp3', '.wav', '.aac', '.ogg', '.m4a', '.flac', '.opus'].contains(ext);
  }

  Future<void> _playMusic() async {
    if (_songs.isEmpty) return;
    
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(DeviceFileSource(_songs[_currentIndex].path));
      setState(() {
        _isPlaying = true;
        _controller.repeat();
      });
    } catch (e) {
      debugPrint("Play error: $e");
    }
  }

  Future<void> _pauseMusic() async {
    try {
      await _player.pause();
      setState(() {
        _isPlaying = false;
        _controller.stop();
      });
    } catch (e) {
      debugPrint("Pause error: $e");
    }
  }

  void _playNext() {
    if (_songs.isEmpty || _currentIndex >= _songs.length - 1) return;
    
    setState(() => _currentIndex++);
    _playMusic();
  }

  void _playPrevious() {
    if (_songs.isEmpty || _currentIndex <= 0) return;
    
    setState(() => _currentIndex--);
    _playMusic();
  }

  String _getSongName(File file) => p.basenameWithoutExtension(file.path);

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> _showPermissionDeniedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Music Player needs access to your audio files to play music. '
              'Please enable storage permissions in app settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    platform.invokeMethod('stopShakeDetection');
    _shakeSubscription.cancel();
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        actions: [
          if (_permissionGranted)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _scanDeviceForAudioFiles,
            ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : !_permissionGranted
                ? _buildPermissionView()
                : _songs.isEmpty
                    ? _buildEmptyView()
                    : _buildPlayerView(),
      ),
    );
  }

  Widget _buildPermissionView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Music Player needs access to your audio files",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _checkPermissions,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text("GRANT PERMISSION"),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: openAppSettings,
            child: const Text("Open Settings Manually"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("No songs found"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _scanDeviceForAudioFiles,
          child: const Text("Scan Again"),
        ),
      ],
    );
  }

  Widget _buildPlayerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.rotate(
              angle: _isPlaying ? _controller.value * 2 * pi : 0,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage("assets/images/Music_logo.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        Text(
          _getSongName(_songs[_currentIndex]),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "${_currentIndex + 1}/${_songs.length}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 40),
        Slider(
          min: 0,
          max: _duration.inSeconds.toDouble(),
          value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
          onChanged: (value) {
            _player.seek(Duration(seconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatTime(_position)),
              Text(_formatTime(_duration)),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 40),
              onPressed: _playPrevious,
            ),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 60,
              ),
              onPressed: _isPlaying ? _pauseMusic : _playMusic,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, size: 40),
              onPressed: _playNext,
            ),
          ],
        ),
      ],
    );
  }
}