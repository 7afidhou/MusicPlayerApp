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
  String singer = "Marwan Khouri";
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
                Padding(
                padding:  const EdgeInsets.only(left: 2, right: 2),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween
                  ,children: [
                  IconButton(
                    onPressed: playPrevious,
                    icon: const Icon(Icons.skip_previous_outlined,
                        size: 60, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: togglePlayPause,
                    icon: Icon(
                      isPlaying ?  Icons.play_circle_filled_rounded :Icons.pause_circle_filled_rounded ,
                      size: 120,
                      color: Color(0xff796EF8),
                    ),
                  ),
                  IconButton(
                    onPressed: playNext,
                    icon: const Icon(Icons.skip_next_outlined,
                        size: 60, color: Colors.white),
                  ),
                ],),
                ),


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

  Padding _progresssection() {
    return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10), // Rounded corners
                    child: const LinearProgressIndicator(
                      value: 0.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff796EF8)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "1:30",
                      style:  TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      "3:00",
                      style:TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
                ]),
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

  Container _photosection() {
    return Container(
      width: 200, // Square size
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            spreadRadius: 7, // Spread of the shadow
            blurRadius: 10, // Softness of the shadow
            offset: const Offset(4, 4), // Position of the shadow
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/Music.jpg'),
          fit: BoxFit.cover, // Ensures the image covers the square
        ),
      ),
    );
  }

  Padding _appheader() {
    return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
            ),
            Text("$song by $singer",
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: toggleLike,
              icon: Icon(
                Icons.favorite,
                color: isLiked ? Colors.red : Colors.white,
                size: 30,
              ),
            ),
          ],
        ));
  }
}
