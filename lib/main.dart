import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canvas Drawing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DrawingScreen(),
    );
  }
}

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _globalKey = GlobalKey();

  List<DrawingPoint> points = [];
  Color selectedColor = Colors.red;
  double strokeWidth = 4.0;
  bool isZooming = false;
  String imagePath = 'assets/image/black_image.png';

  Future<void> _shareDrawing() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/drawing.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      final result = await SharePlus.instance.share(
        ShareParams(
          text: 'Check out my drawing!',
          files: [XFile(imagePath)],
        ),
      );

      print("Shared: ${result.status}, raw: ${result.raw}");
    } catch (e) {
      print("Error sharing drawing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Canvas Drawing with Zoom'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareDrawing,
            ),
          ]
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () => setState(() => isZooming = false),
                  icon: Icon(Icons.draw,color: isZooming ? Colors.grey : Colors.black)
              ),
              IconButton(
                  onPressed: () => setState(() => isZooming = true),
                  icon: Icon(Icons.zoom_in, color:isZooming ? Colors.black : Colors.grey)
              ),
              IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => points.clear())
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push<String>(context, MaterialPageRoute(builder: (context) => Imageview())).then((value) {
                      if(value == null) return;
                      setState(() {
                        imagePath = value;
                      });
                    });
                  },
                  icon: Icon(Icons.image, color: Colors.black)
              ),
            ],
          ),
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: isZooming ? true : false,
                scaleEnabled: isZooming ? true : false,
                minScale: 1.0,
                maxScale: 10.0,
                child: IgnorePointer(
                  ignoring: isZooming,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        points.add(DrawingPoint(
                          details.localPosition,
                          selectedColor,
                          strokeWidth,
                        ));
                      });
                    },
                    onPanEnd: (_) {
                      setState(() {
                        points.add(DrawingPoint(null, selectedColor, strokeWidth));
                      });
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.contain)),
                        Positioned.fill(child: CustomPaint(painter: DrawingPainter(points), size: Size.infinite)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildColorButton(Colors.black),
            _buildColorButton(Colors.red),
            _buildColorButton(Colors.blue),
            _buildColorButton(Colors.green),
            Slider(
                min: 1.0,
                max: 10.0,
                value: strokeWidth,
                onChanged: (value) => setState(() => strokeWidth = value)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: CircleAvatar(
          backgroundColor: color,
          radius: 15,
          child: selectedColor == color ? const Icon(Icons.check, color: Colors.white) : null
      ),
    );
  }
}

class DrawingPoint {
  final Offset? position;
  final Color color;
  final double strokeWidth;

  DrawingPoint(this.position, this.color, this.strokeWidth);
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
    Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].position != null && points[i + 1].position != null) {
        paint.color = points[i].color;
        paint.strokeWidth = points[i].strokeWidth;
        canvas.drawLine(points[i].position!, points[i + 1].position!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class Imageview extends StatelessWidget {
  Imageview({super.key});

  final List<String> imagePath = [
    "black_image.png",
    "grey_image.png",
    "nature_image.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Image"),
      ),
      body: ListView.separated(
        itemCount: 3,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                Navigator.pop<String>(context,'assets/image/${imagePath[index]}');
              },
              child: Image.asset("assets/image/${imagePath[index]}",fit: BoxFit.contain)
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 10);
        },
      ),
    );
  }
}
