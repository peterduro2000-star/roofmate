import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/material_model.dart';

class MaterialDatabaseService extends ChangeNotifier {
  static const String _boxName = 'materials';
  late Box _box;
  List<MaterialModel> _materials = defaultMaterials;
  bool _disposed = false;

  List<MaterialModel> get materials => List.unmodifiable(_materials);

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);

    if (_box.isEmpty) {
      for (final material in defaultMaterials) {
        await _box.put(material.id, material.toJson());
      }
    }

    _loadMaterials();
  }

  Future<void> saveMaterial(MaterialModel material) async {
    await _box.put(material.id, material.toJson());
    final index = _materials.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      _materials[index] = material;
      _materials.sort((a, b) => a.category.compareTo(b.category));
      _notifyIfActive();
    }
  }

  Future<void> resetToDefaults() async {
    await _box.clear();
    for (final material in defaultMaterials) {
      await _box.put(material.id, material.toJson());
    }
    _materials = List.from(defaultMaterials);
    _materials.sort((a, b) => a.category.compareTo(b.category));
    _notifyIfActive();
  }

  void _loadMaterials() {
    _materials = _box.values
        .whereType<Map<dynamic, dynamic>>()
        .map(MaterialModel.fromJson)
        .toList()
      ..sort((a, b) => a.category.compareTo(b.category));

    _notifyIfActive();
  }

  void _notifyIfActive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  static const defaultMaterials = [
    MaterialModel(
      id: 'longspan-sheet',
      name: 'Longspan sheet',
      category: 'Roof covering',
      unit: 'per sheet',
      unitPrice: 0,
      wastePercentage: 0.1,
    ),
    MaterialModel(
      id: 'ridge-cap',
      name: 'Ridge cap',
      category: 'Accessories',
      unit: 'per length',
      unitPrice: 0,
      wastePercentage: 0.05,
    ),
    MaterialModel(
      id: 'timber-2x3',
      name: '2x3 timber batten',
      category: 'Timber/steel frame',
      unit: 'per length',
      unitPrice: 0,
      wastePercentage: 0.08,
    ),
    MaterialModel(
      id: 'timber-2x4',
      name: '2x4 timber rafter',
      category: 'Timber/steel frame',
      unit: 'per length',
      unitPrice: 0,
      wastePercentage: 0.08,
    ),
    MaterialModel(
      id: 'roofing-screw',
      name: 'Roofing screw',
      category: 'Accessories',
      unit: 'per pack',
      unitPrice: 0,
      wastePercentage: 0.05,
    ),
    MaterialModel(
      id: 'fascia-board',
      name: 'Fascia board',
      category: 'Accessories',
      unit: 'per length',
      unitPrice: 0,
      wastePercentage: 0.05,
    ),
  ];
}
