import 'package:flutter/material.dart';
import 'package:frontend/pages/maps/map_view.dart';
import 'package:frontend/pages/maps/search_bar.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MapView(),
        Align(
          alignment: Alignment.topCenter,
          child: RoutingSearchBar(
            selectedPlaces: ['Karnataka'],
            suggestions: ['Karnataka', 'Maharashtra', 'Tamil Nadu'],
            onSearchChanged: (query) {},
            onPlaceSelected: (place) {},
            onPlaceRemoved: (place) {},
          ),
        ),
      ],
    );
  }
}

//map rotations have to be set up
