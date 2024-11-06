import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Equipe.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/repositories/authentication_repository.dart';
import 'package:naftinv/repositories/synchronization_repository.dart';

part 'synchronization_event.dart';
part 'synchronization_state.dart';

class SynchronizationBloc
    extends Bloc<SynchronizationEvent, SynchronizationState> {
  final AuthenticationRepository authenticationRepository;
  final SynchronizationRepository synchronizationRepository;

  SynchronizationBloc(
      {required this.authenticationRepository,
      required this.synchronizationRepository})
      : super(SynchronizationInitial(
            natures: synchronizationRepository.natures,
            localisation: synchronizationRepository.defaultLocalisation,
            centre: authenticationRepository.centre,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.initial,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            pos1: synchronizationRepository.pos1,
            pos2: synchronizationRepository.pos2)) {
    on<SynchronizationStatusChanged>(_onSynchronizationStatusChanged);
    on<SynchronizationRequestSearch>(_onSynchronizationRequestSearch);
    on<SynchronizationRequestFilter>(_onSynchronizationRequestFilter);
    on<SynchronizationAddBien>(_onSynchronizationAddBien);
    on<SynchronizationAddSn>(_onSynchronizationAddSn);
    on<SynchronizationDefaultLocalite>(_onSynchronizationDefaultLocalite);
    on<SynchronizationStart>(_onSynchronizationStart);
    on<SynchronizationRefresh>(_onSynchronizationRefresh);

    _synchronizationStatusSubscription =
        synchronizationRepository.status.listen(
      (status) => add(SynchronizationStatusChanged(status: status)),
    );
    synchronizationRepository.startPositionUpdates();
  }
  late StreamSubscription<SynchronizationStatus>
      _synchronizationStatusSubscription;

  @override
  Future<void> close() {
    _synchronizationStatusSubscription.cancel();
    return super.close();
  }

  void _onSynchronizationRefresh(
      SynchronizationRefresh event, Emitter<SynchronizationState> emit) {
    synchronizationRepository.getStatus();
  }

  void _onSynchronizationStatusChanged(SynchronizationStatusChanged event,
      Emitter<SynchronizationState> emit) async {
    switch (event.status) {
      case SynchronizationStatus.initial:
        return emit(SynchronizationInitial(
            localisation: synchronizationRepository.defaultLocalisation,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.initial,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            natures: synchronizationRepository.natures,
            pos1: synchronizationRepository.pos1,
            pos2: synchronizationRepository.pos2));
      case SynchronizationStatus.loading:
        return emit(SynchronizationInitial(
            localisation: synchronizationRepository.defaultLocalisation,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.loading,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            natures: synchronizationRepository.natures,
            pos1: synchronizationRepository.pos1,
            pos2: synchronizationRepository.pos2));
      case SynchronizationStatus.success:
        return emit(SynchronizationInitial(
            localisation: synchronizationRepository.defaultLocalisation,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.success,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            natures: synchronizationRepository.natures,
            pos1: synchronizationRepository.pos1,
            pos2: synchronizationRepository.pos2));
      case SynchronizationStatus.failed:
        return emit(SynchronizationInitial(
            localisation: synchronizationRepository.defaultLocalisation,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.failed,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            natures: synchronizationRepository.natures,
            pos1: synchronizationRepository.pos1,
            pos2: synchronizationRepository.pos2));
      case SynchronizationStatus.searching:
        return emit(SynchronizationInitial(
            localisation: synchronizationRepository.defaultLocalisation,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.searching,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            natures: synchronizationRepository.natures,
            pos1: synchronizationRepository.pos1,
            pos2: synchronizationRepository.pos2));
      case SynchronizationStatus.found:
        return emit(SynchronizationInitial(
            localisation: synchronizationRepository.defaultLocalisation,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.found,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            natures: synchronizationRepository.natures,
            pos1: synchronizationRepository.pos1,
            pos2: synchronizationRepository.pos2));
      case SynchronizationStatus.synchronized:
        return emit(SynchronizationInitial(
            localisation: synchronizationRepository.defaultLocalisation,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.synchronized,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            natures: synchronizationRepository.natures,
            pos1: synchronizationRepository.pos1,
            pos2: synchronizationRepository.pos2));
      case SynchronizationStatus.locationServiceDisabled:
        return emit(SynchronizationInitial(
            localisation: synchronizationRepository.defaultLocalisation,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.locationServiceDisabled,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword,
            natures: synchronizationRepository.natures,
            pos1: null,
            pos2: null));
    }
  }

  void _onSynchronizationRequestSearch(
      SynchronizationRequestSearch event, Emitter<SynchronizationState> emit) {
    synchronizationRepository.search(event.keyword);
  }

  void _onSynchronizationRequestFilter(
      SynchronizationRequestFilter event, Emitter<SynchronizationState> emit) {
    synchronizationRepository.activeFilter(event.filter);
  }

  void _onSynchronizationAddBien(
      SynchronizationAddBien event, Emitter<SynchronizationState> emit) {
    synchronizationRepository.addBien(event.bien);
  }

  void _onSynchronizationAddSn(
      SynchronizationAddSn event, Emitter<SynchronizationState> emit) {
    synchronizationRepository.addSn(event.sn);
  }

  void _onSynchronizationDefaultLocalite(SynchronizationDefaultLocalite event,
      Emitter<SynchronizationState> emit) {
    synchronizationRepository.setDefaultLocalisation(event.loc);
  }

  void _onSynchronizationStart(
      SynchronizationStart event, Emitter<SynchronizationState> emit) {
    synchronizationRepository.synchronize();
  }
}
