// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pytorch_hiragana/flutter_pytorch_hiragana.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hiragana_recognition/paint.dart';

import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<img.Image> convertFlutterUiToImage(ui.Image uiImage) async {
  final uiBytes = await uiImage.toByteData();
  return img.Image.fromBytes(
      width: uiImage.width,
      height: uiImage.height,
      bytes: uiBytes!.buffer,
      numChannels: 4);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Hiragana classifier'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image? im;
  final hiragana = FlutterPytorchHiragana();
  String predicted = "";
  String googlePredicted = "";
  // final textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hiragana.initModel();
  }

  void onPredictButtonPressed() async {
    if (im != null) {
      // img!.toByteData( )
      img.Image imgim = await convertFlutterUiToImage(im!);
      // final directory = await getApplicationDocumentsDirectory();
      final directory = await getExternalStorageDirectory();
      final bmpPath = p.join(directory!.path, "image.bmp");
      // debugPrint(bmpPath);
      // img.encodePngFile(pngPath, imgim);
      img.encodeBmpFile(bmpPath, imgim);

      // final test = await hiragana.predictProbability(imgim);
      // debugPrint(test.toString());
      final res = await hiragana.predictHiragana(imgim);
      if (mounted) {
        setState(() {
          predicted = res;
        });
      }
      // final f = File(bmpPath);
      // final inputImage = InputImage.fromFile(f);
      // final recognizedText = await textRecognizer.processImage(inputImage);

      // final String text = recognizedText.text;
      if (mounted) {
        setState(() {
          // googlePredicted = text;
        });
      }
    }
  }

  void setImg(ui.Image im) {
    setState(() {
      this.im = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    var mPaint = MyPaint(setImg);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            mPaint,
            ElevatedButton(
                onPressed: onPredictButtonPressed,
                child: const Text("predict")),
            Text(predicted),
            Text(googlePredicted),
          ],
        ),
      ),
    );
  }
}
