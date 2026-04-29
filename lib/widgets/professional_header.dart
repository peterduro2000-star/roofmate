import 'package:flutter/material.dart';

class ProfessionalHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  const ProfessionalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E40AF),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
