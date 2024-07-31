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
            centre: authenticationRepository.centre,
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.initial,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword)) {
    on<SynchronizationStatusChanged>(_onSynchronizationStatusChanged);
    on<SynchronizationRequestSearch>(_onSynchronizationRequestSearch);
    on<SynchronizationRequestFilter>(_onSynchronizationRequestFilter);
    on<SynchronizationAddBien>(_onSynchronizationAddBien);
    on<SynchronizationAddSn>(_onSynchronizationAddSn);

    _synchronizationStatusSubscription =
        synchronizationRepository.status.listen(
      (status) => add(SynchronizationStatusChanged(status: status)),
    );
  }
  late StreamSubscription<SynchronizationStatus>
      _synchronizationStatusSubscription;

  @override
  Future<void> close() {
    _synchronizationStatusSubscription.cancel();
    return super.close();
  }

  void _onSynchronizationStatusChanged(SynchronizationStatusChanged event,
      Emitter<SynchronizationState> emit) async {
    switch (event.status) {
      case SynchronizationStatus.initial:
        return emit(SynchronizationInitial(
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.initial,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword));
      case SynchronizationStatus.loading:
        return emit(SynchronizationInitial(
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.loading,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword));
      case SynchronizationStatus.success:
        return emit(SynchronizationInitial(
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.success,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword));
      case SynchronizationStatus.failed:
        return emit(SynchronizationInitial(
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.failed,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword));
      case SynchronizationStatus.searching:
        return emit(SynchronizationInitial(
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.searching,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword));
      case SynchronizationStatus.found:
        return emit(SynchronizationInitial(
            equipes: synchronizationRepository.equipes,
            localites: synchronizationRepository.localisations,
            status: SynchronizationStatus.found,
            centre: authenticationRepository.centre,
            filter: synchronizationRepository.filter,
            keyword: synchronizationRepository.keyword));
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
}
