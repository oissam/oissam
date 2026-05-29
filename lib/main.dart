import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/data_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://suxiiyszutxrhbhwrjjw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1eGlpeXN6dXR4cmhiaHdyamp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwMTMwMzYsImV4cCI6MjA5NTU4OTAzNn0.aud6oGlo0ArTdQfCGOyKltwsPftR0d2TQ2zLpdxQ3MU',
    realtimeClientOptions: RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
      eventsPerSecond: 10,
    ),
  );

  // Init streams — this awaits the first data batch from each table
  await DataService.init();

  runApp(InternalExamPlannerApp());
}

class InternalExamPlannerApp extends StatefulWidget {
  InternalExamPlannerApp({super.key});

  @override
  State<InternalExamPlannerApp> createState() =>
      _InternalExamPlannerAppState();
}

class _InternalExamPlannerAppState extends State<InternalExamPlannerApp> {
  UserRole? _currentRole;

  void _handleLogin(UserRole role) {
    setState(() => _currentRole = role);
  }

  void _handleLogout() {
    setState(() => _currentRole = null);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Internal Exam Planner',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    if (_currentRole == null) {
      return LoginScreen(onLogin: _handleLogin);
    }
    if (_currentRole == UserRole.callCenter) {
      return CallCenterShell(onLogout: _handleLogout);
    }
    return ExaminatorShell(onLogout: _handleLogout);
  }
}


