import 'package:flutter/material.dart';

class MaterialResultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<MaterialBreakdownItem> breakdown;
  final Color accentColor;

  const MaterialResultCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.breakdown,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withValues(alpha: 0.16)),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        for (final item in breakdown)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.value,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialBreakdownItem {
  final String label;
  final String value;

  const MaterialBreakdownItem({
    required this.label,
    required this.value,
  });
}
