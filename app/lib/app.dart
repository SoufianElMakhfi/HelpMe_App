import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/screens/role_selection_screen.dart';

class HelpMeApp extends StatelessWidget {
  const HelpMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RoleSelectionScreen(),
    );
  }
}
