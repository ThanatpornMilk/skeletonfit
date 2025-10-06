import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final String exercise;

  const CameraScreen({super.key, required this.exercise});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late WebSocketChannel _channel;
  bool _isStreaming = false;

  // ---------------- State ----------------
  String? _selectedPose;
  double _confidence = 0.0;
  Map<String, int> _reps = {};
  Map<String, Map<String, double>> _holds = {};

  // ---------------- Config ----------------
  final String serverIp = "10.0.2.2"; // Emulator
  final int serverPort = 8000;
  int _lastSentTime = 0;

  @override
  void initState() {
    super.initState();
    _selectedPose = widget.exercise;
    _initWebSocket();
    _initCamera();
  }

  @override
  void dispose() {
    _isStreaming = false;
    _cameraController?.dispose();
    _channel.sink.close();
    super.dispose();
  }

  // ---------------- WebSocket ----------------
  void _initWebSocket() {
    final uri = Uri.parse('ws://$serverIp:$serverPort/ws/pose');
    _channel = WebSocketChannel.connect(uri);

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (!mounted) return;

      setState(() {
        _confidence = (data["confidence"] ?? 0).toDouble();
        _reps = (data["reps"] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), (v as num).toInt()),
            ) ??
            {};
        final holdsData = data["holds"] as Map?;
        if (holdsData != null) {
          _holds = holdsData.map((k, v) {
            final m = v as Map;
            return MapEntry(
              k.toString(),
              {
                "current": (m["current_hold"] ?? 0).toDouble(),
                "best": (m["best_hold"] ?? 0).toDouble(),
              },
            );
          });
        }
      });
    });

    // ส่งค่า exercise ที่เลือกไป backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _channel.sink.add(jsonEncode({"select_pose": widget.exercise}));
    });
  }

  // ---------------- Camera ----------------
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium, 
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
      _startImageStream();
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  void _startImageStream() {
    _isStreaming = true;
    _cameraController?.startImageStream((CameraImage image) async {
      if (!_isStreaming) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastSentTime < 350) return; // ส่งทุก ~0.35s (~3 fps)
      _lastSentTime = now;

      try {
        if (_channel.closeCode != null) return;

        Future.microtask(() async {
          final jpgBytes = await _convertCameraImageToJpg(image);
          final base64Image = base64Encode(jpgBytes);
          _channel.sink.add(base64Image);
        });
      } catch (e) {
        debugPrint("Image conversion/send error: $e");
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

    // 🔥 Resize ให้เล็กลงก่อนส่ง (ประหยัด bandwidth + CPU)
    final resized = img.copyResize(imgImage, width: 224, height: 224);

    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    final bool isTimeBased = widget.exercise.toLowerCase().contains("plank");

    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.exercise,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: (_cameraController != null &&
              _cameraController!.value.isInitialized)
          ? Column(
              children: [
                // กล้องเต็มพอดี ต่อจาก Header
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _cameraController!.value.previewSize!.height,
                            height:
                                _cameraController!.value.previewSize!.width,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      ),
                      _buildOverlay(),
                    ],
                  ),
                ),

                // StatsCard
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF181717),
                    border: Border(
                      top: BorderSide(color: Colors.white24, width: 1),
                    ),
                  ),
                  child: _buildStatsContent(isTimeBased),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // ---------------- Overlay ----------------
  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black54,
              Colors.transparent,
              Colors.black38,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4, 1],
          ),
        ),
      ),
    );
  }

  // ---------------- Stats ----------------
  Widget _buildStatsContent(bool isTimeBased) {
    final String poseKey = _selectedPose ?? widget.exercise;
    final int reps = _reps[poseKey] ?? 0;
    final double currentHold = _holds[poseKey]?["current"] ?? 0.0;
    final double bestHold = _holds[poseKey]?["best"] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatRow(
          Icons.trending_up,
          "Confidence",
          "${(_confidence * 100).toStringAsFixed(1)}%",
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: _confidence,
          backgroundColor: Colors.white24,
          color: Colors.greenAccent,
          minHeight: 8,
        ),
        const SizedBox(height: 20),
        if (isTimeBased) ...[
          _buildStatRow(
            Icons.timer,
            "Current Hold",
            "${currentHold.toStringAsFixed(1)}s",
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            Icons.emoji_events,
            "Best Hold",
            "${bestHold.toStringAsFixed(1)}s",
          ),
        ] else ...[
          _buildStatRow(
            Icons.repeat,
            "Reps",
            "$reps",
          ),
        ],
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
