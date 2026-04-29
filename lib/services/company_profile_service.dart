import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/company_profile_model.dart';

class CompanyProfileService extends ChangeNotifier {
  static const String _boxName = 'company_profile';
  static const String _profileKey = 'profile';

  late Box _box;
  CompanyProfileModel _profile = const CompanyProfileModel();

  CompanyProfileModel get profile => _profile;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final json = _box.get(_profileKey);

    if (json is Map<dynamic, dynamic>) {
      _profile = CompanyProfileModel.fromJson(json);
    } else {
      await _box.put(_profileKey, _profile.toJson());
    }

    notifyListeners();
  }

  Future<void> saveProfile(CompanyProfileModel profile) async {
    _profile = profile;
    await _box.put(_profileKey, profile.toJson());
    notifyListeners();
  }
}
