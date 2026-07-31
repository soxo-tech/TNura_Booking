import 'dart:convert';
import 'dart:io' show Platform;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getOrCreateDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('DEVICE_ID');

  if (id == null) {
    id = const Uuid().v4();
    await prefs.setString('DEVICE_ID', id);
  }

  return id;
}

Future<String> createDeviceFingerprint() async {
  String raw;

  try {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      raw = [
        androidInfo.model,
        androidInfo.id,
        androidInfo.version.release,
      ].join('|');
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      raw = [
        iosInfo.model,
        iosInfo.identifierForVendor ?? '',
        iosInfo.systemVersion,
      ].join('|');
    } else {
      raw = await getOrCreateDeviceId();
    }
  } catch (_) {
    // Some devices return malformed/null device-info fields that crash the
    // plugin's parsing. Fall back to a stable per-device id so secure headers
    // (and therefore login) keep working.
    raw = await getOrCreateDeviceId();
  }

  final bytes = utf8.encode(raw);
  final digest = sha256.convert(bytes);

  return digest.toString();
}