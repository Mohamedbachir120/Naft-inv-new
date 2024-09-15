part of 'synchronization_bloc.dart';

@immutable
sealed class SynchronizationEvent {}

class SynchronizationStatusChanged extends SynchronizationEvent {
  final SynchronizationStatus status;
  SynchronizationStatusChanged({required this.status});
}

class SynchronizationRequestSearch extends SynchronizationEvent {
  final String keyword;

  SynchronizationRequestSearch({required this.keyword});
}

class SynchronizationRequestFilter extends SynchronizationEvent {
  final String filter;
  SynchronizationRequestFilter({required this.filter});
}

class SynchronizationAddBien extends SynchronizationEvent {
  final Bien_materiel bien;
  SynchronizationAddBien({required this.bien});
}

class SynchronizationAddSn extends SynchronizationEvent {
  final Non_Etiquete sn;
  SynchronizationAddSn({required this.sn});
}

class SynchronizationDefaultLocalite extends SynchronizationEvent {
  final Localisation loc;
  SynchronizationDefaultLocalite({required this.loc});
}

class SynchronizationStart extends SynchronizationEvent {
  SynchronizationStart();
}

class SynchronizationRefresh extends SynchronizationEvent {
  SynchronizationRefresh();
}
