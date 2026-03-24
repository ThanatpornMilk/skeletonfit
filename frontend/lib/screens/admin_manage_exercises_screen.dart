import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/radial_background.dart';
import '../../services/api_service.dart';
import '../../data/exercises.dart';
import '../../providers/user_provider.dart';

class AdminManageExercisesScreen extends StatefulWidget {
  const AdminManageExercisesScreen({super.key});

  @override
  State<AdminManageExercisesScreen> createState() =>
      _AdminManageExercisesScreenState();
}

class _AdminManageExercisesScreenState
    extends State<AdminManageExercisesScreen> {
  late Future<List<ExerciseInfo>> _exercisesFuture;

  final PageController _pageController = PageController();
  int _currentStep = 0; // 0=รายละเอียด, 1=กล้ามเนื้อ, 2=เป้าหมาย
  bool _isPaging = false; // กันกด/animate รัวๆ

  // Form controllers
  final _nameController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _stepsController = TextEditingController(); 
  final _tipsController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _durationController = TextEditingController();

  // step 1: steps 1–5 ช่อง
  final List<TextEditingController> _stepControllers =
      List.generate(5, (_) => TextEditingController());

  // Form keys
  final _step1FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // กล้ามเนื้อ
  static const int _maxMuscleSelect = 5;
  final Set<int> _selectedMuscleIds = {};

  // duration
  bool _useDuration = false;
  Duration _pickedDuration = const Duration(minutes: 2, seconds: 30);

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = ApiService.fetchExercises();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _benefitsController.dispose();
    _stepsController.dispose();
    _tipsController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    for (final c in _stepControllers) { c.dispose(); }
    super.dispose();
  }

  Future<void> _refreshExercises() async {
    setState(() => _exercisesFuture = ApiService.fetchExercises());
  }

  static const _muscles = <({int id, String th, String en})>[
  (id: 1,  th: 'หน้าท้อง',              en: 'Abdominals'),
  (id: 2,  th: 'ต้นแขนด้านหลัง',        en: 'Triceps'),
  (id: 3,  th: 'หน้าอก',                en: 'Pectorals'),
  (id: 4,  th: 'ก้น/สะโพก',             en: 'Glutes'),
  (id: 5,  th: 'หัวไหล่',               en: 'Deltoids'),
  (id: 6,  th: 'ต้นขาด้านหน้า',         en: 'Quadriceps'),
  (id: 7,  th: 'ต้นขาด้านหลัง',         en: 'Hamstrings'),
  (id: 8,  th: 'ด้านข้างลำตัว',         en: 'Obliques'),
  (id: 9,  th: 'หลังส่วนล่างถึงกลาง',   en: 'Erector Spinae'),
  (id: 10, th: 'น่อง',                  en: 'Calves'),
  (id: 11, th: 'หน้าท้องส่วนกลาง',      en: 'Rectus Abdominis'),
  (id: 12, th: 'สะโพกด้านหน้า',         en: 'Hip Flexors'),
  (id: 13, th: 'หน้าท้องส่วนล่าง',      en: 'Lower Abs'),
  (id: 14, th: 'หน้าท้องลึก',           en: 'Transverse Abdominis'),
  (id: 15, th: 'หลังส่วนล่าง',          en: 'Lower Back'),
];
  // ---------------------- UI HELPERS ----------------------

  InputDecoration _inputDecoration(String hint, {String? helperText}) {
    return InputDecoration(
      hintText: hint,
      helperText: helperText,
      helperStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E9265), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  String? helperText,
  int maxLines = 1,
  int? maxLength,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
  bool enabled = true,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLength,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    enabled: enabled, 
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: _inputDecoration(hint, helperText: helperText),
  );
}


  // ---------------------- NAV BETWEEN STEPS ----------------------

  Future<void> _goToStep(int step, StateSetter setDialogState) async {
    if (step < 0 || step > 2) return;
    _isPaging = true;
    setDialogState(() {}); // ปิดปุ่มชั่วคราวระหว่าง animate

    await _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _currentStep = step;
    _isPaging = false;
    setDialogState(() {});
  }

  // ---------------------- WIZARD DIALOG ----------------------

  void _openWizard() {
    _clearWizardData();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Add Exercise Wizard',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogCtx, anim1, anim2) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 560,
                    maxHeight: 700,
                  ),
                  child: _buildWizardBody(dialogCtx, setDialogState),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildWizardBody(
      BuildContext dialogCtx, StateSetter setDialogState) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2E9265), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E9265).withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWizardHeader(dialogCtx),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1Details(),
                          _buildStep2Muscles(setDialogState),
                          _buildStep3Targets(setDialogState),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.white24, thickness: 1),
            _buildWizardFooter(dialogCtx, setDialogState),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardHeader(BuildContext dialogCtx) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E9265), Color(0xFF25805A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_circle_outline,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สร้างคำขอเพิ่มท่าใหม่',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'ใบคำขอเพิ่มท่าออกกำลังกาย',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const titles = ['รายละเอียด', 'กล้ามเนื้อ', 'เป้าหมาย'];
    const icons = [Icons.description, Icons.fitness_center, Icons.flag];

    return Row(
      children: List.generate(3, (i) {
        final active = i == _currentStep;
        final completed = i < _currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      colors: [Color(0xFF2E9265), Color(0xFF25805A)],
                    )
                  : null,
              color: completed ? const Color(0xFF3A3A3A) : const Color(0xFF252525),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? Colors.transparent
                    : completed
                        ? const Color(0xFF2E9265).withValues(alpha: 0.3)
                        : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  completed ? Icons.check_circle : icons[i],
                  color: active
                      ? Colors.white
                      : completed
                          ? const Color(0xFF2E9265)
                          : Colors.white38,
                  size: 22,
                ),
                const SizedBox(height: 6),
                Text(
                  titles[i],
                  style: TextStyle(
                    color: active || completed ? Colors.white : Colors.white54,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------------- STEP 1: DETAILS ----------------------
  Widget _buildStep1Details() {
    return Form(
      key: _step1FormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายละเอียดของท่าออกกำลังกาย',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _nameController,
              hint: 'ชื่อท่าออกกำลังกาย',
              helperText: 'ภาษาอังกฤษเท่านั้น (Ex : Push-ups)',
              maxLength: 100,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'กรุณากรอกชื่อ';
                if (val.trim().length < 3) return 'ชื่อต้องยาวมากกว่า 3 ตัวอักษร';
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _benefitsController,
              hint: 'Benefits',
              helperText: 'อธิบายประโยชน์ของท่าออกกำลังกายนี้',
              maxLines: 4,
              maxLength: 500,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'กรุณากรอกข้อมูลให้ครบ';
                }
                if (val.trim().length < 10) {
                  return 'ต้องมีตัวอักษรอย่างน้อย 10 ตัวอักษร';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            const Text(
              'วิธีการออกกำลังกาย (1–5 ขั้นตอน)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ...List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _stepControllers[i],
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    'Step ${i + 1}',
                    helperText: i == 0
                        ? 'กรอกอย่างน้อย 1 ขั้นตอน (ปล่อยว่างได้สำหรับ Step ที่ไม่ใช้)'
                        : null,
                  ),
                ),
              );
            }),

            Builder(
              builder: (context) {
                final filled = _stepControllers
                    .map((c) => c.text.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    filled.isEmpty
                        ? 'ยังไม่ได้ระบุขั้นตอน'
                        : 'ระบุแล้ว ${filled.length} ขั้นตอน',
                    style: TextStyle(
                      color: filled.isEmpty ? Colors.redAccent : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
            _buildTextField(
              controller: _tipsController,
              hint: 'Tips',
              helperText: 'คำแนะนำเพิ่มเติม',
              maxLines: 3,
              maxLength: 300,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- STEP 2: MUSCLES ----------------------

  Widget _buildStep2Muscles(StateSetter setDialogState) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'กล้ามเนื้อที่ได้จากท่านี้',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedMuscleIds.isEmpty
                    ? Colors.redAccent.withValues(alpha: 0.2)
                    : const Color(0xFF2E9265).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedMuscleIds.isEmpty
                      ? Colors.redAccent
                      : const Color(0xFF2E9265),
                  width: 1.5,
                ),
              ),
              child: Text(
                '${_selectedMuscleIds.length}/$_maxMuscleSelect selected',
                style: TextStyle(
                  color: _selectedMuscleIds.isEmpty
                      ? Colors.redAccent
                      : const Color(0xFF2E9265),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'เลือก 1-5 กล้ามเนื้อ',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // ใช้ spread + map แล้วปิดด้วย .toList() เสมอ
        ..._muscles.map((m) {
          final checked = _selectedMuscleIds.contains(m.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: checked
                  ? const Color(0xFF2E9265).withValues(alpha: 0.15)
                  : const Color(0xFF252525),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: checked ? const Color(0xFF2E9265) : Colors.transparent,
                width: 2,
              ),
            ),
            child: CheckboxListTile(
              value: checked,
              activeColor: const Color(0xFF2E9265),
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                m.th,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                m.en,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              onChanged: (bool? val) {
                setDialogState(() {
                  if (val == true) {
                    if (_selectedMuscleIds.length >= _maxMuscleSelect) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('สามารถเลือกได้ 5 กล้ามเนื้อ'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }
                    _selectedMuscleIds.add(m.id);
                  } else {
                    _selectedMuscleIds.remove(m.id);
                  }
                });
              },
            ),
          );
        }), 
      ],
    ),
  );
}

// ---------------------- STEP 3: TARGETS ----------------------
  Widget _buildStep3Targets(StateSetter setDialogState) {
    return Form(
      key: _step3FormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เป้าหมายที่ต้องการ',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _setsController,
                    hint: 'Sets',
                    helperText: 'จำนวนเซต',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'กรุณากรอกข้อมูล';
                      final num = int.tryParse(val);
                      if (num == null || num < 1 || num > 20) return '1-20';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // ------ Reps: ปิดเมื่อใช้การจับเวลา ------
                Expanded(
                  child: _buildTextField(
                    controller: _repsController,
                    hint: 'Reps',
                    helperText: _useDuration
                        ? 'ปิดใช้งานเมื่อใช้การจับเวลา'
                        : 'กี่ครั้งต่อ 1 เซต',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    enabled: !_useDuration, // <<< ปิด input เมื่อเปิดจับเวลา
                    validator: (val) {
                      if (_useDuration) return null; // <<< ข้ามการ validate เมื่อใช้เวลา
                      if (val == null || val.trim().isEmpty) return 'กรุณากรอกข้อมูล';
                      final num = int.tryParse(val);
                      if (num == null || num < 1 || num > 100) return '1-100';
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ------ สวิตช์ ใช้การจับเวลา ------
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _useDuration ? const Color(0xFF2E9265) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: SwitchListTile(
                value: _useDuration,
                onChanged: (v) => setDialogState(() {
                  _useDuration = v;
                  if (v) {
                    // เคลียร์ค่า reps ทันที เพื่อให้แน่ใจว่าจะไม่ถูกส่ง
                    _repsController.clear();
                  }
                }),
                activeColor: const Color(0xFF2E9265),
                title: const Text(
                  'ใช้การจับเวลา',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _useDuration
                      ? 'ระยะเวลา: ${_pickedDuration.inMinutes} นาที ${_pickedDuration.inSeconds % 60} วินาที'
                      : 'เปิดใช้งานการออกกำลังกายตามเวลา',
                  style: TextStyle(
                    color: _useDuration ? const Color(0xFF2E9265) : Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            if (_useDuration) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _durationController, // ช่องกรอกเวลา (วินาที)
                hint: 'เวลา (วินาที)',
                helperText: 'กรุณากรอกเวลาเป็นวินาที',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  final num = int.tryParse(val ?? '');
                  if (num == null || num <= 0) {
                    return 'กรุณากรอกเวลาให้ถูกต้อง';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  // ---------------------- WIZARD FOOTER ----------------------
  Widget _buildWizardFooter(BuildContext dialogCtx, StateSetter setDialogState) {
    final isLastStep = _currentStep == 2;

    final cancelBtn = TextButton.icon(
      onPressed: (_isSubmitting || _isPaging) ? null : () => Navigator.of(dialogCtx).pop(),
      icon: const Icon(Icons.cancel_outlined),
      label: const Text('ยกเลิก'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    final backBtn = OutlinedButton.icon(
      onPressed: (_isSubmitting || _isPaging || _currentStep == 0)
          ? null
          : () => _goToStep(_currentStep - 1, setDialogState),
      icon: const Icon(Icons.arrow_back),
      label: const Text('ย้อนกลับ'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    final confirmBtn = ElevatedButton.icon(
      onPressed: (_isSubmitting || _isPaging) ? null : () => _handleNextOrConfirm(dialogCtx, setDialogState),
      icon: _isSubmitting
          ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
            )
          : Icon(isLastStep ? Icons.check_circle : Icons.arrow_forward),
      label: Text(
        _isSubmitting
            ? 'กำลังส่ง'
            : (isLastStep ? 'ยืนยัน' : 'ถัดไป'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E9265),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        minimumSize: const Size(0, 40),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    return MediaQuery.removeViewInsets(
      context: dialogCtx,
      removeBottom: true,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              cancelBtn,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: _currentStep > 0,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: backBtn,
                  ),
                  const SizedBox(width: 8),
                  confirmBtn,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNextOrConfirm(BuildContext dialogCtx, StateSetter setDialogState) async {
    if (_currentStep == 0) {
      if (!_step1FormKey.currentState!.validate()) return;

      final filledSteps = _stepControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .length;
      if (filledSteps < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('โปรดระบุอย่างน้อย 1 ขั้นตอน'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await _goToStep(1, setDialogState); // ไปหน้ากล้ามเนื้อ
      return;
    }

    if (_currentStep == 1) {
      if (_selectedMuscleIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('โปรดเลือกกล้ามเนื้ออย่างน้อย 1 กล้ามเนื้อ'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await _goToStep(2, setDialogState); // ไปหน้าเป้าหมาย
      return;
    }

    // _currentStep == 2 -> Confirm & Submit
    if (!_step3FormKey.currentState!.validate()) return;


    setDialogState(() => _isSubmitting = true);
    try {
      final success = await _submitExerciseRequest(context);
      if (!context.mounted) return;
      if (success && mounted) {
        Navigator.of(dialogCtx).pop();
        await _refreshExercises();
        _showSuccessSnackbar();
      }
    } finally {
      if (mounted) setDialogState(() => _isSubmitting = false);
    }
  }

  Future<bool> _submitExerciseRequest(BuildContext ctx) async {
  final userId = ctx.read<UserProvider>().userId;
  if (userId == null) {
    _showErrorSnackbar('ผู้ใช้ไม่ได้รับการรับรอง');
    return false;
  }

  try {
    final stepsCount = _stepControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .length;
    if (stepsCount < 1) {
      _showErrorSnackbar('โปรดระบุอย่างน้อย 1 ขั้นตอน');
      return false;
    }

    final setsVal = int.tryParse(_setsController.text.trim());
    final repsVal = _useDuration ? null : int.tryParse(_repsController.text.trim()); // ถ้าใช้การจับเวลา ไม่ต้องส่ง reps
    if (setsVal == null || setsVal < 1) {
      _showErrorSnackbar('กรอกจำนวนเซตให้ถูกต้อง');
      return false;
    }

    // ไม่ให้เป็น null เมื่อใช้การจับเวลา
    final reps = _useDuration ? 0 : (repsVal ?? 0); // หาก repsVal เป็น null ให้ใช้ค่า 0 แทน

    final stepsLines = _stepControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .take(5)
        .toList();

    await ApiService.addExerciseRequestPg(
      userId: userId,
      nameEn: _nameController.text.trim(),
      sets: setsVal,
      reps: reps, // ส่ง reps หากไม่ใช้เวลา
      benefits: _benefitsController.text.trim(),
      tips: _tipsController.text.trim(),
      durationSeconds: _useDuration ? _pickedDuration.inSeconds : null, // ส่งเวลาในวินาที
      muscleId1: _selectedMuscleIds.elementAt(0),
      muscleId2: _selectedMuscleIds.length > 1 ? _selectedMuscleIds.elementAt(1) : null,
      muscleId3: _selectedMuscleIds.length > 2 ? _selectedMuscleIds.elementAt(2) : null,
      muscleId4: _selectedMuscleIds.length > 3 ? _selectedMuscleIds.elementAt(3) : null,
      muscleId5: _selectedMuscleIds.length > 4 ? _selectedMuscleIds.elementAt(4) : null,
      exerciseStepsLines: stepsLines,
    );

    return true;
  } catch (e) {
    _showErrorSnackbar('คำขอผิดพลาด: $e');
    return false;
  }
}

  void _clearWizardData() {
    setState(() {
      _currentStep = 0;
      _nameController.clear();
      _benefitsController.clear();
      _stepsController.clear();
      _tipsController.clear();
      _setsController.clear();
      _repsController.clear();
      _selectedMuscleIds.clear();
      _useDuration = false;
      _pickedDuration = const Duration(minutes: 2, seconds: 30);
      _isSubmitting = false;
      for (final c in _stepControllers) { c.clear(); }
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    _step1FormKey.currentState?.reset();
    _step3FormKey.currentState?.reset();
  }

  // ---------------------- SNACKBAR HELPERS ----------------------

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'ส่งคำขอเพิ่มท่าออกกำลังกายเสร็จสิ้น',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E9265),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ---------------------- MAIN BUILD ----------------------

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    if (!user.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFF181717),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 80,
                color: Colors.redAccent.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              const Text(
                'ต้องการสิทธิ Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'หน้านี้สามารถเข้าถึงได้เฉพาะ Admin',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 22,
        ),
        title: const Text(
          'จัดการท่าออกกำลังกาย',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            splashRadius: 22,
            onPressed: _openWizard,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.white24),
        ),
      ),
      body: RadialBackground(
        child: RefreshIndicator(
          onRefresh: _refreshExercises,
          color: const Color(0xFF2E9265),
          backgroundColor: const Color(0xFF1B1B1B),
          child: FutureBuilder<List<ExerciseInfo>>(
            future: _exercisesFuture,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF2E9265),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'กำลังโหลดท่าออกกำลังกาย...',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snap.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.redAccent.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ผิดพลาด',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          '${snap.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshExercises,
                        icon: const Icon(Icons.refresh),
                        label: const Text('ลองอีกครั้ง'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9265),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final items = snap.data ?? [];

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ยังไม่มีท่าออกกำลังกาย',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'กดปุ่ม + เพื่อส่งคำขอเพิ่มท่าออกกำลังกาย',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final exercise = items[i];
                  return _buildExerciseCard(exercise);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Card: รูป + ชื่อ เท่านั้น
  Widget _buildExerciseCard(ExerciseInfo exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF222222), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E9265).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _exerciseThumb(exercise.imageUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                exercise.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseThumb(String? url) {
    final has = (url ?? '').trim().isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E9265), Color(0xFF25805A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E9265).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.white,
          child: has
              ? Image.network(url!, fit: BoxFit.contain)
              : const Center(
                  child: Icon(Icons.fitness_center, color: Colors.grey, size: 28),
                ),
        ),
      ),
    );
  }
}
