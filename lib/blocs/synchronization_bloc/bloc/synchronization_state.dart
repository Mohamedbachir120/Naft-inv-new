part of 'synchronization_bloc.dart';

@immutable
sealed class SynchronizationState {}

enum SynchronizationStatus {
  initial,
  loading,
  searching,
  found,
  success,
  failed
}

final class SynchronizationInitial extends SynchronizationState {
  final SynchronizationStatus status;
  final List<Equipe> equipes;
  final List<Localisation> localites;
  final String centre;
  final String keyword;
  final String filter;

  SynchronizationInitial(
      {required this.equipes,
      required this.localites,
      required this.status,
      required this.centre,
      required this.filter,
      required this.keyword});
}
