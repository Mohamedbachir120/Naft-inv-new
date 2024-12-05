part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {
  final AuthenticationStatus status;

  final User? user;
  final String centre;
  final String deviceID;
  AuthenticationState(
      {required this.status,
      required this.user,
      required this.centre,
      required this.deviceID});
}

enum AuthenticationStatus {
  init,
  authenticated,
  centreSelected,
  uncheckedDevice,
  noInternet,
  authenticatedImmo,
  permissionNotGaranted,
  authFailedImmo,
  incorrectVersion
}

final class AuthenticationInitial extends AuthenticationState {
  AuthenticationInitial(
      {super.status = AuthenticationStatus.init,
      required super.user,
      required super.centre,
      required super.deviceID});
}
