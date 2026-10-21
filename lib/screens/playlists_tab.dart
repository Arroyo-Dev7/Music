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
                title: 'Listas',
                subtitle: playlists.isEmpty
                    ? 'Arma tus propios programas'
                    : '${playlists.length} ${playlists.length == 1 ? 'lista' : 'listas'}',
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
                      playOnceId: 'playlists:new',
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
                    playOnceId: 'playlists:${playlist.id}',
                    child: _PlaylistCard(
                      playlist: playlist,
                      services: services,
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: DockSpacer()),
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
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: AppColors.accent, size: 32),
            SizedBox(height: 12),
            Text(
              'Nueva lista',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.cream,
              ),
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
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: AppColors.cream,
            ),
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
