import 'package:shared_preferences/shared_preferences.dart';

class _SharedPreferencesProvider {
  
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> getStringValue(String key) async {
    final SharedPreferences prefs = await _prefs;
    String value = prefs.getString(key);
    if(value == null) value = "";
    return value;
  }
  Future<int> getIntValue(String key) async {
    final SharedPreferences prefs = await _prefs;
    final int value = prefs.getInt(key);
    return value;
  }
  Future<double> getDoubleValue(String key) async {
    final SharedPreferences prefs = await _prefs;
    final double value = prefs.getDouble(key);
    return value;
  }
  Future<bool> getBoolValue(String key) async {
    final SharedPreferences prefs = await _prefs;
    final bool value = prefs.getBool(key);
    return value;
  }
  Future<List<String>> getStringListValue(String key) async {
    final SharedPreferences prefs = await _prefs;
    final List<String> value = prefs.getStringList(key);
    return value;
  }
  Future<bool> setStringValue(String key, String value) async {
    final SharedPreferences prefs = await _prefs;
    final bool result = await prefs.setString(key, value);
    return result;
  }
  Future<bool> setIntValue(String key, int value) async {
    final SharedPreferences prefs = await _prefs;
    final bool result = await prefs.setInt(key, value);
    return result;
  }
  Future<bool> setDoubleValue(String key, double value) async {
    final SharedPreferences prefs = await _prefs;
    final bool result = await prefs.setDouble(key, value);
    return result;
  }
  Future<bool> setBoolValue(String key, bool value) async {
    final SharedPreferences prefs = await _prefs;
    final bool result = await prefs.setBool(key, value);
    return result;
  }
  Future<bool> setStringListValue(String key, List<String> value) async {
    final SharedPreferences prefs = await _prefs;
    final bool result = await prefs.setStringList(key, value);
    return result;
  }
  Future<bool> remove(String key) async {
    final SharedPreferences prefs = await _prefs;
    final bool result = await prefs.remove(key);
    return result;
  }
}
final sharedPreferencesProvider = new _SharedPreferencesProvider();