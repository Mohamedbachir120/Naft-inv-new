part of 'choix_structure_bloc.dart';

@immutable
sealed class ChoixStructureState {}

enum ChoixStructureStatus { initial, pending, loaded, failed, editing }

final class ChoixStructureInitial extends ChoixStructureState {
  final ChoixStructureStatus status;
  final List<String> structures;
  final String selectedStructures;
  final int year;

  ChoixStructureInitial(
      {required this.selectedStructures,
      required this.status,
      required this.structures,
      required this.year});

  @override
  List<Object> get props => [status, structures, selectedStructures, year];
}
