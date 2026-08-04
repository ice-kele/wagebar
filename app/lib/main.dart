import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: WageBarApp()));
}

class WageBarApp extends ConsumerWidget {
  const WageBarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '打工进度条',
      debugShowCheckedModeBanner: false,
      theme: WageBarTheme.light,
      darkTheme: WageBarTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
