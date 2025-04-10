class Song {
  String name;
  String singer;
  String imagePath;
  String audioPath;
  Duration duration;
  bool isFavorite = false;
  String lyrics;

  Song({
    required this.name,
    required this.singer,
    required this.imagePath,
    required this.audioPath,
    required this.duration,
    required this.lyrics,
  });
  }

Song song1 =Song(
      name: 'Akbar Anani',
      singer: 'Marwan Khoury',  
      imagePath: 'assets/images/song1.jpg',
      audioPath: 'audios/Song1.mp3',
      duration: const Duration(minutes: 3, seconds: 30), 
      lyrics:'''بعرف منك إلي
ولا رح بتكوني يوم
بعرف هوانا مرحلة
واقف عبابي اللوم
 
لكن مارح اسمح هواكي يضيع
و يمرق عليي بكرى من دونك
تا اشتري حبك عمر رح بيع
و كحل عينيي بلفتة عيونك
 
و بعرف رح تنزل دمعة
دمعة تطفي هالشمعة
الضويناها بالعتمة
و
و تشتي علينا تشتي
إيام و حبك إنتي
أكتر من كلشي
و خلي هالليل يغار
 
مضيع قبلك انا حب كبير
و ما بنسى هاك الإنسانة
و هلأ انتي و غلطان كتير
لو ضيعتك مرة تانيي
 
أنا كرمالك بعلن نفسي
بهالدنيي
أكبر أناني
أكبر أناني''');
Song song2 =Song(
      name: '#40 Paradise',
      singer: 'Ikson',
      imagePath: 'assets/images/song2.jpg',
      audioPath: 'audios/Song2.mp3',
      duration: const Duration(minutes: 4, seconds: 30), 
      lyrics: '');
Song song3 =Song(
      name: 'Hakawa',
      singer: 'Asma Lmnawar',
      imagePath: 'assets/images/song3.jpg',
      audioPath: 'audios/Song3.mp3',
      duration: const Duration(minutes: 4, seconds: 30), 
      lyrics: ''' 
يالاه يالاه معايا
نعيشوا ليلة نعيشوا يوم
يالاه يالاه معايا
نعيشوا ليلة نعيشوا يوم
يالاه يالاه معايا
نعيشوا ليلة نعيشوا يوم
يالاه يالاه معايا
نعيشوا ليلة نعيشوا يوم


أنا ليك وإنت ليا
الدنيا تفرح بنا (أيوة)
دنيا تفرح بنا
ونعيشوا أيام زينة
أنا ليك وإنت ليا
الدنيا تفرح بنا (أيوة)
دنيا تفرح بنا
ونعيشوا أيام زينة


هاكاوا زيداوا
رحنا في الهوى سوا
هاكاوا زيداوا
رحنا في الهوى سوا
هاكاوا زيداوا
رحنا في الهوى سوا
هاكاوا زيداوا
رحنا في الهوى سوا
      
      ''');
  List<Song> songList = [song1, song2,song3];