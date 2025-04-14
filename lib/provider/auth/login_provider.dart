import 'package:flutter/material.dart';
import 'package:story_app/data/model/requests/login_request_model.dart';
import 'package:story_app/data/preferences/token.dart';

import '../../core/static/login.dart';
import '../../data/api/api_service.dart';

class LoginProvider extends ChangeNotifier {
  final ApiService _apiService;
  final TokenPreference _prefs;

  LoginProvider(
    this._apiService,
    this._prefs,
  );

  LoginResultState _resultState = LoginNoneState();
  LoginResultState get resultState => _resultState;

  Future<void> login(LoginRequestModel loginRequest) async {
    try {
      _resultState = LoginLoadingState();
      notifyListeners();

      final result = await _apiService.login(loginRequest);

      result.fold(
        (errorMessage) {
          _resultState = LoginErrorState(errorMessage);
          notifyListeners();
        },
        (response) {
          _prefs.saveAuthData(response);
          _resultState = LoginLoadedState(response);
          notifyListeners();
        },
      );
    } on Exception catch (e) {
      _resultState = LoginErrorState(e.toString());
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _prefs.removeAuthData();
    _resultState = LoginNoneState();
    notifyListeners();
  }
}
