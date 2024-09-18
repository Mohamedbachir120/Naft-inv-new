import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:naftinv/repositories/choix_structure_repository.dart';

part 'choix_structure_event.dart';
part 'choix_structure_state.dart';

class ChoixStructureBloc
    extends Bloc<ChoixStructureEvent, ChoixStructureState> {
  final ChoixStructureRepository choixStructureRepository;

  ChoixStructureBloc({required this.choixStructureRepository})
      : super(ChoixStructureInitial(
            selectedStructures: "",
            status: ChoixStructureStatus.initial,
            structures: const [],
            year: DateTime.now().year)) {
    on<ChoixStructureStatusChanged>(_onChoixStructureStatusChanged);
    on<ChoixStructurePickStructure>(_onChoixStructurePickStructure);
    on<ChoixStructurePickYear>(_onChoixStructurePickYear);

    _choixStructureStatusSubscription = choixStructureRepository.status.listen(
      (status) => add(ChoixStructureStatusChanged(status: status)),
    );
  }

  late StreamSubscription<ChoixStructureStatus>
      _choixStructureStatusSubscription;

  @override
  Future<void> close() {
    _choixStructureStatusSubscription.cancel();
    return super.close();
  }

  void _onChoixStructureStatusChanged(
    ChoixStructureStatusChanged event,
    Emitter<ChoixStructureState> emit,
  ) async {
    switch (event.status) {
      case ChoixStructureStatus.initial:
        return emit(ChoixStructureInitial(
            status: ChoixStructureStatus.initial,
            year: DateTime.now().year,
            structures: const [],
            selectedStructures: ""));
      case ChoixStructureStatus.pending:
        return emit(ChoixStructureInitial(
            status: ChoixStructureStatus.pending,
            year: DateTime.now().year,
            structures: const [],
            selectedStructures: ""));
      case ChoixStructureStatus.loaded:
        return emit(ChoixStructureInitial(
            status: ChoixStructureStatus.loaded,
            year: choixStructureRepository.YEAR,
            structures: choixStructureRepository.structures,
            selectedStructures: choixStructureRepository.selectedStructure));
      case ChoixStructureStatus.failed:
        return emit(ChoixStructureInitial(
            status: ChoixStructureStatus.failed,
            year: DateTime.now().year,
            structures: const [],
            selectedStructures: ""));
      case ChoixStructureStatus.editing:
        return emit(ChoixStructureInitial(
            status: ChoixStructureStatus.editing,
            year: choixStructureRepository.YEAR,
            structures: choixStructureRepository.structures,
            selectedStructures: choixStructureRepository.selectedStructure));
    }
  }

  _onChoixStructurePickStructure(
      ChoixStructurePickStructure event, Emitter<ChoixStructureState> emitter) {
    choixStructureRepository.selectStructure(event.structure);
  }

  _onChoixStructurePickYear(
      ChoixStructurePickYear event, Emitter<ChoixStructureState> emitter) {
    choixStructureRepository.changeYear(event.year);
  }
}
