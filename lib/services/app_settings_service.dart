import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings_model.dart';

class AppSettingsService extends ChangeNotifier {
  static const String _boxName = 'app_settings';
  static const String _settingsKey = 'settings';

  late Box _box;
  AppSettingsModel _settings = const AppSettingsModel();
  bool _isInitialized = false;

  AppSettingsModel get settings => _settings;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final json = _box.get(_settingsKey);

    if (json is Map<dynamic, dynamic>) {
      _settings = AppSettingsModel.fromJson(json);
    } else {
      await _box.put(_settingsKey, _settings.toJson());
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    _settings = settings;
    await _box.put(_settingsKey, settings.toJson());
    notifyListeners();
  }
}
