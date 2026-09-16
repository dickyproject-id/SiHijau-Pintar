import 'package:shared_preferences/shared_preferences.dart';

class QuotaService {
  static Future<void> recordStrike(String plantName) async {
    final prefs = await SharedPreferences.getInstance();
    int level = prefs.getInt('penaltyLevel_$plantName') ?? 0;

    if (level == 0) {
      int strikes = (prefs.getInt('strike_$plantName') ?? 0) + 1;
      if (strikes >= 3) {
        await prefs.setInt('penaltyLevel_$plantName', 1);
        await prefs.setString(
          'cooldown_$plantName',
          DateTime.now().add(const Duration(seconds: 20)).toIso8601String(),
        );
        await prefs.setInt('strike_$plantName', 0);
        await prefs.setBool('hasShownWarning_$plantName', false);
      } else {
        await prefs.setInt('strike_$plantName', strikes);
      }
    } else if (level >= 1) {
      await prefs.setInt('penaltyLevel_$plantName', 2);
      await prefs.setString(
        'cooldown_$plantName',
        DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
      );
    }
  }

  static Future<Duration> getCooldownRemaining(String plantName) async {
    final prefs = await SharedPreferences.getInstance();
    String? cooldownStr = prefs.getString('cooldown_$plantName');
    if (cooldownStr == null) return Duration.zero;

    DateTime cooldown = DateTime.parse(cooldownStr);
    if (DateTime.now().isBefore(cooldown)) {
      return cooldown.difference(DateTime.now());
    }
    return Duration.zero;
  }

  static Future<bool> shouldShowWarning(String plantName) async {
    final prefs = await SharedPreferences.getInstance();
    int level = prefs.getInt('penaltyLevel_$plantName') ?? 0;
    bool hasShown = prefs.getBool('hasShownWarning_$plantName') ?? false;
    Duration remaining = await getCooldownRemaining(plantName);

    if (level == 1 && !hasShown && remaining.inSeconds <= 0) {
      return true;
    }
    return false;
  }

  static Future<void> markWarningShown(String plantName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownWarning_$plantName', true);
  }
  
  static Future<int> getPenaltyLevel(String plantName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('penaltyLevel_$plantName') ?? 0;
  }
}
