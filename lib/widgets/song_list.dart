import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../utils/playback_actions.dart';
import 'fade_slide_in.dart';
import 'song_tile.dart';

/// Lista de canciones para usar dentro de un CustomScrollView.
/// Al tocar una, la cola del reproductor pasa a ser esta lista.
///
/// Rendimiento:
/// - Alto de fila conocido de antemano (prototipo): menos trabajo de layout.
/// - `findChildIndexCallback`: al filtrar o reordenar, Flutter reutiliza el
///   estado de cada tile por su ID en vez de reconstruirlos.
/// - Sin KeepAlive por fila: las filas fuera de pantalla se liberan.
class SliverSongList extends StatelessWidget {
  const SliverSongList({
    super.key,
    required this.songs,
    required this.services,
    this.onRemove,
    this.scope = 'list',
  });

  final List<SongModel> songs;
  final AppServices services;
  final void Function(SongModel song)? onRemove;

  /// Identifica la lista (p. ej. 'songs') para que la animación de entrada se
  /// reproduzca una sola vez por canción y lista.
  final String scope;

  @override
  Widget build(BuildContext context) {
    return SliverPrototypeExtentList.builder(
      itemCount: songs.length,
      prototypeItem: const SongTilePrototype(),
      addAutomaticKeepAlives: false,
      findChildIndexCallback: (key) {
        if (key is ValueKey<int>) {
          final i = songs.indexWhere((s) => s.id == key.value);
          return i < 0 ? null : i;
        }
        return null;
      },
      itemBuilder: (context, i) {
        final song = songs[i];
        return FadeSlideIn(
          key: ValueKey<int>(song.id),
          index: i,
          playOnceId: '$scope:${song.id}',
          child: SongTile(
            song: song,
            services: services,
            onTap: () => playSongs(context, services, songs, i),
            onRemove: onRemove == null ? null : () => onRemove!(song),
          ),
        );
      },
    );
  }
}
