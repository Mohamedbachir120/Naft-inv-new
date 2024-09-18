import 'dart:async';

import 'package:naftinv/blocs/settings_bloc/bloc/settings_bloc.dart';
import 'package:sqflite/sqflite.dart';

class Settingsrepository {
  final Database db;
  Settingsrepository({required this.db});
  bool flash = false;
  int modeScan = 1;
  int lecteur = 1;

  final _controller = StreamController<SettingStatus>();

  Stream<SettingStatus> get status async* {
    if (!_controller.isClosed) {
      getStatus();
    }

    yield* _controller.stream;
  }

  Future<void> getStatus() async {
    _controller.add(SettingStatus.pending);
    final List<Map<String, dynamic>> devices =
        await db.rawQuery('SELECT * FROM "DEVICE"');
    if (devices.isNotEmpty) {
      lecteur = devices[0]["SCANNER"];
    }
    _controller.add(SettingStatus.success);
  }

  Future<void> updateLecteur(int newLecteur) async {
    _controller.add(SettingStatus.pending);
    lecteur = newLecteur;
    await db.rawUpdate('''
                      UPDATE DEVICE 
                      SET SCANNER = ?
                      ''', [newLecteur]);

    _controller.add(SettingStatus.success);
  }

  void updateModeScan(int newMode) {
    _controller.add(SettingStatus.pending);
    modeScan = newMode;
    _controller.add(SettingStatus.success);
  }

  void updateFlash() {
    _controller.add(SettingStatus.pending);

    flash = !flash;
    _controller.add(SettingStatus.success);
  }
}
