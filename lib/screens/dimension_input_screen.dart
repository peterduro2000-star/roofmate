import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calculator_mode.dart';
import '../models/project_model.dart';
import '../models/roof_section_model.dart';
import '../services/app_settings_service.dart';
import '../services/project_calculation_service.dart';
import '../services/roof_input_validator.dart';
import '../widgets/app_action_button.dart';
import '../widgets/info_panel.dart';
import '../widgets/metric_input_field.dart';
import '../widgets/professional_header.dart';
import '../widgets/segmented_metric_selector.dart';
import 'results_screen.dart';

class DimensionInputScreen extends StatefulWidget {
  final String roofType;
  final ProjectModel? project;

  const DimensionInputScreen({
    super.key,
    required this.roofType,
    this.project,
  });

  @override
  State<DimensionInputScreen> createState() => _DimensionInputScreenState();
}

class _DimensionInputScreenState extends State<DimensionInputScreen> {
  final _projectNameController =
      TextEditingController(text: 'New roof project');
  final _clientNameController = TextEditingController();
  final _siteAddressController = TextEditingController();
  final _sectionNameController = TextEditingController(text: 'Main roof');
  final _lengthController = TextEditingController();
  final _spanController = TextEditingController();
  final _pitchController = TextEditingController(text: '25');
  final _overhangController = TextEditingController(text: '0.3');
  final _lapAllowanceController = TextEditingController(text: '0.15');
  final _sheetWidthController = TextEditingController(text: '0.686');
  final _pricePerSheetController = TextEditingController(text: '0');
  final _wasteController = TextEditingController(text: '10');
  final _labourController = TextEditingController(text: '0');
  final _transportController = TextEditingController(text: '0');
  final _profitController = TextEditingController(text: '0');

  CalculatorMode _mode = CalculatorMode.simple;
  bool _settingsLoaded = false;
  String _roofType = 'gable';
  String _rafterSpacing = '0.9';
  String _purlinSpacing = '0.3';
  String _sheetType = 'Longspan sheet';
  final List<RoofSectionModel> _sections = [];

  @override
  void initState() {
    super.initState();
    final project = widget.project;

    if (project == null) {
      _roofType = widget.roofType;
      return;
    }

    _projectNameController.text = project.name;
    _clientNameController.text = project.clientName;
    _siteAddressController.text = project.siteAddress;
    _labourController.text = _formatNumber(project.labourCost);
    _transportController.text = _formatNumber(project.transportCost);
    _profitController.text = _formatNumber(project.profitMargin * 100);
    _mode = project.mode;
    _roofType = project.roofType;
    _sections.addAll(project.roofSections);

    final firstSection = project.primaryRoofSection;
    if (firstSection != null) {
      _sheetType = firstSection.sheetType;
      _rafterSpacing = _formatNumber(firstSection.rafterSpacing);
      _purlinSpacing = _formatNumber(firstSection.purlinSpacing);
      _pitchController.text = _formatNumber(firstSection.pitch);
      _overhangController.text = _formatNumber(firstSection.overhang);
      _lapAllowanceController.text = _formatNumber(firstSection.lapAllowance);
      _sheetWidthController.text =
          _formatNumber(firstSection.sheetEffectiveWidth);
      _pricePerSheetController.text = _formatNumber(firstSection.pricePerSheet);
      _wasteController.text = _formatNumber(firstSection.wastePercentage * 100);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_settingsLoaded || widget.project != null) return;

    final settings = context.read<AppSettingsService>().settings;
    _wasteController.text =
        (settings.defaultWastePercentage * 100).toStringAsFixed(0);
    _sheetType = settings.defaultRoofMaterial;
    _settingsLoaded = true;
  }

  void _addSection() {
    try {
      final length = double.parse(_lengthController.text);
      final span = double.parse(_spanController.text);
      final pitch = _mode == CalculatorMode.simple
          ? 25.0
          : double.parse(_pitchController.text);
      final overhang = _mode == CalculatorMode.simple
          ? 0.3
          : double.parse(_overhangController.text);
      final lapAllowance = _mode == CalculatorMode.simple
          ? 0.15
          : double.parse(_lapAllowanceController.text);
      final sheetEffectiveWidth = _mode == CalculatorMode.simple
          ? 0.686
          : double.parse(_sheetWidthController.text);
      final wastePercentage = double.parse(_wasteController.text) / 100;
      final pricePerSheet = double.parse(_pricePerSheetController.text);
      final rafterSpacing = double.parse(_rafterSpacing);
      final purlinSpacing = double.parse(_purlinSpacing);

      if (length <= 0 || span <= 0 || sheetEffectiveWidth <= 0) {
        _showMessage(
          'Check the measurements: length, width, and sheet width must be greater than zero.',
        );
        return;
      }

      final section = RoofSectionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _sectionNameController.text.trim().isEmpty
            ? 'Roof section ${_sections.length + 1}'
            : _sectionNameController.text.trim(),
        roofType: _roofType,
        length: length,
        span: span,
        pitch: pitch,
        overhang: overhang,
        rafterSpacing: rafterSpacing,
        battenSpacing: purlinSpacing,
        purlinSpacing: purlinSpacing,
        lapAllowance: lapAllowance,
        sheetEffectiveWidth: sheetEffectiveWidth,
        wastePercentage: wastePercentage,
        sheetType: _sheetType,
        pricePerSheet: pricePerSheet,
      );
      final validationMessage = RoofInputValidator.validateSection(section);
      if (validationMessage != null) {
        _showMessage(validationMessage);
        return;
      }

      setState(() {
        _sections.add(section.copyWith(
          calculation: ProjectCalculationService.calculateSection(section),
        ));
        _sectionNameController.text = 'Roof section ${_sections.length + 1}';
        _lengthController.clear();
        _spanController.clear();
      });
    } catch (_) {
      _showMessage(
        'Some section values are not valid numbers. Please check the fields and try again.',
      );
    }
  }

  void _calculateProject() {
    if (_sections.isEmpty) {
      _addSection();
      if (_sections.isEmpty) return;
    }

    final now = DateTime.now();
    final project = ProjectModel(
      id: widget.project?.id ?? now.microsecondsSinceEpoch.toString(),
      clientName: _clientNameController.text.trim(),
      siteAddress: _siteAddressController.text.trim(),
      name: _projectNameController.text.trim().isEmpty
          ? 'Roof project'
          : _projectNameController.text.trim(),
      roofType: _roofType,
      mode: _mode,
      labourCost: _parseMoney(_labourController),
      transportCost: _parseMoney(_transportController),
      profitMargin: _parsePercent(_profitController),
      createdAt: widget.project?.createdAt ?? now,
      updatedAt: now,
      roofSections: List.unmodifiable(_sections),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(project: project),
      ),
    );
  }

  double _parseMoney(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0;
  }

  double _parsePercent(TextEditingController controller) {
    return (double.tryParse(controller.text) ?? 0) / 100;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _clientNameController.dispose();
    _siteAddressController.dispose();
    _sectionNameController.dispose();
    _lengthController.dispose();
    _spanController.dispose();
    _pitchController.dispose();
    _overhangController.dispose();
    _lapAllowanceController.dispose();
    _sheetWidthController.dispose();
    _pricePerSheetController.dispose();
    _wasteController.dispose();
    _labourController.dispose();
    _transportController.dispose();
    _profitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.project == null ? 'Project Builder' : 'Edit Project'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfessionalHeader(
              title: 'Complete Roofing Project',
              subtitle:
                  '${widget.project == null ? 'New' : 'Editing'} | ${_mode.label} | ${_sections.length} section${_sections.length == 1 ? '' : 's'} added',
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedMetricSelector(
                    label: 'Calculator Mode',
                    value: _mode.name,
                    options: const ['simple', 'professional'],
                    suffix: '',
                    labels: const {
                      'simple': 'Simple',
                      'professional': 'Professional',
                    },
                    onChanged: (value) {
                      setState(() => _mode = CalculatorMode.fromName(value));
                    },
                    description:
                        'Simple mode is faster. Professional mode exposes pitch, lap, spacing, waste, and cost controls.',
                  ),
                  const SizedBox(height: 20),
                  _ProjectDetails(
                    projectNameController: _projectNameController,
                    clientNameController: _clientNameController,
                    siteAddressController: _siteAddressController,
                  ),
                  const SizedBox(height: 24),
                  _SectionForm(
                    mode: _mode,
                    roofType: _roofType,
                    sheetType: _sheetType,
                    rafterSpacing: _rafterSpacing,
                    purlinSpacing: _purlinSpacing,
                    sectionNameController: _sectionNameController,
                    lengthController: _lengthController,
                    spanController: _spanController,
                    pitchController: _pitchController,
                    overhangController: _overhangController,
                    lapAllowanceController: _lapAllowanceController,
                    sheetWidthController: _sheetWidthController,
                    pricePerSheetController: _pricePerSheetController,
                    wasteController: _wasteController,
                    onRoofTypeChanged: (value) =>
                        setState(() => _roofType = value),
                    onSheetTypeChanged: (value) =>
                        setState(() => _sheetType = value),
                    onRafterSpacingChanged: (value) =>
                        setState(() => _rafterSpacing = value),
                    onPurlinSpacingChanged: (value) =>
                        setState(() => _purlinSpacing = value),
                  ),
                  const SizedBox(height: 20),
                  AppActionButton(
                    label: 'Add Roof Section',
                    icon: Icons.add_home_work_outlined,
                    outlined: true,
                    onPressed: _addSection,
                  ),
                  if (_sections.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionList(
                      sections: _sections,
                      onRemove: (section) {
                        setState(() => _sections.remove(section));
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  _CostDetails(
                    labourController: _labourController,
                    transportController: _transportController,
                    profitController: _profitController,
                  ),
                  const SizedBox(height: 24),
                  const InfoPanel(
                    title: 'PROJECT TOTALS',
                    message:
                        'Each roof section is calculated separately, then combined into one project total for materials and costing.',
                    icon: Icons.functions,
                  ),
                  const SizedBox(height: 32),
                  AppActionButton(
                    label: widget.project == null
                        ? 'Calculate Project'
                        : 'Update Project Estimate',
                    icon: Icons.calculate_outlined,
                    onPressed: _calculateProject,
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

class _ProjectDetails extends StatelessWidget {
  final TextEditingController projectNameController;
  final TextEditingController clientNameController;
  final TextEditingController siteAddressController;

  const _ProjectDetails({
    required this.projectNameController,
    required this.clientNameController,
    required this.siteAddressController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          'Project Details',
          tooltip: 'These details appear on quotations and saved projects.',
        ),
        MetricInputField(
          label: 'Project Name',
          controller: projectNameController,
          hint: 'e.g., Ajah duplex roof',
          description: 'A clear name helps you find this project later.',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        MetricInputField(
          label: 'Client Name',
          controller: clientNameController,
          hint: 'e.g., Mr. Ade',
          description: 'Optional client name for future quotations.',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        MetricInputField(
          label: 'Site Address',
          controller: siteAddressController,
          hint: 'e.g., Lekki Phase 1',
          description: 'Optional project location.',
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }
}

class _SectionForm extends StatelessWidget {
  final CalculatorMode mode;
  final String roofType;
  final String sheetType;
  final String rafterSpacing;
  final String purlinSpacing;
  final TextEditingController sectionNameController;
  final TextEditingController lengthController;
  final TextEditingController spanController;
  final TextEditingController pitchController;
  final TextEditingController overhangController;
  final TextEditingController lapAllowanceController;
  final TextEditingController sheetWidthController;
  final TextEditingController pricePerSheetController;
  final TextEditingController wasteController;
  final ValueChanged<String> onRoofTypeChanged;
  final ValueChanged<String> onSheetTypeChanged;
  final ValueChanged<String> onRafterSpacingChanged;
  final ValueChanged<String> onPurlinSpacingChanged;

  const _SectionForm({
    required this.mode,
    required this.roofType,
    required this.sheetType,
    required this.rafterSpacing,
    required this.purlinSpacing,
    required this.sectionNameController,
    required this.lengthController,
    required this.spanController,
    required this.pitchController,
    required this.overhangController,
    required this.lapAllowanceController,
    required this.sheetWidthController,
    required this.pricePerSheetController,
    required this.wasteController,
    required this.onRoofTypeChanged,
    required this.onSheetTypeChanged,
    required this.onRafterSpacingChanged,
    required this.onPurlinSpacingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          'Roof Section',
          tooltip:
              'Add each real roof area separately, such as main roof, veranda, porch, or extension.',
        ),
        MetricInputField(
          label: 'Section Name',
          controller: sectionNameController,
          hint: 'e.g., Veranda roof',
          description: 'Name each part of the building separately.',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'Roof Type',
          value: roofType,
          options: const {
            'gable': 'Gable Roof',
            'hip': 'Hip Roof',
            'mono-pitch': 'Mono-Pitch Roof',
          },
          onChanged: onRoofTypeChanged,
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'Sheet Type',
          value: sheetType,
          options: const {
            'Longspan sheet': 'Longspan sheet',
            'IBR sheet': 'IBR sheet',
            'Step tile sheet': 'Step tile sheet',
            'Stone coated sheet': 'Stone coated sheet',
          },
          onChanged: onSheetTypeChanged,
        ),
        const SizedBox(height: 16),
        MetricInputField(
          label: 'Building Length (meters) *',
          controller: lengthController,
          hint: 'e.g., 10',
          description: 'Wall-to-wall length for this section.',
        ),
        const SizedBox(height: 16),
        MetricInputField(
          label: 'Building Width (meters) *',
          controller: spanController,
          hint: 'e.g., 7',
          description: 'Wall-to-wall width for this section.',
        ),
        const SizedBox(height: 16),
        MetricInputField(
          label: 'Price per Sheet',
          controller: pricePerSheetController,
          hint: 'e.g., 8500',
          description: 'Used when no editable material price has been set.',
        ),
        const SizedBox(height: 16),
        MetricInputField(
          label: 'Waste Percentage',
          controller: wasteController,
          hint: 'e.g., 10',
          description: 'Waste allowance applied to sheets and project pricing.',
        ),
        if (mode == CalculatorMode.professional) ...[
          const SizedBox(height: 16),
          MetricInputField(
            label: 'Pitch Angle (degrees)',
            controller: pitchController,
            hint: 'e.g., 25',
            description:
                'Roof slope angle. Most residential roofs fall between 15 and 45 degrees.',
          ),
          const SizedBox(height: 16),
          MetricInputField(
            label: 'Overhang (meters)',
            controller: overhangController,
            hint: 'e.g., 0.3',
            description: 'Roof extension beyond the wall.',
          ),
          const SizedBox(height: 16),
          MetricInputField(
            label: 'Lap Allowance (meters)',
            controller: lapAllowanceController,
            hint: 'e.g., 0.15',
            description: 'Extra allowance for sheet overlap and laps.',
          ),
          const SizedBox(height: 16),
          MetricInputField(
            label: 'Sheet Effective Width (meters)',
            controller: sheetWidthController,
            hint: 'e.g., 0.686',
            description: 'Net cover width after side laps.',
          ),
          const SizedBox(height: 16),
          SegmentedMetricSelector(
            label: 'Rafter Spacing (meters)',
            value: rafterSpacing,
            options: const ['0.6', '0.9'],
            onChanged: onRafterSpacingChanged,
            description:
                'Structural rafter spacing. Common values are 0.6m or 0.9m.',
          ),
          const SizedBox(height: 16),
          SegmentedMetricSelector(
            label: 'Purlin Spacing (meters)',
            value: purlinSpacing,
            options: const ['0.3', '0.4'],
            onChanged: onPurlinSpacingChanged,
            description:
                'Purlin or batten spacing across rafters. Typical values are 0.3m or 0.4m.',
          ),
        ],
      ],
    );
  }
}

class _SectionList extends StatelessWidget {
  final List<RoofSectionModel> sections;
  final ValueChanged<RoofSectionModel> onRemove;

  const _SectionList({
    required this.sections,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          'Added Sections',
          tooltip: 'These sections will be calculated separately and combined.',
        ),
        ...sections.map(
          (section) => Card(
            child: ListTile(
              leading: const Icon(Icons.roofing_outlined),
              title: Text(section.name),
              subtitle: Text(
                '${section.displayName} | ${section.length}m x ${section.width}m',
              ),
              trailing: IconButton(
                tooltip: 'Remove section',
                icon: const Icon(Icons.close),
                onPressed: () => onRemove(section),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CostDetails extends StatelessWidget {
  final TextEditingController labourController;
  final TextEditingController transportController;
  final TextEditingController profitController;

  const _CostDetails({
    required this.labourController,
    required this.transportController,
    required this.profitController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          'Project Costing',
          tooltip:
              'Labour, transport, and profit are added after material and waste costs.',
        ),
        MetricInputField(
          label: 'Labour Cost',
          controller: labourController,
          hint: 'e.g., 150000',
          description: 'Optional labour allowance.',
        ),
        const SizedBox(height: 16),
        MetricInputField(
          label: 'Transport Cost',
          controller: transportController,
          hint: 'e.g., 50000',
          description: 'Optional logistics or delivery allowance.',
        ),
        const SizedBox(height: 16),
        MetricInputField(
          label: 'Profit Margin (%)',
          controller: profitController,
          hint: 'e.g., 15',
          description:
              'Margin applied after materials, waste, labour, and transport.',
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(),
          items: options.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? tooltip;

  const _SectionTitle(this.title, {this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          if (tooltip != null) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: tooltip!,
              child: const Icon(
                Icons.help_outline,
                size: 18,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
