import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/company_profile_model.dart';
import '../models/material_model.dart';
import '../models/project_calculation.dart';
import '../models/project_model.dart';
import '../services/company_profile_service.dart';
import '../services/material_database_service.dart';
import '../services/project_calculation_service.dart';
import '../services/project_service.dart';
import '../services/quotation_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_action_button.dart';
import '../widgets/material_result_card.dart';
import '../widgets/parameter_row.dart';
import '../widgets/roof_preview.dart';
import 'dimension_input_screen.dart';

class ResultsScreen extends StatelessWidget {
  final ProjectModel project;
  static const _quotationService = QuotationService();

  const ResultsScreen({
    super.key,
    required this.project,
  });

  Future<void> _saveProject(BuildContext context) async {
    await context.read<ProjectService>().saveProject(
          project.copyWith(updatedAt: DateTime.now()),
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project saved successfully')),
    );
  }

  Future<void> _previewPdf({
    required BuildContext context,
    required ProjectCalculation calculation,
    required List<MaterialModel> materials,
    required CompanyProfileModel profile,
  }) async {
    try {
      await Printing.layoutPdf(
        name: 'Quotation - ${project.name}',
        onLayout: (_) => _quotationService.buildPdfBytes(
          project: project,
          calculation: calculation,
          materials: materials,
          companyProfile: profile,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF preview')),
      );
    }
  }

  Future<void> _generatePdf({
    required BuildContext context,
    required ProjectCalculation calculation,
    required List<MaterialModel> materials,
    required CompanyProfileModel profile,
  }) async {
    try {
      final file = await _quotationService.savePdf(
        project: project,
        calculation: calculation,
        materials: materials,
        companyProfile: profile,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved: ${file.path}')),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save PDF quotation')),
      );
    }
  }

  Future<void> _sharePdf({
    required BuildContext context,
    required ProjectCalculation calculation,
    required List<MaterialModel> materials,
    required CompanyProfileModel profile,
    required String fallbackText,
  }) async {
    try {
      final file = await _quotationService.savePdf(
        project: project,
        calculation: calculation,
        materials: materials,
        companyProfile: profile,
      );

      await SharePlus.instance.share(
        ShareParams(
          text: fallbackText,
          subject: 'Quotation - ${project.name}',
          files: [XFile(file.path)],
        ),
      );
    } catch (_) {
      await SharePlus.instance.share(
        ShareParams(
          text: fallbackText,
          subject: 'Quotation - ${project.name}',
        ),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF sharing failed, text summary shared instead'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final materials = context.watch<MaterialDatabaseService>().materials;
    final profile = context.watch<CompanyProfileService>().profile;
    final calculation = ProjectCalculationService.calculateProject(
      project: project,
      materials: materials,
    );
    final quotation = _quotationService.build(
      project: project,
      calculation: calculation,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Estimate'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Edit project',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DimensionInputScreen(
                    roofType: project.roofType,
                    project: project,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProjectHeader(project: project, total: calculation.total),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProjectSummary(project: project),
                  const SizedBox(height: 24),
                  const _SectionTitle('Roof Preview'),
                  RoofPreview(project: project),
                  const SizedBox(height: 24),
                  _MaterialSummary(calculation: calculation),
                  const SizedBox(height: 24),
                  _CostBreakdown(calculation: calculation),
                  const SizedBox(height: 24),
                  _SectionBreakdown(calculation: calculation, project: project),
                  const SizedBox(height: 24),
                  _QuotationActions(
                    quotationText: quotation.quotationText,
                    boqCsv: quotation.boqCsv,
                    shareText: quotation.shareText,
                    onPreviewPdf: () => _previewPdf(
                      context: context,
                      calculation: calculation,
                      materials: materials,
                      profile: profile,
                    ),
                    onGeneratePdf: () => _generatePdf(
                      context: context,
                      calculation: calculation,
                      materials: materials,
                      profile: profile,
                    ),
                    onSharePdf: () => _sharePdf(
                      context: context,
                      calculation: calculation,
                      materials: materials,
                      profile: profile,
                      fallbackText: quotation.shareText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppActionButton(
                    label: 'Save Project',
                    icon: Icons.save_outlined,
                    onPressed: () => _saveProject(context),
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Edit Project',
                    icon: Icons.edit_outlined,
                    outlined: true,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DimensionInputScreen(
                            roofType: project.roofType,
                            project: project,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Back to Home',
                    icon: Icons.home_outlined,
                    outlined: true,
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
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

class _QuotationActions extends StatelessWidget {
  final String quotationText;
  final String boqCsv;
  final String shareText;
  final VoidCallback onPreviewPdf;
  final VoidCallback onGeneratePdf;
  final VoidCallback onSharePdf;

  const _QuotationActions({
    required this.quotationText,
    required this.boqCsv,
    required this.shareText,
    required this.onPreviewPdf,
    required this.onGeneratePdf,
    required this.onSharePdf,
  });

  Future<void> _copy(BuildContext context, String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryActions = [
      _ToolAction(
        label: 'Preview PDF',
        icon: Icons.picture_as_pdf_outlined,
        onPressed: onPreviewPdf,
        style: _ToolStyle.secondary,
      ),
      _ToolAction(
        label: 'Generate PDF',
        icon: Icons.file_download_outlined,
        onPressed: onGeneratePdf,
        style: _ToolStyle.primary,
      ),
      _ToolAction(
        label: 'Share PDF',
        icon: Icons.ios_share_outlined,
        onPressed: onSharePdf,
        style: _ToolStyle.primary,
      ),
    ];
    final copyActions = [
      _ToolAction(
        label: 'Copy Quotation',
        icon: Icons.description_outlined,
        onPressed: () => _copy(
          context,
          quotationText,
          'Quotation copied',
        ),
        style: _ToolStyle.tertiary,
      ),
      _ToolAction(
        label: 'Copy BOQ CSV',
        icon: Icons.table_chart_outlined,
        onPressed: () => _copy(
          context,
          boqCsv,
          'BOQ CSV copied',
        ),
        style: _ToolStyle.tertiary,
      ),
      _ToolAction(
        label: 'Copy Summary',
        icon: Icons.share_outlined,
        onPressed: () => _copy(
          context,
          shareText,
          'Share summary copied',
        ),
        style: _ToolStyle.tertiary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Quotation Tools'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...primaryActions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ToolButton(action: action),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Copy actions',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        for (final action in copyActions)
                          _ToolButton(action: action, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final _ToolStyle style;

  const _ToolAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.style = _ToolStyle.secondary,
  });
}

enum _ToolStyle {
  primary,
  secondary,
  tertiary,
}

class _ToolButton extends StatelessWidget {
  final _ToolAction action;
  final bool compact;

  const _ToolButton({
    required this.action,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? null : double.infinity,
      height: compact ? 42 : 52,
      child: switch (action.style) {
        _ToolStyle.primary => ElevatedButton.icon(
            onPressed: action.onPressed,
            icon: Icon(action.icon, size: 19),
            label: Text(action.label),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        _ToolStyle.secondary => OutlinedButton.icon(
            onPressed: action.onPressed,
            icon: Icon(action.icon, size: 18),
            label: Text(action.label),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        _ToolStyle.tertiary => TextButton.icon(
            onPressed: action.onPressed,
            icon: Icon(action.icon, size: 17),
            label: Text(action.label),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      },
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final ProjectModel project;
  final double total;

  const _ProjectHeader({
    required this.project,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final sectionLabel =
        '${project.roofSections.length} section${project.roofSections.length == 1 ? '' : 's'}';
    final subtitleParts = [
      if (project.clientName.isNotEmpty) project.clientName,
      if (project.siteAddress.isNotEmpty) project.siteAddress,
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF1E40AF),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (subtitleParts.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitleParts.join(' • '),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderPill(
                label: project.mode.label,
                icon: Icons.workspace_premium_outlined,
                emphasized: true,
              ),
              _HeaderPill(label: sectionLabel, icon: Icons.roofing_outlined),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Estimated total',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.naira(total),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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

class _HeaderPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool emphasized;

  const _HeaderPill({
    required this.label,
    required this.icon,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: emphasized
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: emphasized ? Border.all(color: Colors.white38) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectSummary extends StatelessWidget {
  final ProjectModel project;

  const _ProjectSummary({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Project Details'),
        if (project.clientName.isNotEmpty)
          ParameterRow(label: 'Client', value: project.clientName),
        if (project.siteAddress.isNotEmpty)
          ParameterRow(label: 'Site', value: project.siteAddress),
        ParameterRow(label: 'Mode', value: project.mode.label),
        ParameterRow(
          label: 'Sections',
          value: project.roofSections.length.toString(),
        ),
      ],
    );
  }
}

class _MaterialSummary extends StatelessWidget {
  final ProjectCalculation calculation;

  const _MaterialSummary({required this.calculation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Combined Materials'),
        MaterialResultCard(
          icon: Icons.square_foot_outlined,
          title: 'ROOF AREA',
          value: '${calculation.roofArea.toStringAsFixed(1)} sqm',
          breakdown: [
            MaterialBreakdownItem(
              label: 'Sloped surface',
              value: '${calculation.roofArea.toStringAsFixed(1)} sqm',
            ),
            MaterialBreakdownItem(
              label: 'Measured sections',
              value: calculation.sectionCalculations.length.toString(),
            ),
          ],
          accentColor: const Color(0xFF0F766E),
        ),
        const SizedBox(height: 12),
        MaterialResultCard(
          icon: Icons.inventory_2_outlined,
          title: 'ROOF COVERING',
          value: '${calculation.sheets} sheets',
          breakdown: [
            MaterialBreakdownItem(
              label: 'Sheets to buy',
              value: calculation.sheets.toString(),
            ),
            const MaterialBreakdownItem(
              label: 'Allowance',
              value: 'Waste included',
            ),
          ],
          accentColor: const Color(0xFF1E40AF),
        ),
        const SizedBox(height: 12),
        MaterialResultCard(
          icon: Icons.straighten,
          title: 'TIMBER / STEEL FRAME',
          value: '${calculation.rafters} rafters',
          breakdown: [
            MaterialBreakdownItem(
              label: 'Rafters',
              value: calculation.rafters.toString(),
            ),
            MaterialBreakdownItem(
              label: 'Battens',
              value: calculation.battensNeeded.toString(),
            ),
            MaterialBreakdownItem(
              label: 'Wall plates',
              value: calculation.wallPlatesNeeded.toString(),
            ),
          ],
          accentColor: const Color(0xFF7C3AED),
        ),
        const SizedBox(height: 12),
        MaterialResultCard(
          icon: Icons.settings_outlined,
          title: 'ACCESSORIES',
          value: '${calculation.fasteners} fixings',
          breakdown: [
            MaterialBreakdownItem(
              label: 'Fixings',
              value: calculation.fasteners.toString(),
            ),
            MaterialBreakdownItem(
              label: 'Ridge length',
              value: '${calculation.ridgeBoardLength.toStringAsFixed(1)}m',
            ),
          ],
          accentColor: const Color(0xFFD97706),
        ),
      ],
    );
  }
}

class _CostBreakdown extends StatelessWidget {
  final ProjectCalculation calculation;
  static final NumberFormat _moneyFormatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  const _CostBreakdown({required this.calculation});

  @override
  Widget build(BuildContext context) {
    final totals = calculation.categoryTotals;
    const categories = [
      'Roof covering',
      'Timber/steel frame',
      'Accessories',
      'Labour',
      'Transport',
      'Waste',
      'Profit',
      'Total',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Cost Breakdown'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              for (final category
                  in categories.where((item) => item != 'Total'))
                _CostLine(
                  label: category,
                  value: _money(totals[category] ?? 0),
                  shaded: categories.indexOf(category).isOdd,
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF1E40AF),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      _money(totals['Total'] ?? 0),
                      style: const TextStyle(
                        color: Color(0xFF1E40AF),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _money(double value) => _moneyFormatter.format(value);
}

class _CostLine extends StatelessWidget {
  final String label;
  final String value;
  final bool shaded;

  const _CostLine({
    required this.label,
    required this.value,
    required this.shaded,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: shaded ? const Color(0xFFF8FAFC) : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 136,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBreakdown extends StatelessWidget {
  final ProjectCalculation calculation;
  final ProjectModel project;

  const _SectionBreakdown({
    required this.calculation,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Roof Sections'),
        ...project.roofSections.asMap().entries.map((entry) {
          final section = entry.value;
          final result = calculation.sectionCalculations[entry.key];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ParameterRow(
                    label: 'Dimensions',
                    value: '${section.length}m x ${section.width}m',
                  ),
                  ParameterRow(label: 'Roof type', value: section.displayName),
                  ParameterRow(
                      label: 'Sheets', value: result.sheets.toString()),
                  ParameterRow(
                    label: 'Area',
                    value: '${result.roofArea.toStringAsFixed(1)} sqm',
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}
