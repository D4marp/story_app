import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/response/auth/auth_response.dart';

class TokenPreference {
  static const String _authDataKey = 'auth_data';

  Future<void> saveAuthData(AuthResponse data) async {
    final tokenPreference = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(data.toJson());
    await tokenPreference.setString(_authDataKey, jsonData);
  }

  Future<AuthResponse?> getAuthData() async {
    final tokenPreference = await SharedPreferences.getInstance();
    final data = tokenPreference.getString(_authDataKey);
    if (data != null) {
      try {
        final jsonData = jsonDecode(data) as Map<String, dynamic>;
        return AuthResponse.fromJson(jsonData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> removeAuthData() async {
    final tokenPreference = await SharedPreferences.getInstance();
    await tokenPreference.remove(_authDataKey);
  }

  Future<bool> isUserLoggedIn() async {
    final tokenPreference = await SharedPreferences.getInstance();
    return tokenPreference.containsKey(_authDataKey);
  }
}
