import 'package:flutter/material.dart';

class MuscleFilterDialog {
  static Future<Set<String>?> show(
    BuildContext context, {
    required List<String> allMuscles,
    required Set<String> initialSelected,
  }) {
    final tempSelected = Set<String>.from(initialSelected);
    allMuscles.sort();

    return showDialog<Set<String>>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181717),
          title: const Text('เลือกกล้ามเนื้อ', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (ctx, setState2) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allMuscles.length,
                  itemBuilder: (_, i) {
                    final m = allMuscles[i];
                    final sel = tempSelected.contains(m);
                    return CheckboxListTile(
                      value: sel,
                      title: Text(m, style: const TextStyle(color: Colors.white)),
                      activeColor: Colors.greenAccent,
                      onChanged: (v) {
                        setState2(() {
                          if (v == true) {
                            tempSelected.add(m);
                          } else {
                            tempSelected.remove(m);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              child: const Text('ตกลง', style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }
}
