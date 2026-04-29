import 'package:flutter/material.dart';

import '../widgets/info_panel.dart';
import '../widgets/professional_header.dart';
import '../widgets/roof_type_card.dart';
import 'dimension_input_screen.dart';

class RoofTypeScreen extends StatelessWidget {
  const RoofTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const roofTypes = [
      {
        'id': 'gable',
        'name': 'Gable Roof',
        'description':
            'Two sloping sides forming a triangular gable. A practical and economical residential option.',
        'icon': Icons.roofing_outlined,
      },
      {
        'id': 'hip',
        'name': 'Hip Roof',
        'description':
            'Four sloping sides meeting at a ridge. Strong wind performance with higher material demand.',
        'icon': Icons.cottage_outlined,
      },
      {
        'id': 'mono-pitch',
        'name': 'Mono-Pitch Roof',
        'description':
            'A single roof plane. Simple, efficient, and well suited to extensions or compact structures.',
        'icon': Icons.change_history,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Roof Type'),
        elevation: 0,
      ),
      body: Column(
        children: [
          const ProfessionalHeader(
            title: 'Select Roof Type',
            subtitle:
                'Choose the closest roof profile so material quantities are calculated from the right geometry.',
            padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: roofTypes.length,
              itemBuilder: (context, index) {
                final roofType = roofTypes[index];
                return RoofTypeCard(
                  name: roofType['name'] as String,
                  description: roofType['description'] as String,
                  icon: roofType['icon'] as IconData,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DimensionInputScreen(
                          roofType: roofType['id'] as String,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: InfoPanel(
              title: 'ROOF TYPE GUIDE',
              message:
                  'Gable roofs are common for residential projects. Hip roofs use more material but handle wind well. Mono-pitch roofs are efficient for smaller structures.',
              icon: Icons.info_outline,
            ),
          ),
        ],
      ),
    );
  }
}
