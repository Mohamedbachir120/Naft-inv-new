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

  SubmitAuthentication({required this.matricule, required this.password});
}

class SubmitImmobilisationAuthentication extends AuthenticationEvent {
  final String matricule;
  final String centre;
  final String password;

  SubmitImmobilisationAuthentication(
      {required this.matricule, required this.password, required this.centre});
}

class InitialDatabaseState extends AuthenticationEvent {
  InitialDatabaseState() : super();
}

class SelectStructure extends AuthenticationEvent {
  final String centre;
  final int year;
  SelectStructure({required this.centre, required this.year});
}

class AuthenticationSignOut extends AuthenticationEvent {
  AuthenticationSignOut();
}
