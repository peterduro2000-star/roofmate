import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/material_model.dart';
import '../services/material_database_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/metric_input_field.dart';
import '../widgets/professional_header.dart';

class MaterialDatabaseScreen extends StatelessWidget {
  const MaterialDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MaterialDatabaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Prices'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Reset prices',
            icon: const Icon(Icons.restore),
            onPressed: () async {
              final shouldReset = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Price List?'),
                  content: const Text(
                    'This restores the default material list and clears edited prices.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (shouldReset == true) {
                await service.resetToDefaults();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const ProfessionalHeader(
            title: 'Editable Price List',
            subtitle:
                'Set local prices for sheets, timber, accessories, and wastage.',
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: service.materials.length,
              itemBuilder: (context, index) {
                final material = service.materials[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(material.name),
                    subtitle: Text('${material.category} | ${material.unit}'),
                    trailing: Text(CurrencyFormatter.naira(material.unitPrice)),
                    onTap: () => _editMaterial(context, material),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editMaterial(
    BuildContext context,
    MaterialModel material,
  ) async {
    final updated = await showDialog<MaterialModel>(
      context: context,
      builder: (dialogContext) => _EditMaterialDialog(material: material),
    );

    if (updated != null && context.mounted) {
      try {
        final service = context.read<MaterialDatabaseService>();
        await service.saveMaterial(updated);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material price saved')),
        );
      } catch (e) {
        debugPrint('Save material error: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving: $e')),
          );
        }
      }
    }
  }
}

class _EditMaterialDialog extends StatefulWidget {
  final MaterialModel material;

  const _EditMaterialDialog({required this.material});

  @override
  State<_EditMaterialDialog> createState() => _EditMaterialDialogState();
}

class _EditMaterialDialogState extends State<_EditMaterialDialog> {
  late final TextEditingController _priceController;
  late final TextEditingController _wasteController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.material.unitPrice.toStringAsFixed(2),
    );
    _wasteController = TextEditingController(
      text: (widget.material.wastePercentage * 100).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _wasteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.material.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MetricInputField(
              label: 'Unit Price',
              controller: _priceController,
              hint: 'e.g., 8500',
              description: widget.material.unit,
            ),
            const SizedBox(height: 16),
            MetricInputField(
              label: 'Waste Percentage',
              controller: _wasteController,
              hint: 'e.g., 10',
              description: 'Allowance used when costing this material.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final price = double.tryParse(_priceController.text);
    final waste = double.tryParse(_wasteController.text);

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid material price.')),
      );
      return;
    }
    if (waste == null || waste < 0 || waste > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waste should be between 0% and 50%.')),
      );
      return;
    }

    Navigator.pop(
      context,
      widget.material.copyWith(
        unitPrice: price,
        wastePercentage: waste / 100,
      ),
    );
  }
}
