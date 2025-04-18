import 'package:flutter/material.dart';

import '../../core/static/stories_detail.dart';
import '../../data/api/api_service.dart';

class StoryDetailProvider extends ChangeNotifier {
  final ApiService _apiService;

  StoryDetailProvider(
    this._apiService,
  );

  StoryDetailResultState _resultState = StoryDetailNoneState();
  StoryDetailResultState get resultState => _resultState;

  Future<void> getStoryDetail(String id) async {
    try {
      _resultState = StoryDetailLoadingState();
      notifyListeners();

      final result = await _apiService.getStoryDetail(id);

      result.fold(
        (errorMessage) {
          _resultState = StoryDetailErrorState(errorMessage);
          notifyListeners();
        },
        (response) {
          _resultState = StoryDetailLoadedState(response);
          notifyListeners();
        },
      );
    } on Exception catch (e) {
      _resultState = StoryDetailErrorState(e.toString());
      notifyListeners();
    }
  }
}
