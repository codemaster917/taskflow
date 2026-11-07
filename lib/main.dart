import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/task_details_screen.dart';
import 'screens/task_form_screen.dart';
import 'theme/app_theme.dart';

// Every Flutter app starts from main().
// runApp() puts our app on the screen.
void main() {
  runApp(const TaskFlowApp());
}

// ANIMATION: how screens appear when we open them (fade + slide up).
// We use the same style on every platform.
const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
  },
);

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider makes our providers available to ALL screens.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      // Consumer rebuilds the MaterialApp when the theme changes.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'TaskFlow',
            debugShowCheckedModeBanner: false, // hides the red DEBUG banner

            // THEMES (from app_theme.dart).
            theme: AppTheme.lightTheme.copyWith(
              pageTransitionsTheme: _pageTransitions,
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              pageTransitionsTheme: _pageTransitions,
            ),
            themeMode: themeProvider.themeMode, // light or dark

            // NAMED ROUTES: the name of each screen.
            initialRoute: '/', // the first screen
            routes: {
              '/': (context) => const HomeScreen(),
              '/add': (context) => const TaskFormScreen(),
              '/edit': (context) => const TaskFormScreen(),
              '/details': (context) => const TaskDetailsScreen(),
            },
          );
        },
      ),
    );
  }
}