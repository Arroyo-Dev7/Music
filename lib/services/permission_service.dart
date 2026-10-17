import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Todo lo relacionado con permisos de Android en un solo lugar.
class PermissionService {
  const PermissionService();

  /// Android 13+ (API 33) usa READ_MEDIA_AUDIO; antes, READ_EXTERNAL_STORAGE.
  Future<Permission> _audioPermission() async {
    if (!Platform.isAndroid) return Permission.storage;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt >= 33 ? Permission.audio : Permission.storage;
  }

  /// Revisa el permiso de audio y lo pide si hace falta.
  Future<PermissionStatus> requestAudio() async {
    final permission = await _audioPermission();
    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
    }
    return status;
  }

  /// En Android 13+ la notificación del reproductor necesita este permiso.
  /// Si el usuario lo rechaza, la música igual suena; solo no verá la notificación.
  Future<void> requestNotifications() async {
    if (!Platform.isAndroid) return;
    final status = await Permission.notification.status;
    if (!status.isGranted && !status.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }
}
