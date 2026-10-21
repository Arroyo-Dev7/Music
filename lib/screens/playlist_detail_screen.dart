import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/playback_actions.dart';
import '../widgets/empty_state.dart';
import '../widgets/mini_player.dart';
import '../widgets/name_dialog.dart';
import '../widgets/play_actions_row.dart';
import '../widgets/playlist_mosaic.dart';
import '../widgets/song_list.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({
    super.key,
    required this.services,
    required this.playlistId,
  });

  final AppServices services;
  final String playlistId;

  Future<void> _onMenu(
    BuildContext context,
    String action,
    Playlist playlist,
  ) async {
    if (action == 'rename') {
      final name = await promptForName(
        context,
        title: 'Renombrar lista',
        initial: playlist.name,
      );
      if (name != null) services.playlists.rename(playlist.id, name);
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('¿Eliminar "${playlist.name}"?'),
          content: const Text('Las canciones no se borran del teléfono.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        services.playlists.delete(playlist.id);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: services.playlists,
      builder: (context, _) {
        final playlist = services.playlists.byId(playlistId);
        if (playlist == null) return const Scaffold(); // ya se eliminó

        final songs = services.library.songsFor(playlist.songIds);

        return Scaffold(
          appBar: AppBar(
            actions: [
              PopupMenuButton<String>(
                onSelected: (action) => _onMenu(context, action, playlist),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 20),
                        SizedBox(width: 12),
                        Text('Renombrar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 20),
                        SizedBox(width: 12),
                        Text('Eliminar lista'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(child: MiniPlayer(services: services)),
          body: CustomScrollView(
            cacheExtent: 720,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: PlaylistMosaic(songs: songs, radius: 28),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        playlist.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w600,
                          fontSize: 32,
                          height: 1.1,
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${songs.length} canciones',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 18),
                    if (songs.isNotEmpty)
                      PlayActionsRow(
                        onPlay: () => playSongs(context, services, songs, 0),
                        onShuffle: () => shuffleSongs(context, services, songs),
                      ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              if (songs.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.queue_music_rounded,
                    title: 'Esta lista espera',
                    subtitle: 'Desde el menú de una canción puedes traerla aquí.',
                  ),
                )
              else
                SliverSongList(
                  songs: songs,
                  services: services,
                  scope: 'playlist:${playlist.id}',
                  onRemove: (song) =>
                      services.playlists.removeSong(playlist.id, song.id),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        );
      },
    );
  }
}
