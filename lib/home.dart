import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPlaying = false;
  bool isLiked = false;
  bool hiddenData = true;
  int clickedTimes = 0;
  String singer = "Marwan Khoury";
  String song = "Akbar Anani";

  void togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      clickedTimes++;
      if (clickedTimes > 0) hiddenData = false;
    });
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  void playNext() {}

  void playPrevious() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Music Image
                Center(
                  child: Image.asset(
                    'assets/images/Music.jpg',
                    width: orientation == Orientation.portrait ? 200 : 150,
                    height: orientation == Orientation.portrait ? 200 : 150,
                  ),
                ),
                const SizedBox(height: 40),

                // Music Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!hiddenData) ...[
                      IconButton(
                        onPressed: playPrevious,
                        icon: const Icon(Icons.skip_previous,
                            size: 80, color: Colors.blue),
                      ),
                    ],
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: togglePlayPause,
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 90,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (!hiddenData) ...[
                      IconButton(
                        onPressed: playNext,
                        icon: const Icon(Icons.skip_next,
                            size: 80, color: Colors.blue),
                      ),
                    ],
                  ],
                ),

                // Like Button & Song Info (only visible after clicking play)
                if (!hiddenData) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: toggleLike,
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 40,
                        ),
                      ),
                      Text(
                        "$singer - $song",
                        style: const TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
