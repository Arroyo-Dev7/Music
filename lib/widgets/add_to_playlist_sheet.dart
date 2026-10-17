import 'package:flutter/material.dart';

import '../services/app_services.dart';
import 'name_dialog.dart';

/// Hoja inferior para elegir a qué lista agregar una canción (o crear una).
Future<void> showAddToPlaylistSheet(
  BuildContext context,
  AppServices services,
  int songId,
) {
  final messenger = ScaffoldMessenger.of(context);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => ListenableBuilder(
      listenable: services.playlists,
      builder: (context, _) {
        final playlists = services.playlists.playlists;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Nueva lista'),
                onTap: () async {
                  final name = await promptForName(
                    sheetContext,
                    title: 'Nueva lista',
                  );
                  if (name == null) return;
                  final playlist = services.playlists.create(name);
                  services.playlists.addSong(playlist.id, songId);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Agregada a "${playlist.name}"')),
                  );
                },
              ),
              for (final playlist in playlists)
                ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(playlist.name),
                  subtitle: Text(
                    '${services.library.songsFor(playlist.songIds).length} canciones',
                  ),
                  onTap: () {
                    final added = services.playlists.addSong(
                      playlist.id,
                      songId,
                    );
                    Navigator.pop(sheetContext);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          added
                              ? 'Agregada a "${playlist.name}"'
                              : 'Ya estaba en "${playlist.name}"',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    ),
  );
}
