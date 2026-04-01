import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GpsButton extends StatelessWidget {
  const GpsButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'gps',
      onPressed: onPressed,
      child: const Icon(CupertinoIcons.compass),
    );
  }
}
