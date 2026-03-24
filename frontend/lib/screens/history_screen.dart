import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/navbar.dart';
import '../widgets/radial_background.dart';

enum HistoryView { sessions, exercises }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  bool _refreshing = false;

  // โหมดที่เลือก
  HistoryView _view = HistoryView.sessions;

  // ข้อมูล
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _exerciseHistory = [];

  // --- ช่วงเวลา ---
  // ใช้ _rangeDays (แก้ไขได้) + สร้าง getter _range เพื่อแก้ warning prefer_final_fields
  int _rangeDays = 7;
  Duration get _range => Duration(days: _rangeDays);
  DateTime get _to => DateTime.now();
  DateTime get _from => _to.subtract(_range);

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final userId = context.read<UserProvider>().userId;
      if (userId == null) {
        setState(() {
          _sessions = [];
          _exerciseHistory = [];
          _loading = false;
        });
        return;
      }

      final sessionsF = ApiService.fetchWorkoutSessions(
        userId: userId,
        from: _from,
        to: _to,
      );

      final historyF = ApiService.fetchExerciseHistory(
        userId: userId,
        from: _from,
        to: _to,
      );

      final results = await Future.wait([sessionsF, historyF]);
      setState(() {
        _sessions = results[0];
        _exerciseHistory = results[1];
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading history/sessions: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await _loadAll();
    if (mounted) setState(() => _refreshing = false);
  }

  // ให้เลือกช่วงเวลา 7/30/90 วัน
  Future<void> _pickRange() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        Widget item(String label, int days) => ListTile(
              title: Text(label, style: const TextStyle(color: Colors.white)),
              trailing: _rangeDays == days
                  ? const Icon(Icons.check, color: Color(0xFF2E9265))
                  : null,
              onTap: () => Navigator.pop(context, days),
            );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 4, width: 40,
                decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 12),
              const Text('เลือกช่วงเวลา',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              item('7 วันล่าสุด', 7),
              item('30 วันล่าสุด', 30),
              item('90 วันล่าสุด', 90),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _rangeDays) {
      setState(() => _rangeDays = selected);
      await _loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text('Exercise History', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Container(color: Colors.white24, height: 1),
              const SizedBox(height: 8),
              _viewToggle(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 1),
      body: RadialBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E9265)))
            : RefreshIndicator(
                onRefresh: _refresh,
                color: const Color(0xFF2E9265),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _dateRangeHeader(),
                    const SizedBox(height: 16),
                    if (_view == HistoryView.sessions)
                      _buildSessionsList()
                    else
                      _buildExerciseHistoryList(),
                    if (_refreshing) ...[
                      const SizedBox(height: 12),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _dateRangeHeader() {
    final f = DateFormat('dd MMM');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${f.format(_from)} - ${f.format(_to)}',
            style: const TextStyle(color: Colors.white70)),
        InkWell(
          onTap: _pickRange,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF1F1F1F),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              _rangeDays == 7 ? '7 วัน' : _rangeDays == 30 ? '30 วัน' : '$_rangeDays วัน',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- View Toggle ----------
  Widget _viewToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pill(
          label: 'Workouts',
          selected: _view == HistoryView.sessions,
          onTap: () => setState(() => _view = HistoryView.sessions),
        ),
        const SizedBox(width: 8),
        _pill(
          label: 'Exercises',
          selected: _view == HistoryView.exercises,
          onTap: () => setState(() => _view = HistoryView.exercises),
        ),
      ],
    );
  }

  Widget _pill({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E9265) : const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ---------- Sessions List ----------
  Widget _buildSessionsList() {
    if (_sessions.isEmpty) {
      return _emptyState(text: 'ยังไม่มีประวัติการออกกำลังกายชุดออกกำลังกายในช่วงเวลานี้');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = _sessions[index];

        final sid = s['session_id'] ?? s['workout_session_id'];
        final name = (s['custom_workout_name'] ?? 'Workout Session #$sid').toString();

        final startedAt = _tryParseDate(s['started_at']);
        final completedAt = _tryParseDate(s['completed_at']);

        final sets = _toIntOrNull(s['total_sets']);
        final reps = _toIntOrNull(s['total_reps']);
        final duration = _toIntOrNull(s['total_duration']);

        final List<dynamic> exs = (s['exercises'] is List) ? (s['exercises'] as List) : const [];

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10, runSpacing: 6,
                children: [
                  if (sets != null) _chip('Sets', '$sets'),
                  if (reps != null) _chip('Reps', '$reps'),
                  if (duration != null) _chip('Duration', '${duration}s'),
                ],
              ),
              const SizedBox(height: 8),
              Text(_buildTimeText(startedAt, completedAt), style: const TextStyle(color: Colors.white54, fontSize: 14)),
              if (exs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: exs.map((e) {
                      final ename = (e['name'] ?? 'Exercise').toString();
                      final esets = _toIntOrNull(e['sets_done']);
                      final ereps = _toIntOrNull(e['reps_done']);
                      final edur  = _toIntOrNull(e['duration_done']);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.white70)),
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8, runSpacing: 4,
                                children: [
                                  Text(ename, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                  if (esets != null) _miniChip('S:$esets'),
                                  if (ereps != null) _miniChip('R:$ereps'),
                                  if (edur != null) _miniChip('D:${edur}s'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ---------- Flat Exercise History ----------
  Widget _buildExerciseHistoryList() {
    if (_exerciseHistory.isEmpty) {
      return _emptyState(text: 'ยังไม่มีประวัติการออกกำลังกายในช่วงเวลานี้');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _exerciseHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _exerciseHistory[index];

        final DateTime? completedAt = _tryParseDate(item['completed_at']);
        final String exerciseName =
            (item['name'] ?? item['exercise_name'] ?? item['name_en'] ?? 'Unnamed Exercise').toString();

        final int? sets = _toIntOrNull(item['sets_done']);
        final int? reps = _toIntOrNull(item['reps_done']);
        final int? duration = _toIntOrNull(item['duration_done']);

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E9265).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fitness_center, color: Color(0xFF2E9265), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exerciseName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10, runSpacing: 6,
                      children: [
                        if (sets != null) _chip('Sets', '$sets'),
                        if (reps != null) _chip('Reps', '$reps'),
                        if (duration != null) _chip('Duration', '${duration}s'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completedAt != null
                          ? 'ทำเมื่อ: ${DateFormat('dd/MM/yyyy HH:mm').format(completedAt)}'
                          : 'ทำเมื่อ: -',
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- Helpers ----------
  int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    return null;
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _miniChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _emptyState({String text = 'No data'}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.history, size: 64, color: Colors.white24),
        SizedBox(height: 12),
        Text('ยังไม่มีประวัติการออกกำลังกายในช่วงเวลานี้', style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  String _buildTimeText(DateTime? start, DateTime? end) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    if (start != null && end != null) {
      return 'เริ่ม: ${df.format(start)} • เสร็จ: ${df.format(end)}';
    } else if (start != null) {
      return 'เริ่ม: ${df.format(start)}';
    } else if (end != null) {
      return 'เสร็จ: ${df.format(end)}';
    } else {
      return 'เวลา: -';
    }
  }
}
