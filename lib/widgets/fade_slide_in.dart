import 'package:flutter/material.dart';

/// Entrada suave (aparece y sube) para los primeros elementos de una lista.
/// Cada elemento tarda un poco más que el anterior, lo que crea efecto cascada.
///
/// Rendimiento:
/// - Una sola animación por elemento; el contenido NO se reconstruye en cada
///   fotograma (solo se aplican opacidad y desplazamiento).
/// - Si se da [playOnceId], la animación se reproduce una única vez por ese
///   identificador: al volver a hacer scroll hasta arriba, los elementos
///   aparecen directos en vez de animarse otra vez mientras cargan carátulas.
/// - La estructura del árbol no cambia según el índice, así que al borrar o
///   reordenar elementos no se destruye el estado de los de abajo.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.index,
    required this.child,
    this.playOnceId,
  });

  final int index;
  final Widget child;
  final String? playOnceId;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  static const int _maxAnimatedIndex = 5;
  static final Set<String> _played = <String>{};

  AnimationController? _controller;
  Animation<double>? _curve;

  @override
  void initState() {
    super.initState();
    final id = widget.playOnceId;
    final skip = widget.index > _maxAnimatedIndex ||
        (id != null && _played.contains(id));
    if (id != null && !skip) _played.add(id);
    if (skip) return;

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 360 + widget.index * 60),
    )..forward();
    _controller = controller;
    _curve = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = _curve;
    if (curve == null) return widget.child;
    return FadeTransition(
      opacity: curve,
      child: widget.child,
    );
  }
}
