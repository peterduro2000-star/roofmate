import 'package:flutter/material.dart';

class MetricInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String description;
  final TextInputType keyboardType;

  const MetricInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.description,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
