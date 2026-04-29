import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/estimate_model.dart';
import 'services/app_settings_service.dart';
import 'services/estimate_service.dart';
import 'services/company_profile_service.dart';
import 'services/material_database_service.dart';
import 'services/project_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with error handling
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(EstimateAdapter());
  } catch (e) {
    debugPrint('Hive initialization error: $e');
  }

  runApp(const RoofEstimatorApp());
}

class RoofEstimatorApp extends StatelessWidget {
  const RoofEstimatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstimateService()),
        ChangeNotifierProvider(create: (_) => AppSettingsService()),
        ChangeNotifierProvider(create: (_) => ProjectService()),
        ChangeNotifierProvider(create: (_) => MaterialDatabaseService()),
        ChangeNotifierProvider(create: (_) => CompanyProfileService()),
      ],
      child: MaterialApp(
        title: 'RoofMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E40AF), // Deep Blue
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E40AF),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E40AF), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E40AF),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F172A),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
