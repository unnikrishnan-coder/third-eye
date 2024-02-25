import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:third_eye/connected_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:third_eye/help.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,required this.cameras});
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Third Eye",
      home: MyHome(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHome extends StatelessWidget {
  MyHome({super.key,required this.cameras});
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
      appBar: AppBar(title: const Text("Third Eye"),),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Text('THIRD EYE',style: TextStyle(color: Colors.white,fontSize: 30.0,fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                  Text('A navigational aid for the visually impaired',style: TextStyle(color: Colors.white,fontSize: 20.0)),
                ],
              )
            ),
            ListTile(
              title: const Text("Settings",style: TextStyle(fontSize: 20.0)),
              onTap: (){
                debugPrint("Settings");
              }
            ),
            ListTile(
                title: const Text("Help",style: TextStyle(fontSize: 20.0)),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const HelpScreen()));
                }
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                _stop();
                _speak("PHONE READY TO PAIR WITH NAVIGATION MODULE");
              },
              child: const Padding(
                padding:  EdgeInsets.all(8.0),
                child:  Text("PHONE READY TO PAIR WITH NAVIGATION MODULE",style: TextStyle(fontSize: 40.0,fontWeight: FontWeight.bold)),
              ),
            ),
            GestureDetector(
              onDoubleTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ConnectedScreen(cameras: cameras)));
              },
              child: ElevatedButton(
                  onPressed: () {
                    _stop();
                    _speak("CONNECT TO MODULE");
                  },
                  child: const Text("CONNECT TO MODULE")),
            ),
          ],
        ),
      ),
    );
  }
}
