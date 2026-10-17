import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/song_extensions.dart';
import 'add_to_playlist_sheet.dart';
import 'artwork.dart';
import 'equalizer_bars.dart';
import 'pressable.dart';

enum _SongAction { favorite, addToPlaylist, remove }

/// Tarjeta de canción. La que está sonando se resalta con barras animadas.
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
    return StreamBuilder<int?>(
      stream: services.player.currentSongIdStream,
      builder: (context, snapshot) {
        final isCurrent = snapshot.data == song.id;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Pressable(
            onTap: onTap,
            scale: 0.98,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.fromLTRB(10, 10, 2, 10),
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
              child: Row(
                children: [
                  _Cover(song: song, isCurrent: isCurrent, services: services),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                            color: isCurrent ? AppColors.accent : Colors.white,
                          ),
                          child: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          song.artistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    song.durationLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  _Menu(song: song, services: services, onRemove: onRemove),
                ],
              ),
            ),
          ),
        );
      },
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
                  child: StreamBuilder<bool>(
                    stream: services.player.playingStream,
                    initialData: false,
                    builder: (context, snap) => EqualizerBars(
                      animate: isCurrent && (snap.data ?? false),
                      size: 22,
                    ),
                  ),
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
    return ListenableBuilder(
      listenable: services.favorites,
      builder: (context, _) {
        final isFavorite = services.favorites.isFavorite(song.id);
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
