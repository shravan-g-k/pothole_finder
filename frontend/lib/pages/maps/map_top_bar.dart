import 'package:flutter/material.dart';
import 'package:frontend/utils/constants/routes/routes.dart';
import 'package:frontend/utils/constants/ui/box_decor_const.dart';

class MapTopBar extends StatelessWidget {
  const MapTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const double padding = 8;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
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
      child: Row(
        children: [
          Flexible(child: _FromField()),
          Icon(Icons.arrow_forward_ios_rounded, size: 25),
          Flexible(child: _ToField()),
        ],
      ),
    );
  }
}

class _FromField extends StatelessWidget {
  const _FromField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(BoxDecorConst.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 25,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

class _ToField extends StatelessWidget {
  const _ToField();

  void onTap(BuildContext context) {
    Navigator.pushNamed(context, Routes.searchPage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(BoxDecorConst.borderRadius),
      ),
      child: InkWell(
        onTap: () => onTap(context),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 25,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            SizedBox(width: 8),
            Text('To'),
          ],
        ),
      ),
    );
  }
}
