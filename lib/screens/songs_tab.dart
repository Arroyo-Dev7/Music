import 'dart:async';

import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/artwork_cache.dart';
import '../utils/perf_flags.dart';
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
  Timer? _debounce;
  String _query = '';
  bool _hasText = false;

  // Memoria del último filtrado: build() puede ejecutarse muchas veces
  // (refresco, cambios de tema...) sin que cambie ni la lista ni la búsqueda.
  List<SongModel>? _filteredFor;
  String? _filteredQuery;
  List<SongModel> _filteredResult = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheVisible());
  }

  @override
  void didUpdateWidget(SongsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.songs, widget.songs)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _precacheVisible());
    }
  }

  void _precacheVisible() {
    if (!mounted) return;
    ArtworkCache.instance.prefetch(
      widget.songs.take(36).map((s) => s.id),
      kListArtworkPx,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final hasText = value.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    // Espera a que el usuario deje de teclear: evita refiltrar y reconstruir
    // la lista en cada letra.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _query = '';
      _hasText = false;
    });
  }

  List<SongModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (identical(_filteredFor, widget.songs) && _filteredQuery == q) {
      return _filteredResult;
    }
    final result = q.isEmpty
        ? widget.songs
        : widget.songs.where((s) {
            return s.title.toLowerCase().contains(q) ||
                (s.artist ?? '').toLowerCase().contains(q) ||
                (s.album ?? '').toLowerCase().contains(q);
          }).toList();
    _filteredFor = widget.songs;
    _filteredQuery = q;
    _filteredResult = result;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final songs = _filtered;
    final services = widget.services;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      edgeOffset: MediaQuery.paddingOf(context).top + 8,
      child: CustomScrollView(
        cacheExtent: 720,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(
              overline: 'Archivo sonoro',
              title: 'Tu música',
              subtitle: '${widget.songs.length} piezas en el disco',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 15, fontFamily: AppFonts.body),
                decoration: InputDecoration(
                  hintText: 'Busca título, voz o disco',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: _hasText
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clear,
                        )
                      : null,
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
                title: 'Nada con ese nombre',
                subtitle: 'Prueba con otra voz, un disco o solo unas letras.',
              ),
            )
          else
            SliverSongList(songs: songs, services: services, scope: 'songs'),
          const SliverToBoxAdapter(child: DockSpacer()),
        ],
      ),
    );
  }
}
