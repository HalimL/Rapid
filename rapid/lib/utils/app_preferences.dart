import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late SharedPreferences _preferences;

  static const _loggedIn = 'logIn';
  static const _keyControllerValue = 'controllerValue';
  static const _keyDetachedTime = 'detachedTime';
  static const _keyFinishedTimer = 'finishedimer';
  static const _keyShownAlert = 'shownAlert';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setControllerValue(double controllerValue) async =>
      await _preferences.setDouble(_keyControllerValue, controllerValue);

  static double? getControllerValue() =>
      _preferences.getDouble(_keyControllerValue);

  static Future setDetachedTime(String detachedTime) async =>
      await _preferences.setString(_keyDetachedTime, detachedTime);

  static String? getDetachedTime() => _preferences.getString(_keyDetachedTime);

  static Future setCounterCompleted(bool finishedTimer) async =>
      await _preferences.setBool(_keyFinishedTimer, finishedTimer);

  static bool? getCounterCompleted() => _preferences.getBool(_keyFinishedTimer);

  static Future setShownAlert(bool shownAlert) async =>
      await _preferences.setBool(_keyShownAlert, shownAlert);

  static bool? getShownAlert() => _preferences.getBool(_keyShownAlert);

  static Future setLogin(bool loggedIn) async =>
      await _preferences.setBool(_keyShownAlert, loggedIn);

  static bool? getLogin() => _preferences.getBool(_loggedIn);

  void resetCounter() => setCounterCompleted(false);
}
