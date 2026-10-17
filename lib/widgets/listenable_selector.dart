import 'package:flutter/widgets.dart';

/// Escucha un [Listenable] pero solo reconstruye cuando cambia el valor que
/// devuelve [selector].
///
/// Ejemplo: 200 SongTile escuchan "qué canción suena"; al cambiar de canción
/// solo se reconstruyen las dos cuyo "¿soy la actual?" cambió (la que dejó de
/// sonar y la nueva), no las 200.
class ListenableSelector<T> extends StatefulWidget {
  const ListenableSelector({
    super.key,
    required this.listenable,
    required this.selector,
    required this.builder,
    this.child,
  });

  final Listenable listenable;
  final T Function() selector;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  @override
  State<ListenableSelector<T>> createState() => _ListenableSelectorState<T>();
}

class _ListenableSelectorState<T> extends State<ListenableSelector<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.selector();
    widget.listenable.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(ListenableSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onChanged);
      widget.listenable.addListener(_onChanged);
    }
    _value = widget.selector();
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final next = widget.selector();
    if (next != _value) setState(() => _value = next);
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value, widget.child);
}
