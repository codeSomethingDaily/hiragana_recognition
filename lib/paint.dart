import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class MyPaint extends StatefulWidget {
  const MyPaint(this.setParentImg, {super.key});
  final void Function(ui.Image) setParentImg;

  @override
  State<MyPaint> createState() => _MyPaintState();
}

class _MyPaintState extends State<MyPaint> {
  List<List<Offset>> lines = [];
  // List<Path> lines = [];

  Future<ui.Image> get rendered {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    MyCustomPainter painter = MyCustomPainter(lines);
    var size = context.size;
    painter.paint(canvas, size!);
    return recorder.endRecording().toImage(224, 224);
  }

  @override
  Widget build(BuildContext context) {
    void onPanStart(DragStartDetails details) {
      debugPrint('User started drawing');
      final point = details.localPosition;

      lines.add([point]);
      debugPrint(point.toString());
    }

    void onPanUpdate(DragUpdateDetails details) {
      final point = details.localPosition;

      if (point != lines.last.last) {
        setState(() {
          lines.last.add(point);
        });
      }
    }

    void onPanEnd(DragEndDetails details) {
      debugPrint('User ended drawing');
    }

    return Column(
      children: [
        Container(
            margin: const EdgeInsets.all(15.0),
            // padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 2.0)),
            child: GestureDetector(
              onPanStart: onPanStart,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              child: ClipRect(
                child: CustomPaint(
                  painter: MyCustomPainter(lines),
                  size: const Size(224, 224),
                ),
              ),
            )),
        ElevatedButton(
            onPressed: () {
              lines.clear();
            },
            child: const Text('clear')),
        ElevatedButton(
            onPressed: () async {
              widget.setParentImg(await rendered);
            },
            child: const Text("test")),
      ],
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<List<Offset>> lines;
  // List<Path> lines;

  MyCustomPainter(this.lines) : super();
  Function eq = const DeepCollectionEquality().equals;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.src);
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (var line in lines) {
      canvas.drawPoints(ui.PointMode.polygon, line, paint);
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return !eq(lines, oldDelegate.lines);
  }
}
