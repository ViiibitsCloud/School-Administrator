import 'package:flutter/material.dart';
import 'package:school_admin/screens/login_screen.dart';
import 'package:school_admin/screens/dashboard_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
  };
}