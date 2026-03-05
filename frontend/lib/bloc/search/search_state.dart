part of 'search_bloc.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchSuccess extends SearchState {
  final List<PlaceModel> suggestions;

  SearchSuccess(this.suggestions);
}

final class SearchFailure extends SearchState {
  final String error;

  SearchFailure(this.error);
}
