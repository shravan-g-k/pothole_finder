import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/bloc/search/search_bloc.dart';
import 'package:frontend/models/place_model/place_model.dart';
import 'package:frontend/pages/maps/search_page/route_indicator_painter.dart';

// ---------------------------------------------------------------------------
// Which field is currently active
// ---------------------------------------------------------------------------
enum _ActiveField { from, to }

// ---------------------------------------------------------------------------
// Search page
// ---------------------------------------------------------------------------
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // -- FROM state --
  final _fromQuery = ValueNotifier<String>('');
  final _fromResults = ValueNotifier<List<PlaceModel>>([]);
  final _fromLoading = ValueNotifier<bool>(false);
  final _fromController = TextEditingController();
  final _fromFocus = FocusNode();
  PlaceModel? _fromSelected;
  final _fromError = ValueNotifier<String?>(null);
  // Track last dispatched text to avoid re-firing on focus-only events
  String _lastFromText = '';

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

  // -- Which field owns the BlocConsumer results --
  final _activeField = ValueNotifier<_ActiveField>(_ActiveField.to);

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_onFromChanged);
    _toController.addListener(_onToChanged);

    _fromFocus.addListener(() {
      if (_fromFocus.hasFocus) _activeField.value = _ActiveField.from;
    });
    _toFocus.addListener(() {
      if (_toFocus.hasFocus) _activeField.value = _ActiveField.to;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toFocus.requestFocus();
    });
  }

  void _onFromChanged() {
    final text = _fromController.text;
    // *** FIX: bail out early if text hasn't actually changed ***
    if (text == _lastFromText) return;
    _lastFromText = text;

    _fromQuery.value = text;

    // Invalidate the previously selected place since the user is typing again
    _fromSelected = null;

    if (text.isEmpty) {
      _fromResults.value = [];
      _fromLoading.value = false;
      _fromError.value = 'Please enter a starting point';
      return;
    }
    _fromError.value = null;
    _fromLoading.value = true;
    _activeField.value = _ActiveField.from;
    context.read<SearchBloc>().add(SearchQueryChanged(text));
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
    _activeField.value = _ActiveField.to;
    context.read<SearchBloc>().add(SearchQueryChanged(text));
  }

  void _selectFrom(PlaceModel result) {
    _lastFromText = result.name; // keep in sync so listener won't re-fire
    _fromController.text = result.name;
    _fromFocus.unfocus();
    _fromResults.value = [];
    _fromSelected = result;
    if (_toController.text.isEmpty) _toFocus.requestFocus();
  }

  void _selectTo(PlaceModel result) {
    _lastToText = result.name; // keep in sync so listener won't re-fire
    _toController.text = result.name;
    _toFocus.unfocus();
    _toResults.value = [];
    _toSelected = result;
  }

  /// Validates both fields and dispatches GetRouteCalled when both are ready.
  void _tryDispatchRoute() {
    if (_fromController.text.isEmpty) {
      _fromError.value = 'Please enter a starting point';
      return;
    }
    if (_toController.text.isEmpty) {
      _toError.value = 'Please enter a destination';
      return;
    }

    // Text is present but the user never tapped a suggestion — show guidance
    if (_fromSelected == null) {
      _fromError.value = 'Please select a suggestion from the list';
      return;
    }
    if (_toSelected == null) {
      _toError.value = 'Please select a suggestion from the list';
      return;
    }

    context.read<MapsBloc>().add(
      GetRouteCalled(
        _fromSelected!.location,
        _toSelected!.location,
        _fromSelected!.name,
        _toSelected!.name,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _fromController.removeListener(_onFromChanged);
    _toController.removeListener(_onToChanged);
    _fromController.dispose();
    _toController.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    _fromQuery.dispose();
    _fromResults.dispose();
    _fromLoading.dispose();
    _toQuery.dispose();
    _toResults.dispose();
    _toLoading.dispose();
    _fromError.dispose();
    _toError.dispose();
    _activeField.dispose();
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
            _DualSearchBar(
              fromController: _fromController,
              fromFocus: _fromFocus,
              fromLoading: _fromLoading,
              fromError: _fromError,
              toController: _toController,
              toFocus: _toFocus,
              toLoading: _toLoading,
              toError: _toError,
              onSearch: _tryDispatchRoute, // ← new
            ),
            _HairlineDivider(),

            // Results list driven by the active field
            ValueListenableBuilder<_ActiveField>(
              valueListenable: _activeField,
              builder: (context, activeField, _) {
                return BlocConsumer<SearchBloc, SearchState>(
                  listener: (context, state) {
                    if (activeField == _ActiveField.from) {
                      if (state is SearchLoading) {
                        _fromLoading.value = true;
                      } else if (state is SearchSuccess) {
                        _fromResults.value = state.suggestions;
                        _fromLoading.value = false;
                      } else if (state is SearchFailure) {
                        _fromResults.value = [];
                        _fromLoading.value = false;
                      }
                    } else {
                      if (state is SearchLoading) {
                        _toLoading.value = true;
                      } else if (state is SearchSuccess) {
                        _toResults.value = state.suggestions;
                        _toLoading.value = false;
                      } else if (state is SearchFailure) {
                        _toResults.value = [];
                        _toLoading.value = false;
                      }
                    }
                  },
                  builder: (context, _) {
                    if (activeField == _ActiveField.from) {
                      return Expanded(
                        child: _SuggestionList(
                          query: _fromQuery,
                          results: _fromResults,
                          loading: _fromLoading,
                          onSelect: _selectFrom,
                          emptyHint: 'Search for a starting point',
                        ),
                      );
                    } else {
                      return Expanded(
                        child: _SuggestionList(
                          query: _toQuery,
                          results: _toResults,
                          loading: _toLoading,
                          onSelect: _selectTo,
                          emptyHint: 'Search for a destination',
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dual search bar (FROM + TO stacked)
// ---------------------------------------------------------------------------
class _DualSearchBar extends StatelessWidget {
  const _DualSearchBar({
    required this.fromController,
    required this.fromFocus,
    required this.fromLoading,
    required this.fromError,
    required this.toController,
    required this.toFocus,
    required this.toLoading,
    required this.toError,
    required this.onSearch, // ← new
  });

  final TextEditingController fromController;
  final FocusNode fromFocus;
  final ValueNotifier<bool> fromLoading;
  final ValueNotifier<String?> fromError;
  final TextEditingController toController;
  final FocusNode toFocus;
  final ValueNotifier<bool> toLoading;
  final ValueNotifier<String?> toError;
  final VoidCallback onSearch; // ← new

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dotted route indicator
              _RouteIndicator(),
              const SizedBox(width: 14),
              // The two text fields
              Expanded(
                child: Column(
                  children: [
                    _SearchField(
                      controller: fromController,
                      focusNode: fromFocus,
                      loading: fromLoading,
                      errorNotifier: fromError,
                      hint: 'From',
                      autofocus: false,
                    ),
                    const SizedBox(height: 10),
                    _SearchField(
                      controller: toController,
                      focusNode: toFocus,
                      loading: toLoading,
                      errorNotifier: toError,
                      hint: 'To',
                      autofocus: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchButton(onTap: onSearch),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search button
// ---------------------------------------------------------------------------
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Let\'s Go',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vertical dotted route indicator (origin dot → line → destination dot)
// ---------------------------------------------------------------------------
class _RouteIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 68,
      child: CustomPaint(painter: RouteIndicatorPainter()),
    );
  }
}

// ---------------------------------------------------------------------------
// Single search field row
// ---------------------------------------------------------------------------
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.errorNotifier,
    required this.hint,
    required this.autofocus,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueNotifier<bool> loading;
  final ValueNotifier<String?> errorNotifier;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  style: const TextStyle(
                    fontSize: 15,
                    letterSpacing: -0.2,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textInputAction: TextInputAction.search,
                  cursorColor: Colors.black,
                  cursorWidth: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () => controller.clear(),
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.black38,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: errorNotifier,
          builder: (context, error, _) {
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hairline divider
// ---------------------------------------------------------------------------
class _HairlineDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 0.5,
      color: Colors.black12,
    );
  }
}

// ---------------------------------------------------------------------------
// Suggestions list
// ---------------------------------------------------------------------------
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.query,
    required this.results,
    required this.loading,
    required this.onSelect,
    required this.emptyHint,
  });

  final ValueNotifier<String> query;
  final ValueNotifier<List<PlaceModel>> results;
  final ValueNotifier<bool> loading;
  final ValueChanged<PlaceModel> onSelect;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: query,
      builder: (_, q, __) {
        if (q.isEmpty) return _EmptyHint(message: emptyHint);
        return ValueListenableBuilder<bool>(
          valueListenable: loading,
          builder: (_, isLoading, __) {
            if (isLoading)
              return const _EmptyHint(message: 'Searching places...');
            return ValueListenableBuilder<List<PlaceModel>>(
              valueListenable: results,
              builder: (_, items, __) {
                if (items.isEmpty)
                  return const _EmptyHint(message: 'No results');
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final item in items)
                        _SuggestionTile(
                          result: item,
                          onTap: () => onSelect(item),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Individual suggestion tile
// ---------------------------------------------------------------------------
class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.result, required this.onTap});

  final PlaceModel result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.north_west, size: 14, color: Colors.black26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: const TextStyle(
                      fontSize: 15,
                      letterSpacing: -0.2,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / hint state
// ---------------------------------------------------------------------------
class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black26,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
