import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/playback_actions.dart';
import '../widgets/dock_inset.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_header.dart';
import '../widgets/play_actions_row.dart';
import '../widgets/song_list.dart';

/// Todas las canciones: encabezado, buscador y acciones rápidas.
class SongsTab extends StatefulWidget {
  const SongsTab({
    super.key,
    required this.services,
    required this.songs,
    required this.onRefresh,
  });

  final AppServices services;
  final List<SongModel> songs;
  final Future<void> Function() onRefresh;

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<SongModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.songs;
    return widget.songs.where((s) {
      return s.title.toLowerCase().contains(q) ||
          (s.artist ?? '').toLowerCase().contains(q) ||
          (s.album ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final songs = _filtered;
    final services = widget.services;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      edgeOffset: MediaQuery.paddingOf(context).top + 8,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(
              overline: 'Biblioteca',
              title: 'Tu música',
              subtitle: '${widget.songs.length} canciones',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: TextField(
                controller: _controller,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Buscar canciones, artistas o álbumes',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.07),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (songs.isNotEmpty)
            SliverToBoxAdapter(
              child: PlayActionsRow(
                onPlay: () => playSongs(context, services, songs, 0),
                onShuffle: () => shuffleSongs(context, services, songs),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          if (songs.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Sin resultados',
                subtitle: 'Prueba con otro nombre o artista.',
              ),
            )
          else
            SliverSongList(songs: songs, services: services),
          SliverToBoxAdapter(child: SizedBox(height: DockInset.of(context))),
        ],
      ),
    );
  }
}
