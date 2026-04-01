part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthCheck extends AuthEvent {}

class BasicInfoFormSubmitted extends AuthEvent {
  final String name;
  final String phone;
  final String password;

  BasicInfoFormSubmitted({
    required this.name,
    required this.phone,
    required this.password,
  });

}
