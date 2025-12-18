import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/message_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'views/onboarding_flow.dart';
import 'views/main_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TutorBotApp());
}

class TutorBotApp extends StatelessWidget {
  const TutorBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tutor Anna',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ProfileProvider>().loadProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final hasProfile = context.watch<ProfileProvider>().profile != null;

        return hasProfile ? const MainInterface() : const OnboardingFlow();
      },
    );
  }
}