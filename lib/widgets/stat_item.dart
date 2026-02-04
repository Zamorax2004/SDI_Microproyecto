import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;

  const StatItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
                fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
