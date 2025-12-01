// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart' ;
part 'user_model.freezed.dart';
@freezed
class UserModel with _$UserModel {
  final String name;
  final String email;

  UserModel({required this.name, required this.email});
  
  
}