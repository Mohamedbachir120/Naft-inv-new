part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {}

enum SettingStatus { intial, pending, success, error }

final class SettingsInitial extends SettingsState {
  final bool flash;
  final int modeScan;
  final int lecteur;
  final SettingStatus status;

  SettingsInitial(
      {required this.flash,
      required this.lecteur,
      required this.modeScan,
      required this.status});
}
