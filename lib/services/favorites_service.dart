import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Canciones favoritas. Se guardan en el teléfono (solo los IDs).
class FavoritesService extends ChangeNotifier {
  FavoritesService(this._prefs) {
    final saved = _prefs.getStringList(_key) ?? const <String>[];
    _ids.addAll(saved.map(int.tryParse).whereType<int>());
    _lookup.addAll(_ids);
  }

  static const _key = 'favorites';

  final SharedPreferences _prefs;
  final List<int> _ids = []; // las más recientes primero
  final Set<int> _lookup = {};

  List<int> get ids => List.unmodifiable(_ids);

  bool isFavorite(int id) => _lookup.contains(id);

  void toggle(int id) {
    if (!_ids.remove(id)) {
      _ids.insert(0, id);
      _lookup.add(id);
    } else {
      _lookup.remove(id);
    }
    unawaited(
      _prefs.setStringList(_key, _ids.map((e) => e.toString()).toList()),
    );
    notifyListeners();
  }
}
