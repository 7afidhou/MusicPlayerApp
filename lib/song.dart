class Song {
  String name;
  String singer;
  String imagePath;
  String audioPath;
  Duration duration;
  bool isFavorite = false;

  Song({
    required this.name,
    required this.singer,
    required this.imagePath,
    required this.audioPath,
    required this.duration,
  });
  }

Song song1 =Song(
      name: 'Akbar Anani',
      singer: 'Marwan Khoury',  
      imagePath: 'assets/images/song1.jpg',
      audioPath: 'audios/Song1.mp3',
      duration: const Duration(minutes: 3, seconds: 30), );
Song song2 =Song(
      name: '#40 Paradise',
      singer: 'Ikson',
      imagePath: 'assets/images/song2.jpg',
      audioPath: 'audios/Song2.mp3',
      duration: const Duration(minutes: 4, seconds: 30), );
Song song3 =Song(
      name: 'Hakawa',
      singer: 'Asma Lmnawar',
      imagePath: 'assets/images/song3.jpg',
      audioPath: 'audios/Song3.mp3',
      duration: const Duration(minutes: 4, seconds: 30), );
  List<Song> songList = [song1, song2,song3];