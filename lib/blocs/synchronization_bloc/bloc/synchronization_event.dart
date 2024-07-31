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
