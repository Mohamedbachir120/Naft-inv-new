part of 'choix_structure_bloc.dart';

@immutable
sealed class ChoixStructureEvent {}

class ChoixStructureStatusChanged extends ChoixStructureEvent {
  final ChoixStructureStatus status;
  ChoixStructureStatusChanged({required this.status});
}

class ChoixStructurePickStructure extends ChoixStructureEvent {
  final String structure;

  ChoixStructurePickStructure({required this.structure});
}

class ChoixStructurePickYear extends ChoixStructureEvent {
  final int year;

  ChoixStructurePickYear({required this.year});
}
