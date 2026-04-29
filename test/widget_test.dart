import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:roof_estimator/models/material_model.dart';
import 'package:roof_estimator/screens/material_database_screen.dart';
import 'package:roof_estimator/services/material_database_service.dart';
import 'package:roof_estimator/widgets/app_action_button.dart';

void main() {
  testWidgets('AppActionButton renders a professional primary action',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppActionButton(
            label: 'New Estimate',
            icon: Icons.add_circle_outline,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('New Estimate'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('MaterialDatabaseScreen saves material price without exception',
      (WidgetTester tester) async {
    final service = _FakeMaterialDatabaseService();

    await tester.pumpWidget(
      ChangeNotifierProvider<MaterialDatabaseService>.value(
        value: service,
        child: const MaterialApp(
          home: MaterialDatabaseScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Longspan sheet'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '1234');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      service.materials
          .firstWhere((material) => material.id == 'longspan-sheet')
          .unitPrice,
      1234,
    );
    expect(find.text('Material price saved'), findsOneWidget);
  });
}

class _FakeMaterialDatabaseService extends MaterialDatabaseService {
  List<MaterialModel> _materials = List<MaterialModel>.from(
    MaterialDatabaseService.defaultMaterials,
  )..sort((a, b) => a.category.compareTo(b.category));

  @override
  List<MaterialModel> get materials => List.unmodifiable(_materials);

  @override
  Future<void> saveMaterial(MaterialModel material) async {
    final index = _materials.indexWhere((item) => item.id == material.id);
    if (index != -1) {
      _materials[index] = material;
      _materials.sort((a, b) => a.category.compareTo(b.category));
      notifyListeners();
    }
  }

  @override
  Future<void> resetToDefaults() async {
    _materials = List<MaterialModel>.from(
      MaterialDatabaseService.defaultMaterials,
    )..sort((a, b) => a.category.compareTo(b.category));
    notifyListeners();
  }
}
