import 'package:audioplayers/audioplayers.dart';

class Song {
  String name;
  String singer;
  String imagePath;
  String audioPath;
  Duration duration;

  Song({
    required this.name,
    required this.singer,
    required this.imagePath,
    required this.audioPath,
    required this.duration,
  });
  }

Song song1 =Song(
      name: 'Song 1',
      singer: 'Singer 1',
      imagePath: 'assets/images/song1.jpg',
      audioPath: 'assets/audios/song1.mp3',
      duration: const Duration(minutes: 3, seconds: 30), );
Song song2 =Song(
      name: 'Song 2',
      singer: 'Singer 2',
      imagePath: 'assets/images/song2.jpg',
      audioPath: 'assets/audios/song2.mp3',
      duration: const Duration(minutes: 4, seconds: 30), );
  List<Song> songList = [song1, song2];