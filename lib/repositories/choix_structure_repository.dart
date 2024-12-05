import 'dart:async';

import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:naftinv/blocs/choix_structure/choix_structure_bloc.dart';
import 'package:naftinv/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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
      // final List<Map<String, dynamic>> Struct = await db.query(
      //     'T_E_LOCATION_LOC',
      //     distinct: true,
      //     columns: ['COP_ID', 'COP_LIB']);
      // structures = List.generate(Struct.length, (i) {
      //   return "${Struct[i]['COP_ID']} - ${Struct[i]['COP_LIB']}";
      // });
      await getStructures();
      _controller.add(ChoixStructureStatus.loaded);
    } catch (e) {
      _controller.add(ChoixStructureStatus.failed);
    }
  }

  Future<void> getStructures() async {
    try {
      Dio dio = Dio();
      String imeiNo = await DeviceInformation.deviceIMEINumber;

      var response = await dio.post(
        '${LARAVEL_ADDRESS}api/auth/signin',
        data: {"email": "999999", "password": "a", 'code': imeiNo},
      );

      final token = response.data["token"];
      dio.options.headers["Authorization"] = 'Bearer ' + await token;
      var centresRes =
          await dio.get("${LARAVEL_ADDRESS}api/centres?code=$imeiNo");
      structures = (centresRes.data as List<dynamic>).map((item) {
        return "${item['COP_ID']} - ${item['COP_LIB']}";
      }).toList();
    } catch (e) {
      print("###### $e");
    }
  }

  void selectStructure(String s) async {
    final prefs = await SharedPreferences.getInstance();

    _controller.add(ChoixStructureStatus.editing);

    selectedStructure = s;
    prefs.setString('structure', selectedStructure);
    _controller.add(ChoixStructureStatus.loaded);
  }

  void changeYear(int y) {
    _controller.add(ChoixStructureStatus.editing);

    YEAR = y;
    _controller.add(ChoixStructureStatus.loaded);
  }
}
