import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/song_colors.dart';
import '../widgets/dock_inset.dart';
import '../widgets/listenable_selector.dart';
import '../widgets/nav_dock.dart';
import 'favorites_tab.dart';
import 'playlists_tab.dart';
import 'songs_tab.dart';

/// Estructura principal: tres páginas que se deslizan con el dedo, un fondo
/// que toma el color de la canción actual y la barra flotante abajo.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.services,
    required this.songs,
    required this.onRefresh,
  });

  final AppServices services;
  final List<SongModel> songs;
  final Future<void> Function() onRefresh;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PageController _pageController = PageController();
  final ValueNotifier<double> _position = ValueNotifier<double>(0);
  final ValueNotifier<int> _currentTab = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page != null) _position.value = page;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _position.dispose();
    _currentTab.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.services;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    final pages = PageView(
      controller: _pageController,
      onPageChanged: (index) {
        _currentTab.value = index;
        HapticFeedback.selectionClick();
      },
      children: [
        _TabPage(
          index: 0,
          current: _currentTab,
          child: SongsTab(
            services: services,
            songs: widget.songs,
            onRefresh: widget.onRefresh,
          ),
        ),
        _TabPage(
          index: 1,
          current: _currentTab,
          child: FavoritesTab(services: services),
        ),
        _TabPage(
          index: 2,
          current: _currentTab,
          child: PlaylistsTab(services: services),
        ),
      ],
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _AmbientBackdrop(services: services)),
          Positioned.fill(
            child: ListenableSelector<bool>(
              listenable: services.player.currentSongId,
              selector: () => services.player.currentSongId.value != null,
              builder: (context, hasMini, _) {
                final target =
                    safeBottom +
                    kNavBlockHeight +
                    (hasMini ? kMiniBlockHeight : 0) +
                    16;
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: target),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, inset, child) =>
                      DockInset(bottom: inset, child: child!),
                  child: pages,
                );
              },
            ),
          ),
          // Desvanece el contenido que pasa por debajo de la barra.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: safeBottom + 170,
            child: IgnorePointer(
              child: DecoratedBox(decoration: _fadeDecoration),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavDock(
              services: services,
              position: _position,
              onSelect: _goTo,
            ),
          ),
        ],
      ),
    );
  }
}

/// Degradado que oculta el contenido que pasa bajo la barra flotante.
/// Se crea una sola vez (antes se recreaba en cada reconstrucción).
final BoxDecoration _fadeDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background.withValues(alpha: 0),
      AppColors.background.withValues(alpha: 0.92),
    ],
  ),
);

/// Una pestaña: se mantiene viva (conserva scroll y búsqueda) pero sus
/// animaciones (TickerMode) solo corren mientras es la pestaña visible.
class _TabPage extends StatelessWidget {
  const _TabPage({
    required this.index,
    required this.current,
    required this.child,
  });

  final int index;
  final ValueListenable<int> current;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _KeepAlive(
      child: ValueListenableBuilder<int>(
        valueListenable: current,
        child: child,
        builder: (context, currentIndex, child) =>
            TickerMode(enabled: currentIndex == index, child: child!),
      ),
    );
  }
}

/// Mantiene viva cada página para no perder el scroll ni la búsqueda.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Resplandor de color en la parte alta que cambia con la canción actual.
class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: services.player.currentSongId,
      builder: (context, id, _) {
        final color = id == null ? AppColors.accent : ambientColors(id)[0];
        final alpha = id == null ? 0.2 : 0.4;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: alpha),
                AppColors.background,
              ],
              stops: const [0, 0.55],
            ),
          ),
        );
      },
    );
  }
}
