import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/ani_video_player.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:ani_video_player/widgets/video_button.dart';
import 'package:flutter/material.dart';

void main() async {
  await AniVideo.ensureInitialized();

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
                    controller: AniController(
                      videoConfiguration: VideoConfiguration(
                        controls: VideoControls(showBackButton: false),
                      ),
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
                AniVideo.launchVideoFullScreen(
                  context,
                  url,
                  controller: AniController(
                    videoConfiguration: VideoConfiguration(
                      details: VideoDetails(title: "Example video"),
                      controls: VideoControls(
                        showFullScreenButton: false,
                        onNextButtonPressed: (controller) {
                          controller.pause();

                          controller.videoConfiguration
                            ..details.title = "Example video 2"
                            ..details.start = const Duration(seconds: 30);

                          controller.setVideo(
                            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                          );
                        },
                        extra: VideoButton(
                          label: "EXTRA BUTTON",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      onComplete: (controller) => Navigator.pop(context),
                      onBuffering: (value, controller) async {
                        if (!value) return;

                        await Future.delayed(const Duration(seconds: 10));
                        if (controller.isBuffering()) {
                          //VIDEO WAS 10 SECONDS BUFFERING SO WE ASSUME IT CRASHED
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
