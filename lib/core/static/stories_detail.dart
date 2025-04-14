import 'package:story_app/data/model/response/detail/stories_detail_response.dart';

sealed class StoryDetailResultState {}

class StoryDetailNoneState extends StoryDetailResultState {}

class StoryDetailLoadingState extends StoryDetailResultState {}

class StoryDetailErrorState extends StoryDetailResultState {
  final String error;

  StoryDetailErrorState(this.error);
}

class StoryDetailLoadedState extends StoryDetailResultState {
  final StoryDetailResponse data;

  StoryDetailLoadedState(this.data);
}
