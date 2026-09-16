import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyManager {
  static const String _paramKey = 'gemini_api_keys';
  static const String _exhaustedPrefix = 'exhausted_key_';

  static List<String>? _cachedKeys;

  static Future<List<String>> _fetchKeysFromRemote() async {
    if (_cachedKeys != null && _cachedKeys!.isNotEmpty) {
      return _cachedKeys!;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1), 
      ));
      await remoteConfig.fetchAndActivate();

      String jsonString = remoteConfig.getString(_paramKey);
      if (jsonString.isNotEmpty) {
        try {
          List<dynamic> parsed = jsonDecode(jsonString);
          _cachedKeys = parsed.map((e) => e.toString()).toList();
        } catch (e) {
          // Jika gagal parse JSON, asumsikan pengguna memasukkan 1 API Key secara langsung (raw string)
          // Hapus karakter newline atau spasi agar tidak menyebabkan error "Invalid HTTP header"
          _cachedKeys = [jsonString.replaceAll(RegExp(r'[\r\n]+'), '').trim()];
        }
        return _cachedKeys!;
      }
    } catch (e) {
      debugPrint('Gagal mengambil API Key dari Remote Config: $e');
    }
    return [];
  }

  static Future<String?> getAvailableKey() async {
    final keys = await _fetchKeysFromRemote();
    if (keys.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    for (String key in keys) {
      String? exhaustedTimeStr = prefs.getString('$_exhaustedPrefix$key');
      if (exhaustedTimeStr != null) {
        DateTime exhaustedTime = DateTime.parse(exhaustedTimeStr);
        // Cek apakah sudah lewat 1 menit (Bisa jadi limit karena Requests Per Minute)
        if (now.difference(exhaustedTime).inMinutes >= 1) {
          // Kunci sudah dipulihkan dari limit RPM, hapus dari daftar exhausted
          await prefs.remove('$_exhaustedPrefix$key');
          return key;
        } else {
          // Masih limit, lanjut ke kunci berikutnya
          continue;
        }
      } else {
        // Kunci belum limit
        return key;
      }
    }

    // Jika semua kunci limit, kembalikan kunci pertama sebagai cadangan terakhir
    return keys.first;
  }

  static Future<void> markKeyAsExhausted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_exhaustedPrefix$key', DateTime.now().toIso8601String());
  }
}
