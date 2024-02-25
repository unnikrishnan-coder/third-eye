import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:third_eye/camera_screen.dart';
import 'package:third_eye/main.dart';

class ConnectedScreen extends StatelessWidget{
  ConnectedScreen({super.key,required this.cameras});
  final List<CameraDescription> cameras;
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future _stop() async{
    await flutterTts.stop();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connected Screen"),leading: Container(),),
      body:  Center(
        child: Column(
          children: [
             Padding(
              padding: const EdgeInsets.all(8.0),
              child:  Center(
                child: GestureDetector(
                  onTap: () {
                _stop();
                _speak("CONNECTED TO MODULE");
              },
                  child: const Text(
                    "CONNECTED TO MODULE",
                    style: TextStyle(fontSize: 40.0,fontWeight: FontWeight.bold,),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onDoubleTap: () {
                if(cameras.isNotEmpty){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen(cameras: cameras)));
                    }else{
                      return ;
                    }
              },
              child: ElevatedButton(
                  onPressed: () {
                    _stop();
                _speak("START CAPTURING");
                  },
                  child: const Text("START CAPTURING")
              ),
            ),
            GestureDetector(
              onDoubleTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context)=> MyHome(cameras: cameras,)),);
              },
              child: ElevatedButton(
                  onPressed: () {
                   _stop();
                   _speak("TERMINATE CONNECTION");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("TERMINATE CONNECTION"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}