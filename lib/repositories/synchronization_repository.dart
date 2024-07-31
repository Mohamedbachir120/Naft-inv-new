import 'dart:async';

import 'package:dio/dio.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Equipe.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SynchronizationRepository {
  final Database db;
  SynchronizationRepository(
      {required this.deviceID, required this.structure, required this.db});
  final String deviceID;
  String filter = "";
  String keyword = "";
  final String structure;

  List<Equipe> equipes = [];
  List<Localisation> localisations = [];
  List<Localisation> original = [];
  final _controller = StreamController<SynchronizationStatus>();

  Stream<SynchronizationStatus> get status async* {
    if (!_controller.isClosed) {
      getStatus();
    }

    yield* _controller.stream;
  }

  Future<void> getStatus() async {
    print("calling get status synchronization");
    if (deviceID != "" && structure != "") {
      if (await User.check_user() != 0) {
        List<Bien_materiel> biens = await Bien_materiel.all_objects();
        List<Non_Etiquete> sns = await Non_Etiquete.synchonized_objects();
        final List<Map<String, dynamic>> maps =
            await db.query("T_E_LOCATION_LOC where COP_ID = '$structure' ");
        print(maps);
        localisations = List.generate(maps.length, (i) {
          return Localisation(
              maps[i]['LOC_ID'],
              maps[i]['LOC_LIB'],
              maps[i]['COP_LIB'],
              maps[i]['COP_ID'],
              biens
                  .where((ele) => ele.code_localisation == maps[i]['LOC_ID'])
                  .toList(),
              sns
                  .where((ele) => ele.code_localisation == maps[i]['LOC_ID'])
                  .toList());
        });
        original = localisations;
        print(localisations);

        _controller.add(SynchronizationStatus.success);
      } else {
        try {
          var dio = Dio();
          print("this is device id $deviceID");
          var response = await dio.post(
            '${LARAVEL_ADDRESS}api/auth/signin',
            data: {"email": "999999", "password": "a", 'code': deviceID},
          );
          print(response.data);
          final token = response.data["token"];
          dio.options.headers["Authorization"] = 'Bearer ' + await token;

          response = await dio.get(
              '${LARAVEL_ADDRESS}api/localite_par_centre/$structure',
              queryParameters: {'code': deviceID});
          List temp = response.data;
          print(response.data);
          localisations = List.generate(temp.length, (i) {
            return Localisation(temp[i]['loc_ID'], temp[i]['loc_LIB'],
                temp[i]['cop_LIB'], temp[i]['cop_ID'], [], []);
          });
          original = localisations;

          response = await dio.get(
              '${LARAVEL_ADDRESS}api/equipeParCentre/$structure',
              queryParameters: {'code': deviceID});
          temp = response.data;

          equipes = List.generate(temp.length, (i) {
            return Equipe(
                YEAR: temp[i]['year'] ?? "",
                INV_ID: temp[i]['inv_ID'] ?? "",
                COP_ID: temp[i]['cop_ID'] ?? "",
                EMP_ID: temp[i]['emp_ID'] ?? "",
                EMP_FULLNAME: temp[i]['emp_FULLNAME'] ?? "",
                JOB_LIB: temp[i]['job_LIB'] ?? "",
                GROUPE_ID: temp[i]['groupe_ID'] ?? "",
                EMP_IS_MANAGER: temp[i]['emp_IS_MANAGER'] ?? "");
          });

          var batch = db.batch();
          batch.execute(
              "DELETE FROM T_E_LOCATION_LOC WHERE COP_ID = '${STRUCTURE}' ;");
          batch.execute("DELETE FROM T_E_GROUPE_INV;");

          for (var item in localisations) {
            batch.insert('T_E_LOCATION_LOC', item.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
          for (var item in equipes) {
            batch.insert('T_E_GROUPE_INV', item.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          }

          await batch.commit(noResult: true);

          _controller.add(SynchronizationStatus.success);
        } catch (e) {
          print(e.toString());
          _controller.add(SynchronizationStatus.failed);
        }
      }
    }
  }

  void search(String key) {
    _controller.add(SynchronizationStatus.searching);

    keyword = key;
    if (keyword.length == 0) {
      localisations = original;
    } else {
      localisations = original
          .where((e) =>
              e.code_bar.contains(keyword) || e.designation.contains(keyword))
          .toList();
    }
    _controller.add(SynchronizationStatus.success);
  }

  void activeFilter(String param) {
    _controller.add(SynchronizationStatus.searching);
    filter = param;

    if (param == "ASC") {
      localisations = original;

      localisations.sort((a, b) => a.designation.compareTo(b.designation));
    } else if (param == "DESC") {
      localisations = original;
      localisations.sort((a, b) => a.designation.compareTo(b.designation));
      localisations = localisations.reversed.toList();
    } else {
      localisations = original;
    }
    _controller.add(SynchronizationStatus.success);
  }
}
