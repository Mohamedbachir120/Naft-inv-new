import 'dart:async';

import 'package:flutter/services.dart';
import 'package:naftinv/blocs/choix_structure/choix_structure_bloc.dart';
import 'package:naftinv/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

class ChoixStructureRepository {
  ChoixStructureRepository({required this.db});
  final Database db;
  List<String> structures = [];
  String selectedStructure = "";
  int YEAR = DateTime.now().year;

  final _controller = StreamController<ChoixStructureStatus>();

  Stream<ChoixStructureStatus> get status async* {
    if (!_controller.isClosed) {
      getStatus();
    }

    yield* _controller.stream;
  }

  Future<void> getStatus() async {
    _controller.add(ChoixStructureStatus.pending);
    try {
      final List<Map<String, dynamic>> Struct = await db.query(
          'T_E_LOCATION_LOC',
          distinct: true,
          columns: ['COP_ID', 'COP_LIB']);
      structures = List.generate(Struct.length, (i) {
        return "${Struct[i]['COP_ID']} - ${Struct[i]['COP_LIB']}";
      });
      _controller.add(ChoixStructureStatus.loaded);
    } catch (e) {
      print(e.toString());
      _controller.add(ChoixStructureStatus.failed);
    }
  }

  void selectStructure(String s) {
    _controller.add(ChoixStructureStatus.editing);

    selectedStructure = s;
    _controller.add(ChoixStructureStatus.loaded);
  }

  void changeYear(int y) {
    _controller.add(ChoixStructureStatus.editing);

    YEAR = y;
    _controller.add(ChoixStructureStatus.loaded);
  }
}
