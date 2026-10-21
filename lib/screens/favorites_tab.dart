import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/playback_actions.dart';
import '../utils/song_extensions.dart';
import '../widgets/artwork.dart';
import '../widgets/dock_inset.dart';
import '../widgets/empty_state.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/page_header.dart';
import '../widgets/play_actions_row.dart';
import '../widgets/pressable.dart';

/// Favoritas en cuadrícula de tarjetas grandes con la carátula.
class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: services.favorites,
      builder: (context, _) {
        final songs = services.library.songsFor(services.favorites.ids);

        return CustomScrollView(
          cacheExtent: 480,
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                overline: 'Lo elegido',
                title: 'Guardadas',
                subtitle: songs.isEmpty
                    ? null
                    : '${songs.length} ${songs.length == 1 ? 'pieza' : 'piezas'}',
              ),
            ),
            if (songs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Todavía vacío',
                  subtitle:
                      'El corazón de una canción la trae a esta pared.',
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: PlayActionsRow(
                  onPlay: () => playSongs(context, services, songs, 0),
                  onShuffle: () => shuffleSongs(context, services, songs),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1,
                  ),
                  itemCount: songs.length,
                  itemBuilder: (context, i) => FadeSlideIn(
                    key: ValueKey(songs[i].id),
                    index: i,
                    playOnceId: 'favorites:${songs[i].id}',
                    child: _FavoriteCard(
                      song: songs[i],
                      services: services,
                      onTap: () => playSongs(context, services, songs, i),
                    ),
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: DockSpacer()),
          ],
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.song,
    required this.services,
    required this.onTap,
  });

  final SongModel song;
  final AppServices services;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final side = (MediaQuery.sizeOf(context).width - 46) / 2;
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Artwork(
              id: song.id,
              width: side,
              height: side,
              radius: 0,
              pixelSize: 256,
              fadeIn: false,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xD9000000)],
                  stops: [0.4, 1],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                      fontSize: 16,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  services.favorites.toggle(song.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black45,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: AppColors.accentAlt,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
