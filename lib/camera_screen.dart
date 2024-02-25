import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';

Map<String,String> modelNames = {"YOLO":"YOLO","MOBILENET":"SSDMobileNet"};
enum TTSState {playing,stopped}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required  this.cameras});
  final List<CameraDescription> cameras;

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {

  late CameraController cameraController;
  late CameraImage cameraImage;
  List<dynamic> recognitionsList = [];
  int frameCount = 0;
  String? modelName = modelNames["MOBILENET"];
  late FlutterTts flutterTts;
  TTSState ttsState = TTSState.stopped;

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future _stop() async{
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TTSState.stopped);
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TTSState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TTSState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        ttsState = TTSState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TTSState.stopped;
      });
    });
  }

  void _speakObjectPosition(double centerX,double centerY,double left,double width,String obj){
    late String text;
    if(left<centerX && (left+width) < centerX){
      text = "$obj in left side. Move to right side";
      _speak(text);
    }else if(left<centerX && (left+width) > centerX){
      text = "$obj in middle. Move to side";
      _speak(text);
    }else if(left>centerX){
      text = "$obj in right side. Move to left side";
      _speak(text);
    }else{
      text = "$obj found.";
      _speak(text);
    }
  }

  initCamera() {
    cameraController = CameraController(widget.cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value) {
      if(!mounted){
        return ;
      }
      setState(() {
        cameraController.startImageStream((image) => {
              frameCount ++,
              cameraImage = image,
              if(frameCount % 10 == 0){ 
              frameCount = frameCount % 10,
              runModel(),
              }else{
              frameCount = frameCount % 10,
              }
            });
      });
    });
  }

  runModel() async {
    recognitionsList = await Tflite.detectObjectOnFrame(
      bytesList: cameraImage.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      model: modelName??"SSDMobileNet",
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    ) ?? [];

    setState(() {
      cameraImage;
    });
  }

  Future loadModel() async {
    Tflite.close();
    switch (modelName) {
      case "YOLO":
        await Tflite.loadModel(
        model: "assets/yolov2_tiny.tflite",
        labels: "assets/yolov2_tiny.txt");
        break;
      case "SSDMobileNet":
        await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");
      default:
      await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");
    }
    
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.stopImageStream();
    Tflite.close();
    flutterTts.stop();
  }

  @override
  void initState() {
    super.initState();
    initTts();
    loadModel();
    initCamera();
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (recognitionsList.isEmpty) return [];

    double factorX = screen.width;
    double factorY = screen.height;

    Color colorPick = Colors.pink;

    // for tts
    double centerX = factorX / 2;
    double centerY = factorY / 2;


    return recognitionsList.map((result) {
      _speakObjectPosition(centerX, centerY,result["rect"]["x"] * factorX, result["rect"]["w"] * factorX, result['detectedClass']);
      return Positioned(
        left: result["rect"]["x"] * factorX,
        top: result["rect"]["y"] * factorY,
        width: result["rect"]["w"] * factorX,
        height: result["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> list = [];

    list.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height - 100,
        child: SizedBox(
          height: size.height - 100,
          child: (!cameraController.value.isInitialized)
              ? Container()
              : AspectRatio(
                  aspectRatio: cameraController.value.aspectRatio,
                  child: CameraPreview(cameraController),
                ),
        ),
      ),
    );
    list.addAll(displayBoxesAroundRecognizedObjects(size));

    if(!cameraController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator()
        );
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Connected Screen")),
        backgroundColor: Colors.black,
        body: Container(
          margin: const EdgeInsets.only(top: 50),
          color: Colors.black,
          child: Stack(
            children: list,
          )
        ),
      ),
    );
  }
}
