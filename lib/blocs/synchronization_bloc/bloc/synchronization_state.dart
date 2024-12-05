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
  locationServiceDisabled
}

final class SynchronizationInitial extends SynchronizationState {
  final SynchronizationStatus status;
  final List<Equipe> equipes;
  final String centre;
  final String keyword;
  final String filter;
  final Localisation? localisation;
  final List<String> natures;
  final double? pos1;
  final double? pos2;

  SynchronizationInitial(
      {required this.equipes,
      required this.status,
      required this.centre,
      required this.filter,
      required this.keyword,
      required this.localisation,
      required this.natures,
      required this.pos1,
      required this.pos2});
}
