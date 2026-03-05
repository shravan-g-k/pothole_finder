import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_model.freezed.dart';
part 'place_model.g.dart';

@freezed
abstract class PlaceModel with _$PlaceModel {
  // 1. The constructor must be a factory with no body
  // 2. The redirected constructor name (e.g., _PlaceModel) is required
  const factory PlaceModel({
    required String name,
    required String address,
    @JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson)
    required LatLng location,
  }) = _PlaceModel;

  // 3. This factory connects the generated .g.dart code
  factory PlaceModel.fromJson(Map<String, dynamic> json) =>
      _$PlaceModelFromJson(json);
}

LatLng _latLngFromJson(Map<String, dynamic> json) {
  print(json);
  // Use 'as num' to safely handle both int and double from JSON
  return LatLng(
    (json['lat'] as num).toDouble(),
    (json['lng'] as num).toDouble(),
  );
}

Map<String, dynamic> _latLngToJson(LatLng location) => {
  'lat': location.latitude,
  'lng': location.longitude,
};
