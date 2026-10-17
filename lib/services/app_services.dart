import 'package:shared_preferences/shared_preferences.dart';

import 'favorites_service.dart';
import 'library_service.dart';
import 'player_service.dart';
import 'playlist_service.dart';

/// Agrupa todos los servicios para pasarlos juntos a las pantallas.
class AppServices {
  AppServices._({
    required this.library,
    required this.player,
    required this.favorites,
    required this.playlists,
  });

  final LibraryService library;
  final PlayerService player;
  final FavoritesService favorites;
  final PlaylistService playlists;

  static Future<AppServices> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppServices._(
      library: LibraryService(),
      player: PlayerService(),
      favorites: FavoritesService(prefs),
      playlists: PlaylistService(prefs),
    );
  }

  void dispose() {
    player.dispose();
    favorites.dispose();
    playlists.dispose();
  }
}
