import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/ani_video_player.dart';
import 'package:ani_video_player/utils/keys.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:ani_video_player/widgets/video_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

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
                    controller: AniController(
                      VideoConfiguration(
                        url: url,
                        controls: VideoControls(showBackButton: false),
                      ),
                    ),
                  );
                });
              },
            ),
            GestureDetector(
              onTap: launchFullScreen,
              child: Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyUpEvent &&
                      event.logicalKey.keyLabel == Keys.keyCenter) {
                    launchFullScreen();
                    return KeyEventResult.handled;
                  }

                  return KeyEventResult.ignored;
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue,
                  child: const Text("Launch Video in new Screen"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void launchFullScreen() {
    AniVideo.launchVideoFullScreen(
      context,
      AniController(
        VideoConfiguration(
          url: url,
          details: VideoDetails(
            title: "Example video",
            extraTitle: " - 1",
          ),
          controls: VideoControls(
            showFullScreenButton: false,
            nextButtonLabel: "SKIP",
            onNextButtonPressed: (controller) {
              controller.pause();

              controller.videoConfiguration
                ..details.title = "Example video"
                ..details.extraTitle = " - 2"
                ..details.start = const Duration(seconds: 30)
                ..controls.onNextButtonPressed = null;

              controller.setVideo(
                "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
              );
            },
            extra: (controller) => VideoButton(
              label: "EXTRA 1",
              onPressed: () {
                Navigator.pop(context);
              },
              onPressBack: () {
                print("Prevented back");
              },
            ),
            extra2: (controller) => VideoButton(
              iconData: Icons.replay_outlined,
              label: "EXTRA 2",
              onPressed: () {
                Navigator.pop(context);
              },
              onPressBack: () {
                print("Prevented back");
              },
            ),
          ),
          onComplete: (controller) => Navigator.pop(context),
          onBuffering: (value, controller) async {
            if (!value) return;

            await Future.delayed(const Duration(seconds: 10));
            if (controller.isBuffering()) {
              //VIDEO WAS 10 SECONDS BUFFERING SO WE ASSUME IT CRASHED
              print("BUFFERING EXAMPLE");
            }
          },
        ),
      ),
    );
  }
}
