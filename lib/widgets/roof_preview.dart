import 'package:flutter/material.dart';

import '../models/project_model.dart';

class RoofPreview extends StatelessWidget {
  final ProjectModel project;

  const RoofPreview({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    if (project.roofSections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 236,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _RoofPreviewPainter(project),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RoofPreviewPainter extends CustomPainter {
  final ProjectModel project;

  const _RoofPreviewPainter(this.project);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E40AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..color = const Color(0x1A1E40AF)
      ..style = PaintingStyle.fill;
    final ridgePaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    _drawGrid(canvas, size, gridPaint);

    final sections = project.roofSections;
    final maxLength = sections
        .map((section) => section.length)
        .fold<double>(1, (max, length) => length > max ? length : max);
    final maxWidth = sections
        .map((section) => section.width)
        .fold<double>(1, (max, width) => width > max ? width : max);
    final columns = sections.length == 1 ? 1 : 2;
    final rows = (sections.length / columns).ceil();
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      final column = i % columns;
      final row = i ~/ columns;
      final cellOffset = Offset(column * cellWidth, row * cellHeight);
      final previewWidth = (section.length / maxLength) * (cellWidth - 34);
      final previewHeight = (section.width / maxWidth) * (cellHeight - 52);
      final left = cellOffset.dx + (cellWidth - previewWidth) / 2;
      final top = cellOffset.dy + 16;
      final rect = Rect.fromLTWH(left, top, previewWidth, previewHeight);

      final path = Path();
      final ridgePath = Path();
      if (section.roofType == 'mono-pitch') {
        path
          ..moveTo(rect.left, rect.bottom)
          ..lineTo(rect.right, rect.bottom - rect.height * 0.25)
          ..lineTo(rect.right, rect.top)
          ..lineTo(rect.left, rect.top + rect.height * 0.25)
          ..close();
        ridgePath
          ..moveTo(rect.left + rect.width * 0.12, rect.bottom - 8)
          ..lineTo(rect.right - rect.width * 0.12, rect.top + 8);
      } else if (section.roofType == 'hip') {
        path
          ..moveTo(rect.left + rect.width * 0.5, rect.top)
          ..lineTo(rect.right, rect.top + rect.height * 0.35)
          ..lineTo(rect.right - rect.width * 0.18, rect.bottom)
          ..lineTo(rect.left + rect.width * 0.18, rect.bottom)
          ..lineTo(rect.left, rect.top + rect.height * 0.35)
          ..close();
        ridgePath
          ..moveTo(rect.left + rect.width * 0.5, rect.top + 6)
          ..lineTo(rect.left + rect.width * 0.5, rect.bottom - 10)
          ..moveTo(rect.left + rect.width * 0.5, rect.top + 6)
          ..lineTo(rect.left + rect.width * 0.18, rect.bottom - 6)
          ..moveTo(rect.left + rect.width * 0.5, rect.top + 6)
          ..lineTo(rect.right - rect.width * 0.18, rect.bottom - 6);
      } else {
        path
          ..moveTo(rect.left, rect.bottom)
          ..lineTo(rect.left + rect.width * 0.5, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..close();
        ridgePath
          ..moveTo(rect.left + rect.width * 0.5, rect.top + 6)
          ..lineTo(rect.left + rect.width * 0.5, rect.bottom - 8);
      }

      canvas
        ..drawPath(path, fillPaint)
        ..drawPath(path, paint)
        ..drawPath(ridgePath, ridgePaint);

      labelPainter.text = TextSpan(
        text: section.name,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      labelPainter.layout(maxWidth: cellWidth - 16);
      labelPainter.paint(
        canvas,
        Offset(
          cellOffset.dx + (cellWidth - labelPainter.width) / 2,
          cellOffset.dy + cellHeight - 32,
        ),
      );

      labelPainter.text = TextSpan(
        text: '${section.length}m x ${section.width}m',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      labelPainter.layout(maxWidth: cellWidth - 16);
      labelPainter.paint(
        canvas,
        Offset(
          cellOffset.dx + (cellWidth - labelPainter.width) / 2,
          cellOffset.dy + cellHeight - 16,
        ),
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    const spacing = 28.0;
    for (var x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoofPreviewPainter oldDelegate) {
    return oldDelegate.project != project;
  }
}
