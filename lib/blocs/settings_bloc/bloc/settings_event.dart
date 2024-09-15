part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {}

class SettingStatusChanged extends SettingsEvent {
  final SettingStatus status;
  SettingStatusChanged({required this.status});
}

class SettingsUpdateLecteur extends SettingsEvent {
  final int lecteur;

  SettingsUpdateLecteur({required this.lecteur});
}

class SettingsUpdateFlash extends SettingsEvent {
  SettingsUpdateFlash();
}

class SettingsUpdateMode extends SettingsEvent {
  final int modeScan;

  SettingsUpdateMode({required this.modeScan});
}
