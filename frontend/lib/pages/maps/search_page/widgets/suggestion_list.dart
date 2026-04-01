import 'package:flutter/material.dart';
import 'package:frontend/models/place_model/place_model.dart';

// ---------------------------------------------------------------------------
// Suggestions list
// ---------------------------------------------------------------------------
class SuggestionList extends StatelessWidget {
  const SuggestionList({
    super.key,
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
        if (q.isEmpty) return EmptyHint(message: emptyHint);
        return ValueListenableBuilder<bool>(
          valueListenable: loading,
          builder: (_, isLoading, __) {
            if (isLoading) {
              return const EmptyHint(message: 'Searching places...');
            }
            return ValueListenableBuilder<List<PlaceModel>>(
              valueListenable: results,
              builder: (_, items, __) {
                if (items.isEmpty) {
                  return const EmptyHint(message: 'No results');
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final item in items)
                        SuggestionTile(
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
class SuggestionTile extends StatelessWidget {
  const SuggestionTile({super.key, required this.result, required this.onTap});

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
class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.message});
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
