import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';
import 'services/app_services.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Caché de imágenes decodificadas: las carátulas ya vienen reducidas desde
  // Android, así que 48 MB / 400 imágenes sobran y protegen la RAM del móvil.
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSizeBytes = 48 << 20;
  imageCache.maximumSize = 400;

  // Barras del sistema transparentes con iconos claros.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Habilita la reproducción en segundo plano y la notificación con controles.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.music.channel.audio',
    androidNotificationChannelName: 'Reproducción de música',
    androidNotificationOngoing: true,
  );
  final services = await AppServices.create();
  runApp(MyApp(services: services));
}
