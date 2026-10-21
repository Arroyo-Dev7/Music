import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/artwork_cache.dart';
import '../utils/scroll_perf.dart';
import '../utils/song_colors.dart';

/// Carátula de una canción. Si no tiene, muestra un degradado único por canción.
///
/// Usa [ArtworkCache]: si la imagen ya está en memoria aparece en el mismo
/// fotograma (sin parpadeo al volver a hacer scroll); si no, se pide en
/// segundo plano y, si hay scroll, se pinta al soltar el dedo para no cortar
/// el deslizamiento.
class Artwork extends StatefulWidget {
  const Artwork({
    super.key,
    required this.id,
    required this.width,
    required this.height,
    this.radius = 14,
    this.pixelSize,
    this.filterQuality = FilterQuality.low,
    this.showPlaceholder = true,
    this.fadeIn = true,
  });

  const Artwork.square({
    super.key,
    required this.id,
    required double size,
    this.radius = 14,
    this.pixelSize,
    this.filterQuality = FilterQuality.low,
    this.showPlaceholder = true,
    this.fadeIn = true,
  }) : width = size,
       height = size;

  /// Para fondos decorativos: imagen diminuta ampliada con filtro bicúbico
  /// (efecto "desenfoque barato"), sin icono ni marcador si no hay carátula.
  const Artwork.ambient({
    super.key,
    required this.id,
    required this.width,
    required this.height,
  }) : radius = 0,
       pixelSize = 64,
       filterQuality = FilterQuality.low,
       showPlaceholder = false,
       fadeIn = false;

  final int id;
  final double width;
  final double height;
  final double radius;

  /// Tamaño (px) con el que se pide la imagen. Si es null se calcula solo a
  /// partir del tamaño en pantalla y la densidad del dispositivo.
  final int? pixelSize;

  final FilterQuality filterQuality;
  final bool showPlaceholder;
  final bool fadeIn;

  @override
  State<Artwork> createState() => _ArtworkState();

  /// Precarga la versión 'ambient' (pequeña) de la carátula para evitar que la
  /// primera aparición decodifique en el hilo de UI.
  static Future<void> precacheAmbient(
    BuildContext context,
    int id, {
    int pixelSize = 64,
  }) async {
    try {
      final bytes = await ArtworkCache.instance.load(id, pixelSize);
      if (bytes.isNotEmpty) {
        final provider = MemoryImage(bytes);
        await precacheImage(provider, context);
      }
    } catch (_) {
      // No bloquear si falla el prefetch.
    }
  }
}

class _ArtworkState extends State<Artwork> {
  Uint8List? _bytes; // null = aún cargando; vacío = sin carátula
  MemoryImage? _provider;
  int _boundId = -1;
  int _size = 0;
  bool _waiting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(Artwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resolve();
  }

  @override
  void dispose() {
    _cancelPending();
    super.dispose();
  }

  void _cancelPending() {
    if (_waiting) {
      ArtworkCache.instance.release(_boundId, _size);
      _waiting = false;
    }
  }

  void _applyBytes(Uint8List bytes) {
    _bytes = bytes;
    _provider = bytes.isEmpty ? null : MemoryImage(bytes);
  }

  void _resolve() {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final size =
        widget.pixelSize ??
        ArtworkCache.bucketFor(math.max(widget.width, widget.height), dpr);
    if (size == _size && widget.id == _boundId) return;

    _cancelPending();
    final id = widget.id;
    _boundId = id;
    _size = size;

    final hit = ArtworkCache.instance.peek(id, size);
    if (hit != null) {
      _applyBytes(hit);
      return;
    }

    _bytes = null;
    _provider = null;
    _waiting = true;
    ArtworkCache.instance.load(id, size).then((bytes) {
      if (!mounted || _boundId != id || _size != size) return;
      void apply() {
        if (!mounted || _boundId != id || _size != size) return;
        setState(() {
          _applyBytes(bytes);
          _waiting = false;
        });
      }

      // Las que ya estaban en caché se pintan al instante; las nuevas esperan
      // a que el dedo deje de deslizar para no competir con el scroll.
      ScrollPerf.runWhenIdle(apply);
    });
  }

  Widget _placeholder() {
    if (!widget.showPlaceholder) return const SizedBox.expand();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ambientColors(widget.id),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white54,
          size: math.min(widget.width, widget.height) * 0.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final provider = _provider;
    final bytes = _bytes;

    final Widget content;
    if (provider != null) {
      content = Image(
        image: provider,
        width: w.width,
        height: w.height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: w.filterQuality,
        isAntiAlias: false,
        excludeFromSemantics: true,
        frameBuilder: w.fadeIn
            ? (context, image, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return image;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _placeholder(),
                    AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: image,
                    ),
                  ],
                );
              }
            : null,
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    } else if (bytes != null && bytes.isEmpty) {
      content = _placeholder();
    } else {
      content = _placeholder();
    }

    final sized = SizedBox(width: w.width, height: w.height, child: content);
    return RepaintBoundary(
      child: w.radius > 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(w.radius),
              clipBehavior: Clip.hardEdge,
              child: sized,
            )
          : sized,
    );
  }
}
