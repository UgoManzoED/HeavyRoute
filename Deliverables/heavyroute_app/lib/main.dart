import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Questo serve per caricare il file .env
import 'package:intl/date_symbol_data_local.dart';

// --- NESSUN IMPORT DI MAPBOX QUI ---

import 'features/landing/presentation/screens/landing_page.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/coordinator/screens/coordinator_dashboard_screen.dart';
import 'features/gestore/screens/account_manager_screen.dart';
import 'features/planner/presentation/screens/planner_dashboard_screen.dart';
import 'features/requests/presentation/screens/customer_dashboard_screen.dart';
import 'core/theme/app_theme.dart';
// import 'core/navigation/auth_guard.dart'; // Scommenta se usi il guardiano

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Carichiamo le chiavi (serve per dopo)
  await dotenv.load(fileName: "chiavi.env");

  // --- NESSUNA CONFIGURAZIONE MAPBOX QUI ---

  await initializeDateFormatting('it_IT', null);

  runApp(const HeavyRouteApp());
}

class HeavyRouteApp extends StatelessWidget {
  const HeavyRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeavyRoute',
      debugShowCheckedModeBanner: false,

      // Configurazioni tema (No Swipe)
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginScreen(),
        '/traffic_dashboard': (context) => const CoordinatorDashboardScreen(),
        '/account_manager': (context) => const AccountManagerScreen(),
        '/planner_dashboard': (context) => const PlannerDashboardScreen(),
        '/customer_dashboard': (context) => const CustomerDashboardScreen(),
      },
    );
  }
}