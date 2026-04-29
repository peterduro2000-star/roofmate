import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/project_model.dart';

class ProjectService extends ChangeNotifier {
  static const String _boxName = 'projects';
  late Box _box;
  List<ProjectModel> _projects = [];
  bool _isInitialized = false;

  List<ProjectModel> get projects => List.unmodifiable(_projects);
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _isInitialized = true;
    _loadProjects();
  }

  Future<void> saveProject(ProjectModel project) async {
    await _box.put(project.id, project.toJson());
    _loadProjects();
  }

  Future<ProjectModel> duplicateProject(ProjectModel project) async {
    final now = DateTime.now();
    final copy = project.copyWith(
      id: now.microsecondsSinceEpoch.toString(),
      name: '${project.name} Copy',
      createdAt: now,
      updatedAt: now,
    );

    await saveProject(copy);
    return copy;
  }

  Future<void> deleteProject(String id) async {
    await _box.delete(id);
    _loadProjects();
  }

  Future<File> exportProjectsJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/roof-projects-backup-$timestamp.json');
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': 1,
      'projects': _projects.map((project) => project.toJson()).toList(),
    };

    return file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
  }

  ProjectModel? getProject(String id) {
    final json = _box.get(id);
    if (json is Map<dynamic, dynamic>) {
      return ProjectModel.fromJson(json);
    }
    return null;
  }

  List<ProjectModel> getRecentProjects({int limit = 5}) {
    return _projects.take(limit).toList();
  }

  void _loadProjects() {
    _projects = _box.values
        .whereType<Map<dynamic, dynamic>>()
        .map(ProjectModel.fromJson)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    notifyListeners();
  }
}
