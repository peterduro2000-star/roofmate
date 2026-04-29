import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/estimate_model.dart';

class EstimateService extends ChangeNotifier {
  static const String _boxName = 'estimates';
  late Box<Estimate> _box;
  List<Estimate> _estimates = [];

  List<Estimate> get estimates => _estimates;

  Future<void> init() async {
    _box = await Hive.openBox<Estimate>(_boxName);
    _loadEstimates();
  }

  void _loadEstimates() {
    _estimates = _box.values.toList();
    _estimates.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> saveEstimate(Estimate estimate) async {
    await _box.put(estimate.id, estimate);
    _loadEstimates();
  }

  Future<void> deleteEstimate(String id) async {
    await _box.delete(id);
    _loadEstimates();
  }

  Future<void> clearAllEstimates() async {
    await _box.clear();
    _loadEstimates();
  }

  Estimate? getEstimate(String id) {
    return _box.get(id);
  }

  List<Estimate> getRecentEstimates({int limit = 3}) {
    return _estimates.take(limit).toList();
  }
}
