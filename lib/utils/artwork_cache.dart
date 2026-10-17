import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

/// Caché en memoria de carátulas (bytes JPEG ya reducidos por Android).
///
/// - Evita volver a pedir la misma carátula al hacer scroll de ida y vuelta.
/// - Une peticiones idénticas (misma canción y tamaño) en una sola.
/// - Limita las peticiones simultáneas al canal nativo y atiende primero lo
///   último que apareció en pantalla (LIFO); si el tile ya salió de pantalla
///   antes de empezar, la petición se descarta.
/// - Presupuesto de memoria con expulsión de lo menos usado (LRU).
///
/// Un resultado vacío (`isEmpty`) significa "esta canción no tiene carátula".
class ArtworkCache {
  ArtworkCache._();

  static final ArtworkCache instance = ArtworkCache._();

  static const int _maxBytes = 24 * 1024 * 1024;
  static const int _maxConcurrent = 3;
  static final Uint8List _none = Uint8List(0);

  /// Tamaños que se piden al sistema. Pocos tamaños = más aciertos de caché.
  static const List<int> _buckets = [64, 128, 192, 256, 384, 512];

  /// Elige el tamaño de petición según el lado en dp y la densidad de pantalla.
  /// El plugin avisa de que más de ~200 apenas mejora y sí ralentiza, así que
  /// solo las imágenes grandes (pantalla de reproducción) suben de 384.
  static int bucketFor(double logicalSide, double devicePixelRatio) {
    final px = logicalSide * devicePixelRatio;
    for (final b in _buckets) {
      if (px <= b) return b;
    }
    return _buckets.last;
  }

  final OnAudioQuery _query = OnAudioQuery();
  final LinkedHashMap<String, Uint8List> _cache =
      LinkedHashMap<String, Uint8List>();
  final Map<String, _Job> _jobs = {};
  final List<_Job> _pending = [];
  int _bytes = 0;
  int _running = 0;

  static String _key(int id, int size) => '$id@$size';

  /// Respuesta inmediata si ya está en memoria (null = aún no se sabe).
  Uint8List? peek(int id, int size) {
    final key = _key(id, size);
    final value = _cache.remove(key);
    if (value == null) return null;
    _cache[key] = value; // pasa a ser el más reciente
    return value;
  }

  /// Pide la carátula. Cada llamada a [load] debe equilibrarse con [release]
  /// si el widget se destruye antes de recibir el resultado.
  Future<Uint8List> load(int id, int size) {
    final cached = peek(id, size);
    if (cached != null) return Future<Uint8List>.value(cached);

    final key = _key(id, size);
    var job = _jobs[key];
    if (job == null) {
      job = _Job(key, id, size);
      _jobs[key] = job;
      _pending.add(job);
    }
    job.refs++;
    _pump();
    return job.completer.future;
  }

  /// El widget que pidió [load] ya no necesita el resultado.
  void release(int id, int size) {
    final job = _jobs[_key(id, size)];
    if (job == null) return;
    job.refs--;
    if (job.refs <= 0 && !job.started) {
      _pending.remove(job);
      _jobs.remove(job.key);
    }
  }

  void clear() {
    _cache.clear();
    _bytes = 0;
  }

  /// Olvida las carátulas de canciones concretas (p. ej. tras borrarlas).
  void evictSongs(Iterable<int> ids) {
    final set = ids.toSet();
    final keys = _cache.keys
        .where((k) => set.contains(int.tryParse(k.split('@').first)))
        .toList();
    for (final k in keys) {
      _bytes -= _cache.remove(k)?.length ?? 0;
    }
  }

  void _pump() {
    while (_running < _maxConcurrent && _pending.isNotEmpty) {
      final job = _pending.removeLast();
      job.started = true;
      _running++;
      unawaited(_run(job));
    }
  }

  Future<void> _run(_Job job) async {
    var result = _none;
    try {
      final bytes = await _query.queryArtwork(
        job.id,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: job.size,
        quality: job.size >= 384 ? 85 : 75,
      );
      if (bytes != null && bytes.isNotEmpty) result = bytes;
    } catch (e) {
      debugPrint('Carátula ${job.id}: $e');
    }
    _store(job.key, result);
    _jobs.remove(job.key);
    _running--;
    job.completer.complete(result);
    _pump();
  }

  void _store(String key, Uint8List value) {
    final old = _cache.remove(key);
    if (old != null) _bytes -= old.length;
    _cache[key] = value;
    _bytes += value.length;
    while (_bytes > _maxBytes && _cache.length > 1) {
      final oldest = _cache.keys.first;
      _bytes -= _cache.remove(oldest)!.length;
    }
  }
}

class _Job {
  _Job(this.key, this.id, this.size);

  final String key;
  final int id;
  final int size;
  final Completer<Uint8List> completer = Completer<Uint8List>();
  int refs = 0;
  bool started = false;
}
