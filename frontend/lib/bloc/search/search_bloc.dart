import 'package:bloc/bloc.dart';
import 'package:frontend/models/place_model/place_model.dart';
import 'package:frontend/repo/maps_repo.dart';
import 'package:meta/meta.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MapsRepo _mapsRepo;
  SearchBloc(this._mapsRepo) : super(SearchInitial()) {
    on<SearchQueryChanged>((event, emit) async {
      emit(SearchLoading());
      try {
        final suggestions = await _fetchSearchSuggestions(event.query);
        emit(SearchSuccess(suggestions));
      } catch (e) {
       
        emit(SearchFailure(e.toString()));
      }
    });
  }

  Future<List<PlaceModel>> _fetchSearchSuggestions(String query) async {
    return await _mapsRepo.getTextSearchResults(query);
  }
}
