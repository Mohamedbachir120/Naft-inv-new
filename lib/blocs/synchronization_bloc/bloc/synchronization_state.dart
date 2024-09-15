part of 'synchronization_bloc.dart';

@immutable
sealed class SynchronizationState {}

enum SynchronizationStatus {
  initial,
  loading,
  searching,
  found,
  success,
  failed,
  synchronized,
}

final class SynchronizationInitial extends SynchronizationState {
  final SynchronizationStatus status;
  final List<Equipe> equipes;
  final List<Localisation> localites;
  final String centre;
  final String keyword;
  final String filter;
  final Localisation? localisation;
  final List<String> natures;

  SynchronizationInitial(
      {required this.equipes,
      required this.localites,
      required this.status,
      required this.centre,
      required this.filter,
      required this.keyword,
      required this.localisation,
      required this.natures});
}
