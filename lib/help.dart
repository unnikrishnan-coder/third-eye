import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

const String helperText = """ Third Eye Navigation Assistant

Welcome to Third Eye, your personalized navigation assistant designed to empower the visually impaired. This app is crafted to provide an accessible and intuitive navigation experience. Below is a guide to the three main screens of the app:

Home Screen:
Upon launching Third Eye, you'll find the home screen, your starting point for navigation. Here, you can explore the following features:

Explore Features: Single-tap on any icon to hear a brief description of its function.
Navigation Module: Connect to an external module for enhanced navigation. Double-tap to activate or deactivate the module.

External Module Screen:
After connecting to the external module, you'll access additional functionalities to improve your navigation experience. Here's what you can do:

Explore Features: Single-tap on any element to hear its description.
Start Capture: Double-tap the "Start Capture" button to move to the third screen and initiate video capturing and obstacle detection.

Video Capturing and Obstacle Detection Screen:
This screen provides real-time video capturing and obstacle detection to assist you in navigating your surroundings. Here's how to use it:

Explore Features: Single-tap on any part of the screen to hear a description of the surroundings.
Capture Obstacles: Double-tap the screen to capture obstacles and receive audio feedback about their location and distance.
Stop Capture: Double-tap again to stop the obstacle detection.

Additional Tips:
Adjust the volume of your device for a comfortable experience.
Use headphones for a more immersive audio experience.
For detailed instructions on app features, you can access the Help section from the menu.

Third Eye is committed to making your navigation experience as seamless as possible. If you have any feedback or encounter issues, please feel free to contact our support team.

Thank you for choosing Third Eye, and we hope it enhances your mobility and independence!""";

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future _stop() async {
    await flutterTts.stop();
  }
  @override
  void dispose() {
    super.dispose();
    _stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Help"),),
        body: GestureDetector(
          onTap: (){
            _stop();
            _speak(helperText);
          },
          child: const SizedBox(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: SingleChildScrollView(child: Text(helperText,style: TextStyle(fontSize: 20.0),)),
            ),
          ),
        )
    );
  }
}
