import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:naftinv/blocs/settings_bloc/settingsRepository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final Settingsrepository settingsrepository;

  SettingsBloc({required this.settingsrepository})
      : super(SettingsInitial(
            status: SettingStatus.intial,
            flash: settingsrepository.flash,
            modeScan: settingsrepository.modeScan,
            lecteur: settingsrepository.lecteur)) {
    on<SettingStatusChanged>(_onSettingStatusChanged);
    on<SettingsUpdateFlash>(_onSettingsUpdateFlash);
    on<SettingsUpdateMode>(_onSettingsUpdateMode);
    on<SettingsUpdateLecteur>(_onSettingsUpdateLecteur);

    _settingsStatusSubscription = settingsrepository.status.listen(
      (status) => add(SettingStatusChanged(status: status)),
    );
  }

  late StreamSubscription<SettingStatus> _settingsStatusSubscription;

  void _onSettingStatusChanged(
      SettingStatusChanged event, Emitter<SettingsState> emit) {
    switch (event.status) {
      case SettingStatus.intial:
        return emit(SettingsInitial(
            flash: settingsrepository.flash,
            lecteur: settingsrepository.lecteur,
            modeScan: settingsrepository.modeScan,
            status: SettingStatus.intial));
      case SettingStatus.pending:
        return emit(SettingsInitial(
            flash: settingsrepository.flash,
            lecteur: settingsrepository.lecteur,
            modeScan: settingsrepository.modeScan,
            status: SettingStatus.pending));
      case SettingStatus.success:
        return emit(SettingsInitial(
            flash: settingsrepository.flash,
            lecteur: settingsrepository.lecteur,
            modeScan: settingsrepository.modeScan,
            status: SettingStatus.success));
      case SettingStatus.error:
        return emit(SettingsInitial(
            flash: settingsrepository.flash,
            lecteur: settingsrepository.lecteur,
            modeScan: settingsrepository.modeScan,
            status: SettingStatus.error));
    }
  }

  void _onSettingsUpdateFlash(
      SettingsUpdateFlash event, Emitter<SettingsState> emit) {
    settingsrepository.updateFlash();
  }

  void _onSettingsUpdateMode(
      SettingsUpdateMode event, Emitter<SettingsState> emit) {
    settingsrepository.updateModeScan(event.modeScan);
  }

  void _onSettingsUpdateLecteur(
      SettingsUpdateLecteur event, Emitter<SettingsState> emit) {
    settingsrepository.updateLecteur(event.lecteur);
  }

  @override
  Future<void> close() {
    _settingsStatusSubscription.cancel();
    return super.close();
  }
}
