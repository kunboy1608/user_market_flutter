import 'package:shared_preferences/shared_preferences.dart';

enum SPK {
  username(code: "user_name"),
  password(code: "password");

  const SPK({required this.code});

  final String code;
}

class SPM {
  static Future<dynamic> get(SPK key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (key) {
      case SPK.username:
      case SPK.password:
        return prefs.getString(key.code);
      default:
        return null;
    }
  }

  static Future<void> set(SPK key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (key) {
      case SPK.username:
      case SPK.password:
        prefs.setString(key.code, value);
        break;
      default:
    }
  }

  static Future<bool> clearAllReference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
