import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CustomBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    const green = Color.fromRGBO(46, 146, 101, 1);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromRGBO(75, 85, 99, 0.5),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          onPressed: onTap ?? () => Navigator.pop(context),
          splashColor: green.withValues(alpha: 0.15),
          highlightColor: green.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
