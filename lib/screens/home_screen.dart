import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/library_result.dart';
import '../services/app_services.dart';
import '../services/permission_service.dart';
import '../widgets/message_view.dart';
import '../widgets/skeleton_list.dart';
import 'main_shell.dart';

/// Carga la biblioteca y decide qué mostrar: permisos, errores o la app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  LibraryStatus _status = LibraryStatus.loading;
  List<SongModel> _songs = [];
  bool _isLoading = false; // evita cargas simultáneas

  AppServices get _services => widget.services;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLibrary());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Si el usuario va a Ajustes, da el permiso y vuelve, recargamos solo.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        (_status == LibraryStatus.permanentlyDenied ||
            _status == LibraryStatus.denied)) {
      _loadLibrary();
    }
  }

  /// [silent] = true (deslizar para refrescar): no tapa la lista con el spinner.
  Future<void> _loadLibrary({bool silent = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (!silent) setState(() => _status = LibraryStatus.loading);

    final result = await _services.library.loadSongs();
    if (!mounted) {
      _isLoading = false;
      return;
    }

    setState(() {
      _songs = result.songs;
      _status = result.status;
    });

    if (result.status == LibraryStatus.ready && !silent) {
      try {
        await const PermissionService().requestNotifications();
      } catch (e) {
        debugPrint('Permiso de notificaciones: $e');
      }
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_status == LibraryStatus.ready) {
      return MainShell(
        services: _services,
        songs: _songs,
        onRefresh: () => _loadLibrary(silent: true),
      );
    }

    return Scaffold(
      body: switch (_status) {
          LibraryStatus.loading => const SkeletonList(),
          LibraryStatus.denied => MessageView(
            icon: Icons.lock_outline_rounded,
            text: 'Necesito permiso para leer tu música.',
            buttonLabel: 'Dar permiso',
            onPressed: _loadLibrary,
          ),
          LibraryStatus.permanentlyDenied => MessageView(
            icon: Icons.settings_outlined,
            text: 'El permiso fue denegado. Actívalo desde los ajustes.',
            buttonLabel: 'Abrir ajustes',
            onPressed: openAppSettings,
          ),
          LibraryStatus.empty => MessageView(
            icon: Icons.music_off_outlined,
            text: 'No encontré canciones en este dispositivo.',
            buttonLabel: 'Volver a escanear',
            onPressed: _loadLibrary,
          ),
          _ => MessageView(
            icon: Icons.error_outline_rounded,
            text: 'Algo salió mal al leer tu música.',
            buttonLabel: 'Reintentar',
            onPressed: _loadLibrary,
          ),
      },
    );
  }
}
