part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;

  SearchQueryChanged(this.query);
}

class SearchLocationSubmitted extends SearchEvent {
  final LatLng end;  
  final String endAddress;

  SearchLocationSubmitted(this.end, this.endAddress);
}
  