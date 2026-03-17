import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTypeSelector extends StatelessWidget {
  const MapTypeSelector({super.key, required this.mapTypeNotifier});

  final ValueNotifier<MapType> mapTypeNotifier;

  static const _mapTypes = [
    (label: 'Normal', icon: Icons.map_outlined, type: MapType.normal),
    (label: 'Satellite', icon: Icons.satellite_alt, type: MapType.satellite),
    (label: 'Terrain', icon: Icons.landscape_outlined, type: MapType.terrain),
    (label: 'Hybrid', icon: Icons.layers_outlined, type: MapType.hybrid),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MapType>(
      valueListenable: mapTypeNotifier,
      builder: (_, currentType, __) {
        return Column(
          children:
              _mapTypes
                  .expand(
                    (entry) => [
                      _MapTypeButton(
                        label: entry.label,
                        icon: entry.icon,
                        mapType: entry.type,
                        isActive: currentType == entry.type,
                        onTap: () => mapTypeNotifier.value = entry.type,
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                  .toList()
                ..removeLast(), // remove trailing SizedBox
        );
      },
    );
  }
}

class _MapTypeButton extends StatelessWidget {
  const _MapTypeButton({
    required this.label,
    required this.icon,
    required this.mapType,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final MapType mapType;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: label,
      backgroundColor: isActive ? Colors.blue : Colors.white,
      foregroundColor: isActive ? Colors.white : Colors.black87,
      elevation: isActive ? 4 : 2,
      onPressed: isActive ? null : onTap,
      child: Icon(icon),
    );
  }
}
