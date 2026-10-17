import 'package:on_audio_query_forked/on_audio_query.dart';

enum LibraryStatus { loading, denied, permanentlyDenied, empty, error, ready }

/// Resultado de intentar leer la biblioteca de música del dispositivo.
class LibraryResult {
  const LibraryResult(this.status, [this.songs = const []]);

  final LibraryStatus status;
  final List<SongModel> songs;
}
