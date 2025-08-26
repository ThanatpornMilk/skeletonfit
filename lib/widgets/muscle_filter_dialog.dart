import 'package:flutter/material.dart';

class MuscleFilterDialog {
  static Future<Set<String>?> show(
    BuildContext context, {
    required List<String> allMuscles,
    required Set<String> initialSelected,
  }) {
    final sorted = [...allMuscles]..sort();
    final initial = Set<String>.from(initialSelected);

    return showDialog<Set<String>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _MuscleFilterContent(allMuscles: sorted, initialSelected: initial),
      ),
    );
  }
}

class _MuscleFilterContent extends StatefulWidget {
  final List<String> allMuscles;
  final Set<String> initialSelected;

  const _MuscleFilterContent({
    required this.allMuscles,
    required this.initialSelected,
  });

  @override
  State<_MuscleFilterContent> createState() => _MuscleFilterContentState();
}

class _MuscleFilterContentState extends State<_MuscleFilterContent> {
  // สีเขียวตามที่ขอ
  static const Color kGreen = Color(0xFF2E9265);

  late Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initialSelected);
  }

  List<String> get _filtered => widget.allMuscles
      .where((m) => m.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context),
          _scrollArea(),
          _actions(context),
        ],
      ),
    );
  }

  // ======= Parts =======

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'เลือกกล้ามเนื้อ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                  tooltip: 'ปิด',
                  icon: const Icon(Icons.close, size: 24, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scrollArea() {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _filtered.length + 1, // +1 ช่องค้นหา
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (_, i) => (i == 0) ? _searchField() : _muscleTile(_filtered[i - 1]),
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kGreen.withAlpha(0x4D), // ~30%
            width: 1,
          ),
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'ค้นหากล้ามเนื้อ...',
            hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
            prefixIcon: Icon(Icons.search, color: kGreen.withAlpha(0xB3)), // ~70%
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
    );
  }

  Widget _muscleTile(String name) {
    final sel = _selected.contains(name);
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      value: sel,
      selected: sel,
      selectedTileColor: kGreen.withAlpha(0x1A), // ~10%
      activeColor: kGreen,
      checkColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: sel ? kGreen.withAlpha(0x4D) : Colors.white.withAlpha(0x33), // 30% / 20%
          width: 1,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: sel ? kGreen : Colors.white,
          fontWeight: sel ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      onChanged: (v) => setState(() {
        if (v == true) {
          _selected.add(name);
        } else {
          _selected.remove(name);
        }
      }),
    );
  }

  Widget _actions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // ล้างทั้งหมด -> สีแดง
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(_selected.clear),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('ล้างทั้งหมด', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: const Color(0xFF1E1E1E),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
