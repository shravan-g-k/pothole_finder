import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/bloc/search/search_bloc.dart';
import 'package:frontend/models/place_model/place_model.dart';
import 'package:frontend/pages/maps/search_page/widgets/search_bar.dart';
import 'package:frontend/pages/maps/search_page/widgets/suggestion_list.dart';

// ---------------------------------------------------------------------------
// Search page
// ---------------------------------------------------------------------------
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // -- TO state --
  final _toQuery = ValueNotifier<String>('');
  final _toResults = ValueNotifier<List<PlaceModel>>([]);
  final _toLoading = ValueNotifier<bool>(false);
  final _toController = TextEditingController();
  final _toFocus = FocusNode();
  PlaceModel? _toSelected;
  final _toError = ValueNotifier<String?>(null);
  // Track last dispatched text to avoid re-firing on focus-only events
  String _lastToText = '';

  @override
  void initState() {
    super.initState();
    _toController.addListener(_onToChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toFocus.requestFocus();
    });
  }

  void _onToChanged() {
    final text = _toController.text;
    // *** FIX: bail out early if text hasn't actually changed ***
    if (text == _lastToText) return;
    _lastToText = text;

    _toQuery.value = text;

    // Invalidate the previously selected place since the user is typing again
    _toSelected = null;

    if (text.isEmpty) {
      _toResults.value = [];
      _toLoading.value = false;
      _toError.value = 'Please enter a destination';
      return;
    }
    _toError.value = null;
    _toLoading.value = true;
    context.read<SearchBloc>().add(SearchQueryChanged(text));
  }

  void _selectTo(PlaceModel result) {
    _lastToText = result.name; // keep in sync so listener won't re-fire
    _toController.text = result.name;
    _toFocus.unfocus();
    _toResults.value = [];
    _toSelected = result;
  }

  /// Validates the to field and Wood dispatches GetRouteCalled using current location.
  void _tryDispatchRoute() async {
    if (_toController.text.isEmpty) {
      _toError.value = 'Please enter a destination';
      return;
    }

    // Text is present but the user never tapped a suggestion — show guidance
    if (_toSelected == null) {
      _toError.value = 'Please select a suggestion from the list';
      return;
    }

    context.read<SearchBloc>().add(
      SearchLocationSubmitted(_toSelected!.location, _toSelected!.name),
    );
  }

  void _displayLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            child: const Center(child: CircularProgressIndicator()),
          ),
    );
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  void _displayError(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _toController.removeListener(_onToChanged);
    _toController.dispose();
    _toFocus.dispose();
    _toQuery.dispose();
    _toResults.dispose();
    _toLoading.dispose();
    _toError.dispose();
    super.dispose();
  }

  // ---- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleSearchBar(
              toController: _toController,
              toFocus: _toFocus,
              toLoading: _toLoading,
              toError: _toError,
              onSearch: _tryDispatchRoute,
            ),
            const HairlineDivider(),

            // Results list
            BlocConsumer<SearchBloc, SearchState>(
              listener: (context, state) {
                if (state is SearchLoading) {
                  _toLoading.value = true;
                } else if (state is SearchSuccess) {
                  _toResults.value = state.suggestions;
                  _toLoading.value = false;
                } else if (state is SearchFailure) {
                  _toResults.value = [];
                  _toLoading.value = false;
                } else if (state is SearchRouteLoading) {
                  _displayLoading();
                } else if (state is SearchRouteError) {
                  _hideLoading();
                  _displayError(state.error);
                } else if (state is SearchRouteLocationError) {
                  _hideLoading();
                  _displayError("Enable location permissions and try again");
                } else if (state is SearchRouteLoaded) {
                  _hideLoading();
                  context.read<MapsBloc>().add(
                    MapsRouteLoadedEvent(
                      points: state.points,
                      routePoints: state.routePoints,
                      start: state.start,
                      destination: state.destination,
                      startAddress: state.startAddress,
                      endAddress: state.endAddress,
                      segments: state.segments,
                      distance: state.distance,
                      duration: state.duration,
                      bboxPoints: state.bboxPoints,
                    ),
                  );
                }
              },
              builder: (context, _) {
                return Expanded(
                  child: SuggestionList(
                    query: _toQuery,
                    results: _toResults,
                    loading: _toLoading,
                    onSelect: _selectTo,
                    emptyHint: 'Search for a destination',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
