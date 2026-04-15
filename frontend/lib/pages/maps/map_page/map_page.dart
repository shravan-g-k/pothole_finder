import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/pages/maps/map_page/map_top_bar/map_top_bar.dart';
import 'package:frontend/pages/maps/map_page/map_view.dart';
import 'package:frontend/pages/maps/map_page/map_type_selector.dart';
import 'package:frontend/pages/maps/map_page/widgets/gps_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ValueNotifier<MapType> _mapTypeNotifier = ValueNotifier(MapType.normal);

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  @override
  void dispose() {
    _mapTypeNotifier.dispose();
    super.dispose();
  }

  void _setCurrentLocation() {
    context.read<MapsBloc>().add(GetLiveLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
          
          ValueListenableBuilder<MapType>(
              valueListenable: _mapTypeNotifier,
              builder:
                  (_, mapType, __) => MapView(
                    mapType: mapType,
                  ),
            ),
     
        const MapTopBar(),
        Positioned(
          top: 200,
          right: 12,
          child: MapTypeSelector(mapTypeNotifier: _mapTypeNotifier),
        ),

        Positioned(
          right: 20,
          bottom: 100,
          child: GpsButton(onPressed: _setCurrentLocation),
        ),
      ],
    );
  }
}
