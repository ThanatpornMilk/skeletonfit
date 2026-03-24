import 'package:flutter/material.dart';

class RadialBackground extends StatelessWidget {
  final Widget child;
  final Color bg;

  const RadialBackground({
    super.key,
    required this.child,
    this.bg = const Color(0xFF181717),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity, 
      color: bg,
      child: Stack(
        children: [
          // ชั้นล่าง
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomLeft,
                  radius: 1.2,
                  colors: [
                    const Color.fromRGBO(46, 146, 101, 0.05),
                    bg,
                    bg,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
          // ชั้นบน
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.0,
                  colors: [
                    Color.fromRGBO(46, 146, 101, 0.08),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // ครอบเนื้อหา + SafeArea กันโดนรอยบาก/StatusBar
          Positioned.fill(
            child: SafeArea(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
