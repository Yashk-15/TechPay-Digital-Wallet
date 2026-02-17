import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: TechPayApp()));
}

class TechPayApp extends ConsumerWidget {
  const TechPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'TechPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRouter.welcome,
      routes: AppRouter.routes,
    );
  }
}
