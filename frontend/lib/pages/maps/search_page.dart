import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/search/search_bloc.dart';
import 'package:frontend/models/place_model/place_model.dart';

// ---------------------------------------------------------------------------
// Mock search function – replace with your real API / business logic
// ---------------------------------------------------------------------------
Future<List<SearchResult>> fetchSuggestions(String query) async {
  // Simulate network latency
  await Future.delayed(const Duration(milliseconds: 300));

  if (query.isEmpty) return [];

  // Mock data – swap for a real network call
  final all = [
    SearchResult(
      title: 'Flutter architecture patterns',
      subtitle: 'BLoC, Riverpod, MVC',
    ),
    SearchResult(
      title: 'Flutter state management',
      subtitle: 'No setState ever again',
    ),
    SearchResult(
      title: 'Dart null safety guide',
      subtitle: 'Sound null safety deep-dive',
    ),
    SearchResult(title: 'Flutter animations', subtitle: 'Implicit & explicit'),
    SearchResult(
      title: 'Firebase with Flutter',
      subtitle: 'Auth, Firestore, Storage',
    ),
    SearchResult(
      title: 'SearchController in Flutter',
      subtitle: 'Native search delegation',
    ),
    SearchResult(
      title: 'Custom painters in Flutter',
      subtitle: 'Canvas & paint',
    ),
    SearchResult(
      title: 'Flutter testing handbook',
      subtitle: 'Unit, widget, integration',
    ),
  ];

  return all
      .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class SearchResult {
  const SearchResult({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

// ---------------------------------------------------------------------------
// Search page – zero setState
// ---------------------------------------------------------------------------
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // ValueNotifiers drive all reactive rebuilds – no setState anywhere
  final _query = ValueNotifier<String>('');
  final _results = ValueNotifier<List<PlaceModel>>([]);
  final _loading = ValueNotifier<bool>(false);

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    _query.value = text;
    _search(text);
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _results.value = [];
      return;
    }
    _loading.value = true;
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  void _selectResult(PlaceModel result) {
    _controller.text = result.name;
    _focusNode.unfocus();
    _results.value = [];
    // TODO: navigate or handle selection
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _query.dispose();
    _results.dispose();
    _loading.dispose();
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
            _SearchBar(
              controller: _controller,
              focusNode: _focusNode,
              loading: _loading,
            ),
            _Divider(),
            BlocConsumer<SearchBloc, SearchState>(
              listener: (context, state) {
                if (state is SearchLoading) {
                  _loading.value = true;
                } else if (state is SearchSuccess) {
                  _results.value = state.suggestions;
                  _loading.value = false;
                } else if (state is SearchFailure) {
                  
                  _results.value = [];
                  _loading.value = false;
                }
              },
              builder: (context, state) {
                return Expanded(
                  child: _SuggestionList(
                    query: _query,
                    results: _results,
                    onSelect: _selectResult,
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

// ---------------------------------------------------------------------------
// Search bar widget
// ---------------------------------------------------------------------------
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.loading,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueNotifier<bool> loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              style: const TextStyle(
                fontSize: 17,
                letterSpacing: -0.3,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.black26,
                  fontSize: 17,
                  letterSpacing: -0.3,
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
          const SizedBox(width: 8),
          // Spinner or clear button
          ValueListenableBuilder<bool>(
            valueListenable: loading,
            builder: (_, isLoading, __) {
              if (isLoading) {
                return const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.black38,
                  ),
                );
              }
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () => controller.clear(),
                    child: const Icon(
                      Icons.close,
                      size: 17,
                      color: Colors.black38,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hairline divider
// ---------------------------------------------------------------------------
class _Divider extends StatelessWidget {
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
// Suggestions list – driven by ValueListenables, no ListView.builder suggestions
// ---------------------------------------------------------------------------
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.query,
    required this.results,
    required this.onSelect,
  });

  final ValueNotifier<String> query;
  final ValueNotifier<List<PlaceModel>> results;
  final ValueChanged<PlaceModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: query,
      builder: (_, q, __) {
        if (q.isEmpty) {
          return const _EmptyHint(message: 'Start typing to search');
        }
        return ValueListenableBuilder<List<PlaceModel>>(
          valueListenable: results,
          builder: (_, items, __) {
            if (items.isEmpty) {
              return const _EmptyHint(message: 'No results');
            }
            // Manual column – no suggestionsBuilder, no ListView.builder
            return SingleChildScrollView(
              child: Column(
                children: [
                  for (final item in items)
                    _SuggestionTile(result: item, onTap: () => onSelect(item)),
                ],
              ),
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
