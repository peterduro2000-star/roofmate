import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/demo_project.dart';
import '../models/project_model.dart';
import '../services/app_settings_service.dart';
import '../services/company_profile_service.dart';
import '../services/estimate_service.dart';
import '../services/material_database_service.dart';
import '../services/project_service.dart';
import '../widgets/app_action_button.dart';
import '../widgets/estimate_list_tile.dart';
import '../widgets/info_panel.dart';
import 'estimate_detail_screen.dart';
import 'app_settings_screen.dart';
import 'company_profile_screen.dart';
import 'dimension_input_screen.dart';
import 'material_database_screen.dart';
import 'results_screen.dart';
import 'roof_type_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Initialize services with error handling
      try {
        context.read<EstimateService>().init();
        context.read<AppSettingsService>().init();
        context.read<ProjectService>().init();
        context.read<MaterialDatabaseService>().init();
        context.read<CompanyProfileService>().init();
      } catch (e) {
        debugPrint('Service initialization error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E40AF),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('RoofMate'),
              background: Container(
                color: const Color(0xFF1E40AF),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(24, 72, 24, 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RoofMate',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Fast, clean material estimates for field-ready roofing decisions.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppActionButton(
                    label: 'New Estimate',
                    icon: Icons.add_circle_outline,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoofTypeScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Open Demo Project',
                    icon: Icons.play_circle_outline,
                    outlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultsScreen(
                            project: DemoProject.sample(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Material Price List',
                    icon: Icons.inventory_2_outlined,
                    outlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MaterialDatabaseScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Company Profile',
                    icon: Icons.business_outlined,
                    outlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompanyProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'App Settings',
                    icon: Icons.settings_outlined,
                    outlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Consumer<ProjectService>(
                    builder: (context, service, _) {
                      if (!service.isInitialized) {
                        return const _LoadingPanel(
                          message: 'Loading saved projects...',
                        );
                      }
                      final projects = service.getRecentProjects();
                      if (projects.isEmpty) {
                        return const _EmptyProjects();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved Projects',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...projects.map(
                            (project) => _ProjectListCard(
                              project: project,
                              onOpen: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ResultsScreen(project: project),
                                  ),
                                );
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DimensionInputScreen(
                                      roofType: project.roofType,
                                      project: project,
                                    ),
                                  ),
                                );
                              },
                              onDuplicate: () async {
                                final copy =
                                    await service.duplicateProject(project);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${copy.name} duplicated'),
                                  ),
                                );
                              },
                              onDelete: () async {
                                final shouldDelete =
                                    await _confirmProjectDelete(
                                  context,
                                  project.name,
                                );
                                if (shouldDelete != true) return;
                                await service.deleteProject(project.id);
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                  Consumer<EstimateService>(
                    builder: (context, service, _) {
                      final recentEstimates = service.getRecentEstimates();

                      if (recentEstimates.isEmpty) {
                        return const _EmptyEstimates();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Legacy Estimates',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final shouldClear =
                                      await _confirmLegacyClear(context);
                                  if (shouldClear == true) {
                                    await service.clearAllEstimates();
                                  }
                                },
                                icon: const Icon(Icons.delete_sweep_outlined),
                                label: const Text('Clear'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentEstimates.length,
                            itemBuilder: (context, index) {
                              final estimate = recentEstimates[index];
                              return EstimateListTile(
                                estimate: estimate,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EstimateDetailScreen(
                                        estimate: estimate,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const InfoPanel(
                    title: 'QUICK TIP',
                    message:
                        'Measure building length, span, roof pitch, and overhang before starting an estimate for cleaner results.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _confirmProjectDelete(BuildContext context, String projectName) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Project?'),
      content: Text(
        'Delete "$projectName"? This removes the saved project only. Old estimates are not affected.',
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
}

Future<bool?> _confirmLegacyClear(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear Legacy Estimates?'),
      content: const Text(
        'This removes all old saved estimates. New project records are not affected.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Clear'),
        ),
      ],
    ),
  );
}

class _ProjectListCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final Future<void> Function() onDuplicate;
  final Future<void> Function() onDelete;

  const _ProjectListCard({
    required this.project,
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.business_center),
        title: Text(project.name),
        subtitle: Text(
          '${project.roofSections.length} sections | ${project.updatedAt.toLocal().toString().split(' ')[0]}',
        ),
        trailing: PopupMenuButton<_ProjectAction>(
          tooltip: 'Project actions',
          onSelected: (action) {
            switch (action) {
              case _ProjectAction.open:
                onOpen();
              case _ProjectAction.edit:
                onEdit();
              case _ProjectAction.duplicate:
                onDuplicate();
              case _ProjectAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _ProjectAction.open,
              child: ListTile(
                leading: Icon(Icons.visibility_outlined),
                title: Text('Open'),
              ),
            ),
            PopupMenuItem(
              value: _ProjectAction.edit,
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
              ),
            ),
            PopupMenuItem(
              value: _ProjectAction.duplicate,
              child: ListTile(
                leading: Icon(Icons.copy_outlined),
                title: Text('Duplicate'),
              ),
            ),
            PopupMenuItem(
              value: _ProjectAction.delete,
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Delete'),
              ),
            ),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}

enum _ProjectAction {
  open,
  edit,
  duplicate,
  delete,
}

class _EmptyEstimates extends StatelessWidget {
  const _EmptyEstimates();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 36),
        Icon(
          Icons.description_outlined,
          size: 56,
          color: Color(0xFF94A3B8),
        ),
        SizedBox(height: 16),
        Text(
          'No Estimates Yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Create an estimate to calculate and save your roofing materials.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        SizedBox(height: 36),
      ],
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: InfoPanel(
        title: 'NO SAVED PROJECTS',
        message:
            'Create a new estimate or open the demo project to see how full roofing projects are saved.',
        icon: Icons.folder_open_outlined,
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  final String message;

  const _LoadingPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
