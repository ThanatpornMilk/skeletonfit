import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late WebSocketChannel _channel;
  bool _isStreaming = false;

  String _pose = "N/A";
  double _confidence = 0.0;
  int _count = 0;
  int _reps = 0;

  final String serverIp = "10.0.2.2"; // เปลี่ยนเป็น IP server จริงถ้าไม่ใช้ emulator
  final int serverPort = 8000;

  int _lastSentTime = 0;

  @override
  void initState() {
    super.initState();
    _initWebSocket();
    _initCamera();
  }

  @override
  void dispose() {
    _isStreaming = false;
    _cameraController.dispose();
    _channel.sink.close();
    super.dispose();
  }

  void _initWebSocket() {
    final uri = Uri.parse('ws://$serverIp:$serverPort/ws/pose');
    print("Connecting to WebSocket: $uri");

    _channel = WebSocketChannel.connect(uri);

    _channel.stream.listen((message) {
      print("Received from WS: $message");
      final data = jsonDecode(message);
      setState(() {
        _pose = data["pose"] ?? "N/A";
        _confidence = (data["confidence"] ?? 0).toDouble();
        _count = data["count"] ?? 0;
        _reps = data["reps"] ?? 0;
      });
    }, onError: (error) {
      print("WebSocket error: $error");
    }, onDone: () {
      print("WebSocket closed");
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    setState(() {});

    _startImageStream();
  }

  void _startImageStream() {
    _isStreaming = true;
    _cameraController.startImageStream((CameraImage image) async {
      if (!_isStreaming) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastSentTime < 200) return; // ส่งทุก 200ms (5fps)
      _lastSentTime = now;

      try {
        if (_channel.closeCode != null) {
          print("WebSocket is closed, cannot send image");
          return;
        }

        final jpgBytes = await _convertCameraImageToJpg(image);
        final base64Image = base64Encode(jpgBytes);

        print("Sending image of size: ${base64Image.length}");
        _channel.sink.add(base64Image);
      } catch (e) {
        print("Image conversion/send error: $e");
      }
    });
  }

  Future<Uint8List> _convertCameraImageToJpg(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;
    final img.Image imgImage = img.Image(width: width, height: height);

    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + 1.403 * (vp - 128)).round();
        int g = (yp - 0.344 * (up - 128) - 0.714 * (vp - 128)).round();
        int b = (yp + 1.770 * (up - 128)).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        imgImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(img.encodeJpg(imgImage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Real-Time Pose Detection")),
      body: _cameraController.value.isInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pose: $_pose", style: const TextStyle(color: Colors.white)),
                        Text("Confidence: ${(_confidence * 100).toStringAsFixed(2)}%", style: const TextStyle(color: Colors.white)),
                        Text("Count: $_count", style: const TextStyle(color: Colors.white)),
                        Text("Reps: $_reps", style: const TextStyle(color: Colors.white)),
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
