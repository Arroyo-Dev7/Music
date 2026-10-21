import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/app_services.dart';
import 'theme/app_theme.dart';
import 'utils/scroll_perf.dart';

/// Scroll con rebote suave y sin el resplandor azul por defecto de Android.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

/// Raíz de la app: tema + servicios compartidos por todas las pantallas.
class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.services});

  final AppServices services;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = buildAppTheme();
    return MaterialApp(
      title: 'Sala',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: theme,
      darkTheme: theme,
      scrollBehavior: const _AppScrollBehavior(),
      builder: (context, child) => NotificationListener<ScrollNotification>(
        onNotification: ScrollPerf.handle,
        child: child ?? const SizedBox.shrink(),
      ),
      home: HomeScreen(services: widget.services),
    );
  }
}
