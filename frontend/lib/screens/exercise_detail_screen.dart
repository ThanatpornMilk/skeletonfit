// lib/screens/exercise_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';
import '../data/exercises.dart';
import '../widgets/button.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'camera_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseInfo exercise;
  /// ระบุว่าเข้ามาจาก Custom Workout หรือไม่
  final bool isCustomWorkout;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.isCustomWorkout = false,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final Color green = const Color(0xFF2E9265);
  final TextEditingController _setsController = TextEditingController(text: '');
  final TextEditingController _valueController = TextEditingController(text: '');

  bool _isLoading = true;

  // ---------- Video (Drive/WebView) ----------
  WebViewController? _wvController;
  bool _webViewFailed = false;

  @override
  void initState() {
    super.initState();

    // ค่าเริ่มต้น
    _setsController.text = widget.exercise.sets;
    if (_isTimeBased(widget.exercise.name)) {
      _valueController.text = widget.exercise.duration;
    } else {
      _valueController.text = widget.exercise.reps;
    }

    // เตรียม WebView ถ้าเป็นลิงก์ Google Drive
    final normalized = _normalizeDriveUrl(widget.exercise.videoUrl);
    if (_isGoogleDrive(normalized)) {
      _initDriveWebView(normalized);
    }

    _loadUserExercise();
  }

  @override
  void dispose() {
    _setsController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  bool _isTimeBased(String name) => name.toLowerCase().contains("plank");

  // ---------- Google Drive helpers ----------

  bool _isGoogleDrive(String url) =>
      url.contains('drive.google.com') || url.contains('googleusercontent.com');

  /// แปลงเป็น preview URL + บังคับ rm=minimal เพื่อตัด toolbar ของ Drive
  String _normalizeDriveUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;

    String addMinimal(String url) =>
        url.contains('?') ? '$url&rm=minimal' : '$url?rm=minimal';

    // ดึง id จากหลายรูปแบบ
    final idFromFile = RegExp(r'/file/d/([A-Za-z0-9_\-]+)').firstMatch(s)?.group(1);
    final idFromOpen = RegExp(r'[?&]id=([A-Za-z0-9_\-]+)').firstMatch(s)?.group(1);
    final idFromUc   = RegExp(r'[?&]id=([A-Za-z0-9_\-]+)').firstMatch(s)?.group(1);
    final id = idFromFile ?? idFromOpen ?? idFromUc;

    if (id != null && id.isNotEmpty) {
      return addMinimal('https://drive.google.com/file/d/$id/preview');
      // หรือ: return addMinimal('https://drive.google.com/uc?export=preview&id=$id');
    }

    if (s.contains('/preview') ||
        (s.contains('uc?export=preview') && s.contains('id='))) {
      return addMinimal(s);
    }
    return s;
  }

  /// ตั้งค่า WebView ให้เล่นวิดีโอ Drive ได้ + ซ่อน toolbar ด้วย JS
  Future<void> _initDriveWebView(String previewUrl) async {
  // ใช้ params มาตรฐานจากแพ็กเกจหลัก ไม่พึ่งคลาสของ Android/iOS
  const params = PlatformWebViewControllerCreationParams();

  // สร้าง controller จาก params
  final c = WebViewController.fromPlatformCreationParams(params);

  // ตั้งค่าทั่วไป
  c
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.black)
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (req) {
          final u = req.url;
          // บล็อกลิงก์ดาวน์โหลดที่หลุดจากหน้า preview
          if (u.contains('export=download') && !u.contains('/preview')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (_) {
          if (mounted) setState(() => _webViewFailed = true);
        },
        onPageFinished: (url) async {
          // ซ่อน toolbar/ปุ่ม "Open in new window"
          const js = r'''
            (function(){
              try {
                var tb = document.querySelector('[role="toolbar"]');
                if (tb) tb.style.display = 'none';
                var btn = document.querySelector('[aria-label="Open in new window"]');
                if (btn && btn.parentElement) btn.parentElement.style.display = 'none';
                document.body.style.margin = '0';
                document.documentElement.style.margin = '0';
                document.body.style.backgroundColor = 'black';
              } catch(e) {}
            })();
          ''';
          try { await c.runJavaScript(js); } catch (_) {}
        },
      ),
    );

  // โหลดหน้า preview
  await c.loadRequest(Uri.parse(previewUrl));

  if (mounted) {
    setState(() {
      _wvController = c;
      _webViewFailed = false;
    });
  }
}


  Future<void> _loadUserExercise() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) return;

      final data = await ApiService.fetchUserExercise(userId, widget.exercise.id);
      if (data != null && mounted) {
        final isTimeBased = _isTimeBased(widget.exercise.name);
        setState(() {
          if (data['sets'] != null) _setsController.text = data['sets'].toString();
          if (isTimeBased && data['duration'] != null) {
            _valueController.text = data['duration'].toString();
          } else if (!isTimeBased && data['reps'] != null) {
            _valueController.text = data['reps'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint("Failed to load user exercise: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserExercise() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) return;
      final isTimeBased = _isTimeBased(widget.exercise.name);
      await ApiService.saveUserExercise(
        userId: userId,
        exerciseId: widget.exercise.id,
        sets: _setsController.text,
        reps: isTimeBased ? null : _valueController.text,
        duration: isTimeBased ? _valueController.text : null,
      );
    } catch (e) {
      debugPrint("Error saving user exercise: $e");
    }
  }

  int _parseIntSafe(String? v, {required int fallback}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return fallback;
    return int.tryParse(s) ?? fallback;
  }

  Future<void> _openExternalVideo() async {
    // เปิดด้วยลิงก์ที่ normalize แล้วเสมอ
    final url = _normalizeDriveUrl(widget.exercise.videoUrl).trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) debugPrint('Could not launch $url');
    } catch (e) {
      debugPrint('Launch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final bool isTimeBased = _isTimeBased(ex.name);
    final String normalizedUrl = _normalizeDriveUrl(ex.videoUrl);
    final bool isDrive = _isGoogleDrive(normalizedUrl);
    final bool hasVideo = normalizedUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(ex.name, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: ColoredBox(color: Colors.white24, child: SizedBox(height: 1)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E9265)))
          : Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: widget.isCustomWorkout ? 0 : 100),
                  child: ListView(
                    children: [
                      // แสดง player ถ้าเป็น Drive และโหลด WebView ได้
                      if (isDrive && _wvController != null && !_webViewFailed)
                        _buildDrivePlayer()
                      else
                        _buildHeaderWithOptionalButton(ex, hasVideo),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildExerciseInfo(ex, isTimeBased),
                            if (ex.muscles.isNotEmpty) _buildMuscleTags(ex),
                            const SizedBox(height: 24),
                            if (ex.steps.isNotEmpty) _buildSection("คำแนะนำ", ex.steps),
                            if (ex.tips.isNotEmpty) _buildTips(ex),
                            _buildBenefits(ex),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (!widget.isCustomWorkout)
                  Positioned(
                    bottom: 20, left: 20, right: 20,
                    child: Button(
                      buttonText: "เริ่มออกกำลังกาย",
                      isEnabled: true,
                      onPressed: () async {
                        final int targetSets =
                            _parseIntSafe(_setsController.text, fallback: 1);

                        final int targetRepsOrSecs = _parseIntSafe(
                          _valueController.text,
                          fallback: isTimeBased ? 30 : 10,
                        );

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraScreen(
                              exerciseId: widget.exercise.id,
                              exercise: widget.exercise.name,
                              reps: targetRepsOrSecs,
                              sets: targetSets,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  // ---------- UI helpers ----------

  Widget _buildDrivePlayer() {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          // ห้าม const เพราะเป็น stateful child
          child: WebViewWidget(controller: _wvController!),
        ),
      ),
    );
  }

  // เฮดเดอร์รูปภาพ + ปุ่มเปิดวิดีโอ (กรณีโหลด player ไม่ได้)
  Widget _buildHeaderWithOptionalButton(ExerciseInfo exercise, bool hasVideo) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            image: exercise.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(exercise.imageUrl),
                    fit: BoxFit.cover,
                    onError: (_, __) {}, // ป้องกัน error รูปพัง
                  )
                : null,
            gradient: exercise.imageUrl.isEmpty
                ? const LinearGradient(
                    colors: [
                      Color.fromRGBO(128, 0, 128, 0.3),
                      Color.fromRGBO(33, 150, 243, 0.5),
                      Color.fromRGBO(0, 188, 212, 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: exercise.imageUrl.isEmpty
              ? const Center(
                  child: Icon(Icons.fitness_center,
                      color: Colors.white70, size: 64),
                )
              : null,
        ),
        if (hasVideo)
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton.icon(
              onPressed: _openExternalVideo,
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('ดูวิดีโอ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9265),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseInfo(ExerciseInfo exercise, bool isTimeBased) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(18, 18, 18, 0.8),
            Color.fromRGBO(33, 33, 33, 0.6)
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(97, 97, 97, 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEditableStatCard("เซต", _setsController, Icons.repeat, green),
          Container(height: 30, width: 1, color: Colors.grey),
          if (isTimeBased)
            _buildEditableStatCard(
                "เวลา (วินาที)", _valueController, Icons.timer, green)
          else
            _buildEditableStatCard(
                "ครั้ง", _valueController, Icons.fitness_center, green),
        ],
      ),
    );
  }

  Widget _buildEditableStatCard(
    String label,
    TextEditingController controller,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconButton(Icons.remove, () {
              setState(() {
                int value = int.tryParse(controller.text) ?? 1;
                if (value > 1) value--;
                controller.text = value.toString();
              });
              _saveUserExercise();
            }),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                controller.text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            _iconButton(Icons.add, () {
              setState(() {
                int value = int.tryParse(controller.text) ?? 1;
                value++;
                controller.text = value.toString();
              });
              _saveUserExercise();
            }),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildMuscleTags(ExerciseInfo exercise) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: exercise.muscles.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                exercise.muscles[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((e) {
          final i = e.key;
          final text = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(18, 18, 18, 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromRGBO(97, 97, 97, 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTips(ExerciseInfo exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildSectionTitle("เคล็ดลับ"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(18, 18, 18, 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromRGBO(97, 97, 97, 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...exercise.tips.split('\n').map((line) {
                final s = line.trim();
                if (s.isEmpty) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(color: Colors.white, fontSize: 18)),
                      Expanded(
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBenefits(ExerciseInfo exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("ประโยชน์"),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(18, 18, 18, 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromRGBO(97, 97, 97, 0.3),
              width: 1,
            ),
          ),
          child: Text(
            exercise.benefits,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
}
