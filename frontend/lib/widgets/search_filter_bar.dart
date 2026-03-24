import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTapFilter;
  final String hint;
  final ValueChanged<String>? onChanged;

  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.onTapFilter,
    this.hint = 'ค้นหา...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: (value) => onChanged?.call(value.trim()),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white12,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTapFilter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.filter_list, color: Colors.white),
                SizedBox(width: 4),
                Text('Filter', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
