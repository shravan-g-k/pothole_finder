import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/utils/constants/routes/routes.dart';
import 'package:frontend/utils/constants/ui/box_decor_const.dart';

class MapTopBar extends StatelessWidget {
  const MapTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const double padding = 8;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding,
      ),
      margin: EdgeInsets.only(
        left: padding,
        right: padding,
        top: mediaQuery.padding.top,
      ),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BoxDecorConst.borderRadius),
      ),
      child: BlocConsumer<MapsBloc, MapsState>(
        listener: (context, state) {},
        listenWhen: (previous, current) {
          return current is RouteLoaded;
        },
        builder: (context, state) {
          String? from;
          String? to;

          if (state is RouteLoaded) {
            from = state.startAddress;
            to = state.endAddress;
          }

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.searchPage);
            },
            child: Row(
              children: [
                Flexible(
                  child: _TopBarField(
                    icon: Icons.my_location_rounded,
                    label: from,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: Colors.black26,
                ),
                Flexible(
                  child: _TopBarField(
                    icon: Icons.location_on_rounded,
                    label: to,
                  ),
                ),
              ],
            ),
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
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
