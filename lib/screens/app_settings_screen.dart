import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings_model.dart';
import '../services/app_settings_service.dart';
import '../services/company_profile_service.dart';
import '../services/project_service.dart';
import '../widgets/app_action_button.dart';
import '../widgets/info_panel.dart';
import '../widgets/metric_input_field.dart';
import '../widgets/professional_header.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _wasteController = TextEditingController();
  final _companyNameController = TextEditingController();
  String _currency = 'NGN';
  String _roofMaterial = 'Longspan sheet';
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;

    final settings = context.read<AppSettingsService>().settings;
    _wasteController.text =
        (settings.defaultWastePercentage * 100).toStringAsFixed(0);
    _companyNameController.text = settings.defaultCompanyName;
    _currency = settings.defaultCurrency;
    _roofMaterial = settings.defaultRoofMaterial;
    _loaded = true;
  }

  Future<void> _save() async {
    final waste = double.tryParse(_wasteController.text);
    if (waste == null || waste < 0 || waste > 50) {
      _showMessage('Default waste should be between 0% and 50%.');
      return;
    }

    final settings = AppSettingsModel(
      defaultWastePercentage: waste / 100,
      defaultCurrency: _currency,
      defaultRoofMaterial: _roofMaterial,
      defaultCompanyName: _companyNameController.text.trim().isEmpty
          ? 'RoofMate'
          : _companyNameController.text.trim(),
    );

    final settingsService = context.read<AppSettingsService>();
    final profileService = context.read<CompanyProfileService>();
    final updatedProfile = profileService.profile.copyWith(
      companyName: settings.defaultCompanyName,
    );

    await settingsService.saveSettings(settings);
    await profileService.saveProfile(updatedProfile);

    if (!mounted) return;
    _showMessage('App settings saved');
  }

  Future<void> _exportBackup() async {
    try {
      final file = await context.read<ProjectService>().exportProjectsJson();
      if (!mounted) return;
      _showMessage('Project backup saved: ${file.path}');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not export backup. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _wasteController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfessionalHeader(
              title: 'App Settings',
              subtitle: 'Offline defaults and local project backup.',
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MetricInputField(
                    label: 'Default Waste Percentage',
                    controller: _wasteController,
                    hint: 'e.g., 10',
                    description:
                        'Used when starting a new estimate. Keep it realistic for site cutting and laps.',
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Default Currency',
                    value: _currency,
                    options: const {'NGN': 'Nigerian Naira (₦)'},
                    onChanged: (value) => setState(() => _currency = value),
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Default Roof Material',
                    value: _roofMaterial,
                    options: const {
                      'Longspan sheet': 'Longspan sheet',
                      'IBR sheet': 'IBR sheet',
                      'Step tile sheet': 'Step tile sheet',
                      'Stone coated sheet': 'Stone coated sheet',
                    },
                    onChanged: (value) => setState(() => _roofMaterial = value),
                  ),
                  const SizedBox(height: 16),
                  MetricInputField(
                    label: 'Default Company Name',
                    controller: _companyNameController,
                    hint: 'e.g., Ade Roofing Services',
                    description:
                        'Also updates the company profile name used in quotations.',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 24),
                  const InfoPanel(
                    title: 'OFFLINE BACKUP',
                    message:
                        'Export saves all project records as a JSON file in this app’s documents folder.',
                    icon: Icons.backup_outlined,
                  ),
                  const SizedBox(height: 24),
                  AppActionButton(
                    label: 'Save Settings',
                    icon: Icons.save_outlined,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Export Projects JSON',
                    icon: Icons.file_download_outlined,
                    outlined: true,
                    onPressed: _exportBackup,
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
