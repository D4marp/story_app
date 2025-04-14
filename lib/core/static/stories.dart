import 'package:story_app/data/model/response/stories/list_stories.dart';

sealed class StoriesResultState {}

class StoriesNoneState extends StoriesResultState {}

class StoriesLoadingState extends StoriesResultState {}

class StoriesErrorState extends StoriesResultState {
  final String error;

  StoriesErrorState(this.error);
}

class StoriesLoadedState extends StoriesResultState {
  final List<ListStory> data;

  StoriesLoadedState(this.data);
}
