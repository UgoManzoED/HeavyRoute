import 'package:flutter/material.dart';
import 'package:heavyroute_app/features/gestore/screens/account_manager_screen.dart';
import 'package:heavyroute_app/features/requests/presentation/screens/create_request_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/landing/presentation/screens/landing_page.dart';
import 'features/requests/presentation/screens/customer_dashboard_screen.dart';
import 'features/coordinator/screens/coordinator_dashboard_screen.dart';

void main() {
  runApp(const HeavyRouteApp());
}

class HeavyRouteApp extends StatelessWidget {
  const HeavyRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeavyRoute',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
      '/': (context) => const LandingPage(),
      '/login': (context) => const LoginScreen(),
      '/traffic_dashboard': (context) => const CoordinatorDashboardScreen(),
      }
    );
  }
}