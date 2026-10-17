import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/song_extensions.dart';
import 'add_to_playlist_sheet.dart';
import 'artwork.dart';
import 'equalizer_bars.dart';
import 'listenable_selector.dart';
import 'pressable.dart';

enum _SongAction { favorite, addToPlaylist, remove }

const _kTitleStyle = TextStyle(
  fontSize: 15.5,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.1,
);
const _kArtistStyle = TextStyle(fontSize: 13, color: AppColors.textMuted);
const _kDurationStyle = TextStyle(
  fontSize: 12,
  color: AppColors.textMuted,
  fontFeatures: [FontFeature.tabularFigures()],
);
const _kTilePadding = EdgeInsets.fromLTRB(10, 10, 2, 10);
const _kTileMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

/// Fila interior de la tarjeta. La comparten [SongTile] y [SongTilePrototype]
/// para que ambos midan exactamente lo mismo (incluso con texto grande).
Widget _tileRow({
  required Widget cover,
  required Widget title,
  required Widget artist,
  required Widget duration,
  required Widget menu,
}) {
  return Row(
    children: [
      cover,
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [title, const SizedBox(height: 3), artist],
        ),
      ),
      const SizedBox(width: 8),
      duration,
      menu,
    ],
  );
}

/// Tarjeta de canción. La que está sonando se resalta con barras animadas.
///
/// Rendimiento: ya no abre un StreamBuilder por tile. Escucha el notificador
/// central del reproductor mediante [ListenableSelector], que solo reconstruye
/// el tile cuando cambia su propio "¿soy la que suena?".
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.services,
    required this.onTap,
    this.onRemove,
  });

  final SongModel song;
  final AppServices services;
  final VoidCallback onTap;

  /// Si se pasa, el menú muestra "Quitar de esta lista".
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final currentId = services.player.currentSongId;

    return Padding(
      padding: _kTileMargin,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: ListenableSelector<bool>(
          listenable: currentId,
          selector: () => currentId.value == song.id,
          builder: (context, isCurrent, _) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: _kTilePadding,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.accent.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrent
                    ? AppColors.accent.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: _tileRow(
              cover: _Cover(song: song, isCurrent: isCurrent, services: services),
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: _kTitleStyle.copyWith(
                  color: isCurrent ? AppColors.accent : Colors.white,
                ),
                child: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              artist: Text(
                song.artistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _kArtistStyle,
              ),
              duration: Text(song.durationLabel, style: _kDurationStyle),
              menu: _Menu(song: song, services: services, onRemove: onRemove),
            ),
          ),
        ),
      ),
    );
  }
}

/// Molde sin datos con la misma estructura que [SongTile]. Lo usa la lista
/// (SliverPrototypeExtentList) para conocer el alto de todas las filas sin
/// medirlas una a una.
class SongTilePrototype extends StatelessWidget {
  const SongTilePrototype({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _kTileMargin,
      child: Container(
        padding: _kTilePadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.transparent),
        ),
        child: _tileRow(
          cover: const SizedBox.square(dimension: 56),
          title: const DefaultTextStyle(
            style: _kTitleStyle,
            child: Text('Ag', maxLines: 1),
          ),
          artist: const Text('Ag', maxLines: 1, style: _kArtistStyle),
          duration: const Text('0:00', style: _kDurationStyle),
          menu: const SizedBox(width: 48, height: 48),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({
    required this.song,
    required this.isCurrent,
    required this.services,
  });

  final SongModel song;
  final bool isCurrent;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Artwork.square(id: song.id, size: 56, radius: 14),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: isCurrent ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  // Solo la tile actual se suscribe a "reproduciendo".
                  child: isCurrent
                      ? ValueListenableBuilder<bool>(
                          valueListenable: services.player.playing,
                          builder: (context, playing, _) =>
                              EqualizerBars(animate: playing, size: 22),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.song,
    required this.services,
    required this.onRemove,
  });

  final SongModel song;
  final AppServices services;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ListenableSelector<bool>(
      listenable: services.favorites,
      selector: () => services.favorites.isFavorite(song.id),
      builder: (context, isFavorite, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: isFavorite
                  ? const Padding(
                      key: ValueKey('fav'),
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 18,
                        color: AppColors.accentAlt,
                      ),
                    )
                  : const SizedBox(key: ValueKey('nofav')),
            ),
            PopupMenuButton<_SongAction>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textMuted,
              ),
              onSelected: (action) {
                switch (action) {
                  case _SongAction.favorite:
                    HapticFeedback.mediumImpact();
                    services.favorites.toggle(song.id);
                  case _SongAction.addToPlaylist:
                    showAddToPlaylistSheet(context, services, song.id);
                  case _SongAction.remove:
                    onRemove?.call();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _SongAction.favorite,
                  child: _MenuRow(
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: isFavorite
                        ? 'Quitar de favoritas'
                        : 'Marcar como favorita',
                  ),
                ),
                const PopupMenuItem(
                  value: _SongAction.addToPlaylist,
                  child: _MenuRow(
                    icon: Icons.playlist_add_rounded,
                    label: 'Agregar a una lista',
                  ),
                ),
                if (onRemove != null)
                  const PopupMenuItem(
                    value: _SongAction.remove,
                    child: _MenuRow(
                      icon: Icons.remove_circle_outline_rounded,
                      label: 'Quitar de esta lista',
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
