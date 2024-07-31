part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class AuthenticationStatusChanged extends AuthenticationEvent {
  final AuthenticationStatus status;
  AuthenticationStatusChanged({required this.status});
}

class SubmitAuthentication extends AuthenticationEvent {
  final String matricule;
  final String password;

  SubmitAuthentication(
      { required this.matricule, required this.password});
}

class InitialDatabaseState extends AuthenticationEvent {
  InitialDatabaseState() : super();
}

class SelectStructure extends AuthenticationEvent {
  final String centre;
  final int year;
  SelectStructure({required this.centre,required this.year});
}
