import 'package:flutter/material.dart';

class SegmentedMetricSelector extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String description;
  final String suffix;
  final Map<String, String>? labels;

  const SegmentedMetricSelector({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.description,
    this.suffix = 'm',
    this.labels,
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
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: options.map((option) {
              final isSelected = value == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x140F172A),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      labels?[option] ?? '$option$suffix',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF1E40AF)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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
