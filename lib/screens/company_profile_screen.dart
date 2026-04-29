import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/company_profile_model.dart';
import '../services/company_profile_service.dart';
import '../widgets/app_action_button.dart';
import '../widgets/info_panel.dart';
import '../widgets/metric_input_field.dart';
import '../widgets/professional_header.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;

    final profile = context.read<CompanyProfileService>().profile;
    _companyNameController.text = profile.companyName;
    _phoneController.text = profile.phoneNumber;
    _emailController.text = profile.email;
    _addressController.text = profile.address;
    _loaded = true;
  }

  Future<void> _save() async {
    final profile = CompanyProfileModel(
      companyName: _companyNameController.text.trim().isEmpty
          ? 'RoofMate'
          : _companyNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );

    await context.read<CompanyProfileService>().saveProfile(profile);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company profile saved')),
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfessionalHeader(
              title: 'Company Profile',
              subtitle: 'Saved offline and used on client quotations.',
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MetricInputField(
                    label: 'Company Name',
                    controller: _companyNameController,
                    hint: 'e.g., Ade Roofing Services',
                    description: 'Displayed in the quotation header.',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  MetricInputField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hint: 'e.g., 08012345678',
                    description: 'Optional contact phone.',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  MetricInputField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'e.g., info@example.com',
                    description: 'Optional business email.',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  MetricInputField(
                    label: 'Address',
                    controller: _addressController,
                    hint: 'e.g., Lagos, Nigeria',
                    description: 'Optional office or workshop address.',
                    keyboardType: TextInputType.streetAddress,
                  ),
                  const SizedBox(height: 24),
                  const InfoPanel(
                    title: 'LOGO SUPPORT',
                    message:
                        'A logo placeholder is already included in the PDF header. Image upload can be added later without changing the quotation structure.',
                    icon: Icons.image_outlined,
                  ),
                  const SizedBox(height: 32),
                  AppActionButton(
                    label: 'Save Profile',
                    icon: Icons.save_outlined,
                    onPressed: _save,
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
