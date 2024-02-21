import 'package:ani_video_player/ani_video_player.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget videoWidget = Container();

  final url =
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            videoWidget,
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue,
                child: Text(
                  videoWidget is Container ? "Show Video" : "Hide Video",
                ),
              ),
              onTap: () {
                if (videoWidget is! Container) {
                  setState(() => videoWidget = Container());
                  return;
                }

                setState(() {
                  videoWidget = AniVideo(
                    url: url,
                    videoConfiguration: VideoConfiguration(
                      showBackButton: false,
                      showNextButton: true,
                    ),
                  );
                });
              },
            ),
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue,
                child: const Text("Launch Video in new Screen"),
              ),
              onTap: () {
                AniVideo.launchVideo(context, url);
              },
            ),
          ],
        ),
      ),
    );
  }
}
