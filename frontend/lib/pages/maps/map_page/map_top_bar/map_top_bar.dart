import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/pages/maps/map_page/widgets/segment_info.dart';
import 'package:frontend/utils/constants/routes/routes.dart';
import 'package:frontend/utils/constants/ui/box_decor_const.dart';

class MapTopBar extends StatelessWidget {
  const MapTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const double padding = 8;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(
        left: padding,
        right: padding,
        top: mediaQuery.padding.top + padding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BoxDecorConst.borderRadius),
      ),
      child: BlocBuilder<MapsBloc, MapsState>(
        builder: (context, state) {
          String? from;
          String? to;

          if (state is RouteNavigationStarted) {
            final firstSegment =
                state.segments.isNotEmpty ? state.segments.first : null;
            final nextSegment =
                state.segments.length > 1 ? state.segments[1] : null;
            return SegmentInfo(
              segment: firstSegment!,
              nextSegment: nextSegment,
            );
          }

          if (state is RouteLoaded) {
            from = state.startAddress;
            to = state.endAddress;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.searchPage);
                },
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: _TopBarField(
                        icon: Icons.my_location_rounded,
                        label: from,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Colors.black87,
                    ),
                    Flexible(
                      flex: 2,
                      child: _TopBarField(
                        icon: Icons.location_on_rounded,
                        label: to,
                      ),
                    ),
                  ],
                ),
              ),
              if (state is RouteLoaded) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            theme.colorScheme.error,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            theme.colorScheme.onError,
                          ),
                        ),
                        onPressed: () {
                          context.read<MapsBloc>().add(ResetMap());
                        },
                        icon: const Icon(Icons.cancel_presentation_rounded),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 8,
                      child: TextButton(
                        onPressed: () {
                          context.read<MapsBloc>().add(
                            StartNavigation(
                              state.points,
                              state.segments,
                              state.distance,
                              state.duration,
                              state.endAddress,
                            ),

                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            theme.colorScheme.primary,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.navigation_rounded),
                            const Text("Start"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TopBarField extends StatelessWidget {
  const _TopBarField({required this.icon, this.label});

  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(BoxDecorConst.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 25, color: theme.colorScheme.onSecondaryContainer),
            if (label != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label ?? "",
                  maxLines: 1,
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
