import 'package:on_audio_query_forked/on_audio_query.dart';

extension SongModelX on SongModel {
  /// Nombre del artista, o un texto por defecto si no se conoce.
  String get artistName =>
      (artist == null || artist == '<unknown>')
          ? 'Artista desconocido'
          : artist!;

  /// Duración como "3:45".
  String get durationLabel {
    final d = Duration(milliseconds: duration ?? 0);
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${d.inMinutes}:$seconds';
  }
}
