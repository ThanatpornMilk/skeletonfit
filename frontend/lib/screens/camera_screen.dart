// lib/screens/camera_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../providers/user_provider.dart';

class CameraScreen extends StatefulWidget {
  final int exerciseId;      // ส่งมาจากหน้าก่อน
  final String exercise;     // ชื่อท่า
  final int reps;            // เป้าหมาย (ครั้ง) หรือ วินาที (ถ้าเป็น plank/side plank)
  final int sets;            // เป้าหมายเซ็ต

  const CameraScreen({
    super.key,
    required this.exerciseId,
    required this.exercise,
    required this.reps,
    required this.sets,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late final WebSocketChannel _channel;

  bool _isStreaming = false;
  bool _poseSent = false;

  String? _selectedPose;
  double _confidence = 0.0;

  // ข้อมูลจากเซิร์ฟเวอร์
  final Map<String, int> _serverReps = {};                 // reps สะสมต่อท่า
  final Map<String, Map<String, double>> _holds = {};      // {pose: {current, best}}

  String _advice = "";
  int _lastSentTime = 0;

  bool _isPoseCorrect = false;
  bool _prevPoseCorrect = false;
  double _adviceOpacity = 1.0;

  // เซิร์ฟเวอร์ (ปรับให้ตรงกับของคุณ)
  final String serverIp = "10.0.2.2"; // Emulator
  final int serverPort = 8000;

  // ====== ตัวช่วยแสดงเวลาลื่นไหล (Plank/Side Plank) ======
  Timer? _uiTicker;
  double _displayHold = 0.0;       // เวลาโชว์จริง (ไหลต่อ)
  double _serverHoldCurrent = 0.0; // current_hold ล่าสุด
  int _serverHoldTsMs = 0;         // เวลา ms ตอนรับ current_hold ล่าสุด
  // ========================================================

  // ====== Progress ปัจจุบันสำหรับแถบบน ======
  int _currentRep = 0;     // ถ้าเป็นท่าเวลา = วินาทีในเซ็ต
  int _currentSet = 0;
  bool _workoutDone = false;
  // ==========================================

  @override
  void initState() {
    super.initState();
    _selectedPose = widget.exercise;
    _initWebSocket();
    _initCamera();

    // อัปเดตเวลาแบบลื่นไหลสำหรับ Plank/Side Plank
    _uiTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      if (!_isTimeBased(widget.exercise)) return;

      final bool canAccumulate =
          _isPoseCorrect && _confidence > 0.55 && _selectedPose != null;

      double base = _serverHoldCurrent;
      if (canAccumulate && _serverHoldTsMs > 0) {
        final int now = DateTime.now().millisecondsSinceEpoch;
        final double delta = (now - _serverHoldTsMs) / 1000.0;
        base += (delta > 0 ? delta : 0.0);
      }

      final double rounded = double.parse(base.toStringAsFixed(2));
      if ((rounded - _displayHold).abs() >= 0.01) {
        _displayHold = rounded;
        _recalcProgress(); // คิด Rep/Set ใหม่จากเวลา
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _isStreaming = false;
    _cameraController?.dispose();
    _channel.sink.close();
    _uiTicker?.cancel();
    super.dispose();
  }

  bool _isTimeBased(String poseName) {
    // รองรับ Plank และ Side Plank
    final lower = poseName.toLowerCase();
    return lower.contains("plank");
  }

  void _initWebSocket() {
    final uri = Uri.parse('ws://$serverIp:$serverPort/ws/pose');
    _channel = WebSocketChannel.connect(uri);

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (!mounted) return;

      _confidence = (data["confidence"] ?? 0).toDouble();

      // reps สะสมต่อท่า
      final Map<String, int> newReps =
          (data["reps"] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {};
      _serverReps
        ..clear()
        ..addAll(newReps);

      // holds: สำหรับ Plank / Side Plank เท่านั้น (backend ส่งมาเฉพาะท่าที่เลือก)
      final holdsData = data["holds"] as Map?;
      if (holdsData != null) {
        _holds.clear();
        holdsData.forEach((pose, value) {
          final m = value as Map;
          final double cur = (m["current_hold"] ?? 0).toDouble();
          final double best = (m["best_hold"] ?? 0).toDouble();
          _holds[pose] = {"current": cur, "best": best};

          // บันทึกเวลา server เพื่อทำให้ UI ไหลต่อเอง
          if (_selectedPose != null && pose.toString() == _selectedPose) {
            _serverHoldCurrent = cur;
            _serverHoldTsMs = DateTime.now().millisecondsSinceEpoch;
            _displayHold = cur; // sync ทันที
          }
        });
      }

      _advice = (data["advice"] ?? "").toString();

      // ประเมิน form
      final bool isTimeBased = _isTimeBased(widget.exercise);
      bool correct;
      if (isTimeBased) {
        final currentHold = _holds[_selectedPose]?["current"] ?? 0.0;
        correct = _confidence > 0.55 && currentHold >= 0.0;
      } else {
        final counted = _serverReps[_selectedPose] ?? 0;
        correct = _confidence > 0.50 && counted >= 0;
      }

      if (correct != _prevPoseCorrect) {
        _prevPoseCorrect = correct;
        _isPoseCorrect = correct;
        _adviceOpacity = 0.0;
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          setState(() {
            _adviceOpacity = 1.0;
          });
        });
      }

      // ส่ง select_pose ครั้งแรก
      if (!_poseSent && _selectedPose != null) {
        _channel.sink.add(jsonEncode({"select_pose": _selectedPose}));
        _poseSent = true;
      }

      _recalcProgress();
      if (mounted) setState(() {});
    }, onError: (error) {
      debugPrint("WebSocket error: $error");
    }, onDone: () {
      debugPrint("WebSocket closed");
    });
  }

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
      if (now - _lastSentTime < 200) return; // ~5 FPS
      _lastSentTime = now;

      try {
        if (_channel.closeCode != null) return;

        final jpgBytes = await _convertCameraImageToJpg(image);
        final base64Image = base64Encode(jpgBytes);
        _channel.sink.add(base64Image);
      } catch (e) {
        debugPrint("Image conversion error: $e");
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

  /// แปลง “ยอดสะสม” → Rep/Set ปัจจุบัน
  /// - ท่าเวลา: วินาทีสะสม (_displayHold.floor())
  /// - ท่าจำนวนครั้ง: reps สะสมจาก backend
  void _recalcProgress() {
    if (_selectedPose == null) return;

    final bool isTimeBased = _isTimeBased(widget.exercise);
    int totalUnits; // วินาทีสะสม หรือ ครั้งสะสม

    if (isTimeBased) {
      totalUnits = _displayHold.floor();
    } else {
      totalUnits = _serverReps[_selectedPose] ?? 0;
    }

    int currentSet = 0;
    int currentRep = 0;
    bool done = false;

    if (widget.reps > 0) {
      currentSet = totalUnits ~/ widget.reps;
      currentRep = totalUnits % widget.reps;
    }

    if (currentSet >= widget.sets) {
      currentSet = widget.sets;
      currentRep = 0;
      done = true;
    }

    _currentSet = currentSet;
    _currentRep = currentRep;
    _workoutDone = done;

    if (done) _showCompleteOnce();
  }

  bool _shownDialog = false;
  void _showCompleteOnce() {
    if (_shownDialog) return;
    _shownDialog = true;
    showDialog(
      context: context,
      builder: (ctx) => const AlertDialog(
        title: Text('🎉 Workout Complete!'),
        content: Text('Great job!'),
      ),
    );
  }

  /// ใช้สำหรับบันทึกผล (ท่าเวลาเก็บเป็น duration = best hold)
  Map<String, String?> _buildResultPayload() {
    final isTimeBased = _isTimeBased(widget.exercise);

    final int measuredReps = _serverReps[_selectedPose] ?? 0;
    final int measuredSecs = ((_holds[_selectedPose]?["best"] ?? 0).round());

    return {
      "sets": _currentSet.toString(),
      "reps": isTimeBased ? null : measuredReps.toString(),
      "duration": isTimeBased ? measuredSecs.toString() : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.exercise, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: (_cameraController != null && _cameraController!.value.isInitialized)
          ? Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cameraController!.value.previewSize!.height,
                                height: _cameraController!.value.previewSize!.width,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),
                          _buildOverlay(),

                          // ===== แถบ Rep/Set (รองรับ Plank/Side Plank) =====
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _pillStat(
                                  label: 'Rep',
                                  // ท่าเวลา: Rep = วินาทีในเซ็ต (นับ 0..เป้า-1)
                                  value: _isTimeBased(widget.exercise)
                                      ? '${_workoutDone ? 0 : _currentRep}/${widget.reps}s'
                                      : '${_workoutDone ? 0 : _currentRep}/${widget.reps}',
                                  good: !_workoutDone,
                                ),
                                const SizedBox(width: 12),
                                _pillStat(
                                  label: 'Set',
                                  value: '$_currentSet/${widget.sets}', // ← เอา {} ออก (var เดี่ยว)
                                  good: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      decoration: const BoxDecoration(
                        color: Color(0xFF181717),
                        border: Border(
                          top: BorderSide(color: Colors.white24, width: 1),
                        ),
                      ),
                      child: _buildStatsContent(),
                    ),
                  ],
                ),

                if (_advice.isNotEmpty)
                  Positioned(
                    top: 72, // ไม่ให้ทับแถบ Rep/Set
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _adviceOpacity,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (_isPoseCorrect
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFF44336))
                              .withValues(alpha: 0.9), // ← ใช้ withValues
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Text(
                          _advice,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.black87,
            boxShadow: [
              BoxShadow(color: Color.fromARGB(66, 0, 115, 61), blurRadius: 12, offset: Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleStream,
                  icon: Icon(_isStreaming ? Icons.pause_circle : Icons.play_circle),
                  label: Text(_isStreaming ? 'หยุด' : 'เริ่ม'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveExerciseHistory(popAfter: true),
                  icon: const Icon(Icons.check),
                  label: const Text('จบเซต & บันทึก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleStream() async {
    if (_cameraController == null) return;
    if (_isStreaming) {
      try {
        _isStreaming = false;
        await _cameraController!.stopImageStream();
        if (mounted) setState(() {});
      } catch (_) {}
    } else {
      _startImageStream();
      if (mounted) setState(() {});
    }
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.transparent, Colors.black38],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4, 1],
          ),
        ),
      ),
    );
  }

  String _formatSeconds(double seconds) {
    final int s = seconds.floor();
    final int mm = (s ~/ 60);
    final int ss = (s % 60);
    final String ms = (seconds - s).toStringAsFixed(2).substring(2); // .ff
    return '${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}.$ms';
  }

  Widget _buildStatsContent() {
    final int targetRepsOrSecs = widget.reps;
    final int targetSets = widget.sets;

    final int totalReps = _serverReps[_selectedPose] ?? 0;
    final double bestHold = _holds[_selectedPose]?["best"] ?? 0.0;
    final bool isTimeBased = _isTimeBased(widget.exercise);

    // แสดงค่าแบบอ่านง่ายด้านล่างกล้อง
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatRow(Icons.trending_up, 'Confidence', '${(_confidence * 100).toStringAsFixed(1)}%'),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: _confidence.clamp(0.0, 1.0),
          backgroundColor: Colors.white24,
          color: Colors.greenAccent,
          minHeight: 8,
        ),
        const SizedBox(height: 20),

        _buildStatRow(Icons.flag, 'Target per set',
            isTimeBased ? '$targetRepsOrSecs s' : '$targetRepsOrSecs reps'),

        const SizedBox(height: 8),

        if (isTimeBased) ...[
          _buildStatRow(Icons.timer, 'Live (this set)',
              _formatSeconds(_displayHold % widget.reps.toDouble())),
          const SizedBox(height: 8),
          _buildStatRow(Icons.emoji_events, 'Best Hold', _formatSeconds(bestHold)),
        ] else ...[
          _buildStatRow(Icons.functions, 'Total counted (server)', '$totalReps reps'),
        ],

        const SizedBox(height: 10),
        _buildStatRow(Icons.layers, 'Sets Done', '$_currentSet / $targetSets'),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _pillStat({required String label, required String value, bool good = true}) {
    final bg = good ? Colors.white.withValues(alpha: 0.92) : Colors.white24; // ← withValues
    final fg = good ? Colors.black87 : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: good
            ? const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))]
            : null,
      ),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(
                color: fg.withValues(alpha: 0.8), // ← withValues แทน withOpacity
                fontWeight: FontWeight.w600,
              )),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// บันทึกผล
  Future<void> _saveExerciseHistory({bool popAfter = false}) async {
    try {
      final userId = context.read<UserProvider>().userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ยังไม่ได้ล็อกอิน (userId = null)')),
        );
        return;
      }

      final payload = _buildResultPayload();

      await ApiService.saveUserExercise(
        userId: userId,
        exerciseId: widget.exerciseId,
        sets: payload['sets'] ?? '0',
        reps: payload['reps'],
        duration: payload['duration'],
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกผลสำเร็จ')),
      );
      if (popAfter) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving exercise history: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกล้มเหลว')),
      );
    }
  }
}
