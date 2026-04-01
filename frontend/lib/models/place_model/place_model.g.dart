// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceModel _$PlaceModelFromJson(Map<String, dynamic> json) => _PlaceModel(
  name: json['name'] as String,
  address: json['address'] as String,
  location: _latLngFromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlaceModelToJson(_PlaceModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'location': _latLngToJson(instance.location),
    };
