import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Single search bar
// ---------------------------------------------------------------------------
class SingleSearchBar extends StatelessWidget {
  const SingleSearchBar({
    super.key,
    required this.toController,
    required this.toFocus,
    required this.toLoading,
    required this.toError,
    required this.onSearch,
  });

  final TextEditingController toController;
  final FocusNode toFocus;
  final ValueNotifier<bool> toLoading;
  final ValueNotifier<String?> toError;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 24, color: Colors.redAccent),
              const SizedBox(width: 14),
              Expanded(
                child: SearchField(
                  controller: toController,
                  focusNode: toFocus,
                  loading: toLoading,
                  errorNotifier: toError,
                  hint: 'Where to?',
                  autofocus: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SearchButton(onTap: onSearch),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search button
// ---------------------------------------------------------------------------
class SearchButton extends StatelessWidget {
  const SearchButton({super.key, required this.onTap});
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
// Single search field row
// ---------------------------------------------------------------------------
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
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
class HairlineDivider extends StatelessWidget {
  const HairlineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 0.5,
      color: Colors.black12,
    );
  }
}
