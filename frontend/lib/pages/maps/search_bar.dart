import 'package:flutter/material.dart';

/// A Google-style search bar for selecting multiple places (for routing).
///
/// [onSearchChanged] is called when the user types in the search field.
/// [onPlaceSelected] is called when a place is selected from suggestions.
/// [onPlaceRemoved] is called when a selected place is removed.
/// [selectedPlaces] is the list of currently selected places (displayed as chips).
/// [suggestions] is the list of current search suggestions.
class RoutingSearchBar extends StatelessWidget {
  final List<String> selectedPlaces;
  final List<String> suggestions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onPlaceSelected;
  final ValueChanged<String> onPlaceRemoved;

  const RoutingSearchBar({
    super.key,
    required this.selectedPlaces,
    required this.suggestions,
    required this.onSearchChanged,
    required this.onPlaceSelected,
    required this.onPlaceRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final double extraPadding = 16.0;
    return Padding(
      padding: EdgeInsets.only(
        top: padding.top + extraPadding,
        left: extraPadding,
        right: extraPadding,
      ),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              EditableText(
                controller: TextEditingController(),
                focusNode: FocusNode(),
                onChanged: onSearchChanged,
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                cursorColor: Colors.blueAccent,
                backgroundCursorColor: Colors.grey,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.flag, color: Colors.green),
                  labelText: 'To',
                  labelStyle: const TextStyle(color: Colors.green),
                  filled: true,
                  fillColor: Colors.green[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: onSearchChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
