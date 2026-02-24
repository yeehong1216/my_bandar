import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/submit_complaint_screen.dart';
import 'screens/verify_report_screen.dart';
import 'screens/track_reports_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyBandarApp(),
    ),
  );
}

class MyBandarApp extends StatelessWidget {
  const MyBandarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyBandar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/submit': (context) => const SubmitComplaintScreen(),
        '/verify': (context) => const VerifyReportScreen(),
        '/track': (context) => const TrackReportsScreen(),
      },
    );
  }
}
