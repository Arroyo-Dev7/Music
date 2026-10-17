import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/dock_inset.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/name_dialog.dart';
import '../widgets/page_header.dart';
import '../widgets/playlist_mosaic.dart';
import '../widgets/pressable.dart';
import 'playlist_detail_screen.dart';

/// Listas en cuadrícula, cada una con su mosaico de carátulas.
class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: services.playlists,
      builder: (context, _) {
        final playlists = services.playlists.playlists;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                overline: 'Colección',
                title: 'Tus listas',
                subtitle: playlists.isEmpty
                    ? 'Organiza tu música como quieras'
                    : '${playlists.length} listas',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: playlists.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return FadeSlideIn(
                      index: 0,
                      child: _NewPlaylistCard(
                        onTap: () async {
                          final name = await promptForName(
                            context,
                            title: 'Nueva lista',
                          );
                          if (name != null) services.playlists.create(name);
                        },
                      ),
                    );
                  }
                  final playlist = playlists[i - 1];
                  return FadeSlideIn(
                    key: ValueKey(playlist.id),
                    index: i,
                    child: _PlaylistCard(
                      playlist: playlist,
                      services: services,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: DockInset.of(context)),
            ),
          ],
        );
      },
    );
  }
}

class _NewPlaylistCard extends StatelessWidget {
  const _NewPlaylistCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nueva lista',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist, required this.services});

  final Playlist playlist;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final songs = services.library.songsFor(playlist.songIds);

    return Pressable(
      scale: 0.96,
      onTap: () => Navigator.of(context).push(
        fadeScaleRoute(
          (_) => PlaylistDetailScreen(
            services: services,
            playlistId: playlist.id,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: PlaylistMosaic(songs: songs)),
          const SizedBox(height: 10),
          Text(
            playlist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            '${songs.length} canciones',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
