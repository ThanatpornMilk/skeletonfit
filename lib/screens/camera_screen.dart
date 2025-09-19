import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/exercises.dart';  

class CameraScreen extends StatefulWidget {
  final ExerciseInfo exercise;   

  const CameraScreen({super.key, required this.exercise});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;        
  WebSocketChannel? _channel;                
  bool _isStreaming = false;

  String _pose = "N/A";
  double _confidence = 0.0;
  int _count = 0;
  int _reps = 0;

  final String serverIp = "10.0.2.2";
  final int serverPort = 8000;

  int _lastSentTime = 0;

  void _log(String msg, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      dev.log(msg, name: 'CameraScreen', error: error, stackTrace: stackTrace);
    }
  }

  @override
  void initState() {
    super.initState();
    _initWebSocket();
    _initCamera();
  }

  @override
  void dispose() {
    _isStreaming = false;
    _cameraController?.dispose();       
    _channel?.sink.close();              
    super.dispose();
  }

  void _initWebSocket() {
    final uri = Uri.parse('ws://$serverIp:$serverPort/ws/pose');
    _log("Connecting to WebSocket: $uri");

    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        if (!mounted) return;
        setState(() {
          _pose = (data["pose"] ?? "N/A").toString();
          _confidence = (data["confidence"] ?? 0).toDouble();
          _count = (data["count"] ?? 0) as int;
          _reps = (data["reps"] ?? 0) as int;
        });
      } catch (e, st) {
        _log('WS message parse error', error: e, stackTrace: st);
      }
    }, onError: (error, st) {
      _log("WebSocket error", error: error, stackTrace: st);
    }, onDone: () {
      _log("WebSocket closed (code: ${_channel?.closeCode})");
    });
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _log('No cameras available');
        return;
      }
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _cameraController = controller;

      await controller.initialize();
      if (!mounted) return;
      setState(() {});
      _startImageStream();
    } catch (e, st) {
      _log('Init camera error', error: e, stackTrace: st);
    }
  }

  void _startImageStream() {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    _isStreaming = true;
    controller.startImageStream((CameraImage image) async {
      if (!_isStreaming) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastSentTime < 200) return; // ~5fps
      _lastSentTime = now;

      try {
        if (_channel?.closeCode != null) {
          _log("WebSocket is closed, cannot send image");
          return;
        }

        final jpgBytes = await _convertCameraImageToJpg(image);
        final base64Image = base64Encode(jpgBytes);
        _channel?.sink.add(base64Image);
      } catch (e, st) {
        _log("Image conversion/send error", error: e, stackTrace: st);
      }
    });
  }

  Future<Uint8List> _convertCameraImageToJpg(CameraImage image) async {
    final width = image.width;
    final height = image.height;

    final imgImage = img.Image(width: width, height: height);

    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    for (int y = 0; y < height; y++) {
      final int yRow = y * width;
      final int uvRow = (y ~/ 2) * uvRowStride;

      for (int x = 0; x < width; x++) {
        final int uvIndex = uvRow + (x ~/ 2) * uvPixelStride;
        final int index = yRow + x;

        final int yp = yPlane[index];
        final int up = uPlane[uvIndex];
        final int vp = vPlane[uvIndex];

        int r = (yp + 1.403 * (vp - 128)).round();
        int g = (yp - 0.344 * (up - 128) - 0.714 * (vp - 128)).round();
        int b = (yp + 1.770 * (up - 128)).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        imgImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(img.encodeJpg(imgImage, quality: 80));
  }

  @override
  Widget build(BuildContext context) {
    final initialized = _cameraController?.value.isInitialized ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text("Real-Time Pose Detection - ${widget.exercise.name}"), 
      ),
      body: initialized
          ? Stack(
              children: [
                // พรีวิวกล้อง
                CameraPreview(_cameraController!),
                // กล่องข้อมูล
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.54),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pose: $_pose",
                            style: const TextStyle(color: Colors.white)),
                        Text(
                          "Confidence: ${(_confidence * 100).toStringAsFixed(2)}%",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text("Count: $_count",
                            style: const TextStyle(color: Colors.white)),
                        Text("Reps: $_reps",
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
