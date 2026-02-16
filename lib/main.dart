import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: TechPayApp()));
}

class TechPayApp extends StatelessWidget {
  const TechPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRouter.welcome,
      routes: AppRouter.routes,
    );
  }
}
