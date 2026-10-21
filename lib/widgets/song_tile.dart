import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/perf_flags.dart';
import '../utils/song_extensions.dart';
import 'add_to_playlist_sheet.dart';
import 'artwork.dart';
import 'equalizer_bars.dart';
import 'listenable_selector.dart';
import 'pressable.dart';

enum _SongAction { favorite, addToPlaylist, remove }

const _kTitleStyle = TextStyle(
  fontFamily: AppFonts.body,
  fontSize: 15.5,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.15,
  color: AppColors.cream,
);
const _kTitleCurrentStyle = TextStyle(
  fontFamily: AppFonts.body,
  fontSize: 15.5,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.15,
  color: AppColors.accent,
);
const _kArtistStyle = TextStyle(
  fontFamily: AppFonts.body,
  fontSize: 12.5,
  color: AppColors.textMuted,
);
const _kDurationStyle = TextStyle(
  fontFamily: AppFonts.body,
  fontSize: 12,
  color: AppColors.textMuted,
  fontFeatures: [FontFeature.tabularFigures()],
);
const _kTilePadding = EdgeInsets.fromLTRB(0, 9, 0, 9);
const _kTileMargin = EdgeInsets.fromLTRB(20, 0, 8, 0);

Widget _tileRow({
  required Widget marker,
  required Widget cover,
  required Widget title,
  required Widget artist,
  required Widget duration,
  required Widget menu,
}) {
  return Row(
    children: [
      marker,
      const SizedBox(width: 12),
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

/// Fila de archivo: sin tarjeta. La que suena se marca con una raya de oro.
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
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final currentId = services.player.currentSongId;

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline, width: 0.6)),
      ),
      child: Pressable(
        onTap: onTap,
        scale: 0.99,
        child: ListenableSelector<bool>(
          listenable: currentId,
          selector: () => currentId.value == song.id,
          builder: (context, isCurrent, _) => Padding(
            padding: _kTileMargin,
            child: Padding(
              padding: _kTilePadding,
              child: _tileRow(
                marker: _Marker(active: isCurrent),
                cover: _Cover(
                  song: song,
                  isCurrent: isCurrent,
                  services: services,
                ),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isCurrent ? _kTitleCurrentStyle : _kTitleStyle,
                ),
                artist: Text(
                  song.artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _kArtistStyle,
                ),
                duration: Text(song.durationLabel, style: _kDurationStyle),
                menu: _Menu(
                  song: song,
                  services: services,
                  onRemove: onRemove,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SongTilePrototype extends StatelessWidget {
  const SongTilePrototype({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.transparent, width: 0.6)),
      ),
      child: Padding(
        padding: _kTileMargin,
        child: Padding(
          padding: _kTilePadding,
          child: _tileRow(
            marker: const _Marker(active: false),
            cover: const SizedBox.square(dimension: 52),
            title: const DefaultTextStyle(
              style: _kTitleStyle,
              child: Text('Ag', maxLines: 1),
            ),
            artist: const Text('Ag', maxLines: 1, style: _kArtistStyle),
            duration: const Text('0:00', style: _kDurationStyle),
            menu: const SizedBox(width: 48, height: 48),
          ),
        ),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(1),
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
    final art = Artwork.square(
      id: song.id,
      size: 52,
      radius: 10,
      pixelSize: kListArtworkPx,
      fadeIn: false,
    );

    if (!isCurrent) return art;

    return Stack(
      children: [
        art,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x990B0908),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: services.player.playing,
                  builder: (context, playing, _) =>
                      EqualizerBars(animate: playing, size: 18),
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
            if (isFavorite)
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 15,
                  color: AppColors.accentAlt,
                ),
              ),
            PopupMenuButton<_SongAction>(
              icon: const Icon(
                Icons.more_horiz_rounded,
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
                        ? 'Quitar de guardadas'
                        : 'Guardar',
                  ),
                ),
                const PopupMenuItem(
                  value: _SongAction.addToPlaylist,
                  child: _MenuRow(
                    icon: Icons.playlist_add_rounded,
                    label: 'Añadir a una lista',
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
