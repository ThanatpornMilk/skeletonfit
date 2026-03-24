import 'package:flutter/material.dart';

/// กล่องป้อนข้อความธีมเดียวกับ MuscleFilterDialog
/// - หัวข้อพื้นเข้ม 0xFF2A2A2A
/// - ตัวกล่อง 0xFF1E1E1E + เงานุ่ม
/// - ปุ่มยกเลิก: Outlined สีแดง
/// - ปุ่มบันทึก: Elevated สีเขียว
class InputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String initialText;
  final String confirmText;
  final String cancelText;
  final Color confirmColor; // เขียว
  final Color cancelColor;  // แดง

  const InputDialog({
    super.key,
    required this.title,
    this.hintText = '',
    this.initialText = '',
    this.confirmText = 'บันทึก',
    this.cancelText = 'ยกเลิก',
    this.confirmColor = const Color(0xFF2E9265),
    this.cancelColor = const Color(0xFFE53935),
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String hintText = '',
    String initialText = '',
    String confirmText = 'บันทึก',
    String cancelText = 'ยกเลิก',
    Color confirmColor = const Color(0xFF2E9265),
    Color cancelColor = const Color(0xFFE53935),
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => InputDialog(
        title: title,
        hintText: hintText,
        initialText: initialText,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
      ),
    );
  }

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  static const Color _panelDark = Color(0xFF1E1E1E);
  static const Color _headerDark = Color(0xFF2A2A2A);
  static const double _radius = 20;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: BoxConstraints(
          // สูงพอดี ไม่ล้นจอ
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: _panelDark,
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.30),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _headerDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ชื่อหัวข้อ 
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          // ปุ่มปิดมุมขวา
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
                  icon: const Icon(Icons.close, size: 22, color: Colors.white70),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(0x33), width: 1),
        ),
        child: TextField(
          controller: _controller,
          style: const TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 16,
          ),
          cursorColor: widget.confirmColor,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
            filled: true,
            fillColor: const Color(0xFF1F1F1F),
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(0x33), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.confirmColor, width: 1.2),
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: _headerDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_radius),
          bottomRight: Radius.circular(_radius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, null),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.cancelColor,
                side: BorderSide(color: widget.cancelColor, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                widget.cancelText,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.confirmColor,
                foregroundColor: const Color(0xFF1E1E1E),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                widget.confirmText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
