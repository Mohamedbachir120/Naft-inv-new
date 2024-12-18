import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/repositories/authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository authenticationRepository;
  AuthenticationBloc({required this.authenticationRepository})
      : super(AuthenticationInitial(
            centre: '',
            user: null,
            deviceID: authenticationRepository.deviceId)) {
    // TODO: implement event handler
    on<AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<SelectStructure>(_onSelectStructure);
    on<SubmitAuthentication>(_onSubmitAuthentication);
    on<AuthenticationSignOut>(_onAuthenticationSignOut);
    on<AuthenticationRefresh>(_onAuthenticationRefresh);
    on<SubmitImmobilisationAuthentication>(
        _onSubmitAuthenticationImmobilisation);

    _authenticationStatusSubscription = authenticationRepository.status.listen(
      (status) => add(AuthenticationStatusChanged(status: status)),
    );
  }

  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    return super.close();
  }

  void _onAuthenticationStatusChanged(
    AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    switch (event.status) {
      case AuthenticationStatus.init:
        return emit(AuthenticationInitial(
            user: null,
            centre: '',
            deviceID: authenticationRepository.deviceId));
      case AuthenticationStatus.authenticated:
        return emit(AuthenticationInitial(
            status: AuthenticationStatus.authenticated,
            user: authenticationRepository.user,
            centre: authenticationRepository.centre,
            deviceID: authenticationRepository.deviceId));

      case AuthenticationStatus.centreSelected:
        return emit(AuthenticationInitial(
            status: AuthenticationStatus.centreSelected,
            centre: authenticationRepository.centre,
            user: null,
            deviceID: authenticationRepository.deviceId));
      case AuthenticationStatus.uncheckedDevice:
        return emit(AuthenticationInitial(
            status: AuthenticationStatus.uncheckedDevice,
            centre: authenticationRepository.centre,
            user: null,
            deviceID: authenticationRepository.deviceId));
      case AuthenticationStatus.noInternet:
        return emit(AuthenticationInitial(
            status: AuthenticationStatus.noInternet,
            centre: authenticationRepository.centre,
            user: null,
            deviceID: authenticationRepository.deviceId));
      case AuthenticationStatus.permissionNotGaranted:
        return emit(AuthenticationInitial(
            status: AuthenticationStatus.permissionNotGaranted,
            centre: authenticationRepository.centre,
            user: null,
            deviceID: authenticationRepository.deviceId));
      case AuthenticationStatus.authFailedImmo:
        return emit(AuthenticationInitial(
            status: AuthenticationStatus.authFailedImmo,
            user: authenticationRepository.user,
            centre: authenticationRepository.centre,
            deviceID: authenticationRepository.deviceId));
      case AuthenticationStatus.authenticatedImmo:
        return emit(AuthenticationInitial(
            status: AuthenticationStatus.authenticatedImmo,
            user: authenticationRepository.user,
            centre: authenticationRepository.centre,
            deviceID: authenticationRepository.deviceId));
      case AuthenticationStatus.incorrectVersion:
        return emit(AuthenticationInitial(
            status: AuthenticationStatus.incorrectVersion,
            user: authenticationRepository.user,
            centre: authenticationRepository.centre,
            deviceID: authenticationRepository.deviceId));
    }
  }

  void _onAuthenticationRefresh(
      AuthenticationRefresh event, Emitter<AuthenticationState> emit) {
    authenticationRepository.getStatus();
  }

  void _onSelectStructure(
      SelectStructure event, Emitter<AuthenticationState> emit) {
    authenticationRepository.setStructure(event.centre, event.year);
  }

  void _onSubmitAuthentication(
      SubmitAuthentication event, Emitter<AuthenticationState> emit) {
    authenticationRepository.attemptAuthentication(
        event.matricule, event.password);
  }

  void _onAuthenticationSignOut(
      AuthenticationSignOut event, Emitter<AuthenticationState> emit) {
    authenticationRepository.signOut();
  }

  void _onSubmitAuthenticationImmobilisation(
      SubmitImmobilisationAuthentication event,
      Emitter<AuthenticationState> emit) {
    authenticationRepository.attemptAuthenticationImmobilisation(
        centre: event.centre,
        username: event.matricule,
        password: event.password);
  }
}
