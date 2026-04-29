import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/estimate_model.dart';
import '../services/estimate_service.dart';
import '../widgets/material_result_card.dart';
import '../widgets/parameter_row.dart';
import '../widgets/professional_header.dart';

class EstimateDetailScreen extends StatelessWidget {
  final Estimate estimate;

  const EstimateDetailScreen({
    super.key,
    required this.estimate,
  });

  Future<void> _deleteEstimate(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Estimate?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this estimate?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    await context.read<EstimateService>().deleteEstimate(estimate.id);

    if (!context.mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estimate deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimate Details'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Delete estimate',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteEstimate(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfessionalHeader(
              title: estimate.name,
              subtitle: estimate.date.toLocal().toString().split('.')[0],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input Parameters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ParameterRow(
                    label: 'Building Length',
                    value: '${estimate.length}m',
                  ),
                  ParameterRow(
                    label: 'Building Span',
                    value: '${estimate.span}m',
                  ),
                  ParameterRow(
                    label: 'Roof Pitch',
                    value: '${estimate.pitch} degrees',
                  ),
                  ParameterRow(
                    label: 'Eaves Overhang',
                    value: '${estimate.overhang}m',
                  ),
                  ParameterRow(
                    label: 'Rafter Spacing',
                    value: '${estimate.rasterSpacing}m',
                  ),
                  ParameterRow(
                    label: 'Batten Spacing',
                    value: '${estimate.battenSpacing}m',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Material Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MaterialResultCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'ROOFING SHEETS',
                    value: estimate.sheets.toString(),
                    breakdown: const [
                      MaterialBreakdownItem(
                        label: 'Cover width',
                        value: '0.686m',
                      ),
                      MaterialBreakdownItem(
                        label: 'Allowance',
                        value: 'Waste included',
                      ),
                    ],
                    accentColor: const Color(0xFF1E40AF),
                  ),
                  const SizedBox(height: 12),
                  MaterialResultCard(
                    icon: Icons.straighten,
                    title: 'RAFTER PIECES',
                    value: estimate.rafters.toString(),
                    breakdown: [
                      MaterialBreakdownItem(
                        label: 'Length each',
                        value: '${estimate.rasterLength.toStringAsFixed(2)}m',
                      ),
                    ],
                    accentColor: const Color(0xFF7C3AED),
                  ),
                  const SizedBox(height: 12),
                  MaterialResultCard(
                    icon: Icons.horizontal_rule,
                    title: 'RIDGE BOARD',
                    value: '${estimate.ridgeBoardLength.toStringAsFixed(1)}m',
                    breakdown: const [
                      MaterialBreakdownItem(
                        label: 'Typical member',
                        value: '38 x 200mm',
                      ),
                    ],
                    accentColor: const Color(0xFF0891B2),
                  ),
                  const SizedBox(height: 12),
                  MaterialResultCard(
                    icon: Icons.foundation_outlined,
                    title: 'WALL PLATES',
                    value: estimate.wallPlates.toString(),
                    breakdown: const [
                      MaterialBreakdownItem(
                        label: 'Standard length',
                        value: '6m',
                      ),
                    ],
                    accentColor: const Color(0xFF059669),
                  ),
                  const SizedBox(height: 12),
                  MaterialResultCard(
                    icon: Icons.grid_on_outlined,
                    title: 'BATTENS',
                    value: estimate.battens.toString(),
                    breakdown: const [
                      MaterialBreakdownItem(
                        label: 'Typical size',
                        value: '38 x 38mm',
                      ),
                      MaterialBreakdownItem(
                        label: 'Standard length',
                        value: '6m',
                      ),
                    ],
                    accentColor: const Color(0xFFD97706),
                  ),
                  const SizedBox(height: 12),
                  MaterialResultCard(
                    icon: Icons.settings_outlined,
                    title: 'FASTENERS',
                    value: '${estimate.sheets * 20} screws',
                    breakdown: const [
                      MaterialBreakdownItem(
                        label: 'Type',
                        value: 'Galvanized',
                      ),
                      MaterialBreakdownItem(
                        label: 'Washer',
                        value: 'Included',
                      ),
                    ],
                    accentColor: const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
