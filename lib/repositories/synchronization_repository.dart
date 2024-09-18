import 'dart:async';
import 'dart:convert';

import 'package:device_information/device_information.dart';
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
  SynchronizationRepository({required this.db});
  String deviceID = "";
  String filter = "";
  String keyword = "";
  String structure = "";

  List<Equipe> equipes = [];
  List<Localisation> localisations = [];
  List<Localisation> original = [];
  List<String> natures = [];
  Localisation? defaultLocalisation;
  final _controller = StreamController<SynchronizationStatus>();

  Stream<SynchronizationStatus> get status async* {
    if (!_controller.isClosed) {
      getStatus();
    }

    yield* _controller.stream;
  }

  Future<void> getStatus() async {
    String deviceID = await DeviceInformation.deviceIMEINumber;
    String structure = await User.getStructure();

    final List<Map<String, dynamic>> naturesQ = await db.query(
        'FIM_IMMOBILISATION',
        distinct: true,
        columns: ['FIM_ID', 'FIM_LIB']);
    natures = List.generate(naturesQ.length, (i) {
      return "${naturesQ[i]['FIM_ID']} ${naturesQ[i]['FIM_LIB']}";
    });
    if (deviceID != "" && structure != "") {
      print("##_ device id exist and structure ");
      if (await User.check_user() != 0) {
        print("##_ user authenticated ");

        List<Bien_materiel> biens = await Bien_materiel.all_objects(db);
        List<Non_Etiquete> sns = await Non_Etiquete.synchonized_objects(db);
        final List<Map<String, dynamic>> maps =
            await db.query("T_E_LOCATION_LOC where COP_ID = '$structure' ");
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
        print(original);
        _controller.add(SynchronizationStatus.success);
      } else {
        try {
          print("##_ getting data from server ");

          var dio = Dio();
          var response = await dio.post(
            '${LARAVEL_ADDRESS}api/auth/signin',
            data: {"email": "999999", "password": "a", 'code': deviceID},
          );

          final token = response.data["token"];
          dio.options.headers["Authorization"] = 'Bearer ' + await token;

          response = await dio.get(
              '${LARAVEL_ADDRESS}api/localite_par_centre/$structure',
              queryParameters: {'code': deviceID});
          List temp = response.data;
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
              "DELETE FROM T_E_LOCATION_LOC WHERE COP_ID = '$STRUCTURE' ;");
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
    // if (keyword.length == 0) {
    //   localisations = original;
    // } else {
    //   localisations = original
    //       .where((e) =>
    //           e.code_bar.contains(keyword) || e.designation.contains(keyword))
    //       .toList();
    // }
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

  void addBien(Bien_materiel bien) async {
    _controller.add(SynchronizationStatus.searching);

    var maps = await db.query("Bien_materiel");
    // await db.query("Bien_materiel where code_bar  = '$code_bar'  ");
    print("##_ $maps");

    bien.Store_Bien();
    localisations = localisations.map((e) {
      if (e.code_bar == bien.code_localisation) {
        e = e.copyWith(biens: [bien, ...e.biens]);
        return e;
      } else {
        return e;
      }
    }).toList();
    _controller.add(SynchronizationStatus.success);
  }

  void addSn(Non_Etiquete sn) {
    _controller.add(SynchronizationStatus.searching);
    sn.Store_Non_Etique();
    localisations = localisations.map((e) {
      if (e.code_bar == sn.code_localisation) {
        return e.copyWith(nonEtiqu: [sn, ...e.nonEtiqu]);
      } else {
        return e;
      }
    }).toList();
    _controller.add(SynchronizationStatus.success);
  }

  Future<void> synchronize() async {
    _controller.add(SynchronizationStatus.loading);
    List<Bien_materiel> objects = await Bien_materiel.synchonized_objects(db);
    List<Non_Etiquete> object2 = await Non_Etiquete.synchonized_objects(db);
    User user = await User.auth();
    Dio dio = Dio();
    try {
      dio.options.headers["Authorization"] = 'Bearer ${await user.getToken()}';
      String imeiNo = await DeviceInformation.deviceIMEINumber;

      var response = await dio.post('${LARAVEL_ADDRESS}api/save_many/$imeiNo',
          data: jsonEncode(objects));

      response = await dio.post(
          '${LARAVEL_ADDRESS}api/save_manyNonEtiqu/$imeiNo',
          data: jsonEncode(object2));

      if (response.toString() == "true") {
        final database = openDatabase(join(await getDatabasesPath(), DBNAME));
        final db = await database;
        await db.rawUpdate(
            "UPDATE Bien_materiel SET stockage = 1 where stockage = 0");
      }
      _controller.add(SynchronizationStatus.synchronized);
    } catch (e) {
      await refreshToken();
      try {
        dio.options.headers["Authorization"] =
            'Bearer ${await user.getToken()}';
        String imeiNo = await DeviceInformation.deviceIMEINumber;

        var response = await dio.post(
            '${LARAVEL_ADDRESS}api/save_many/$imeiNo',
            data: jsonEncode(objects));

        response = await dio.post(
            '${LARAVEL_ADDRESS}api/save_manyNonEtiqu/$imeiNo',
            data: jsonEncode(object2));

        if (response.toString() == "true") {
          final database = openDatabase(join(await getDatabasesPath(), DBNAME));
          final db = await database;
          await db.rawUpdate(
              "UPDATE Bien_materiel SET stockage = 1 where stockage = 0");
        }
      } catch (e) {
        _controller.add(SynchronizationStatus.failed);
      }
    }
  }

  void setDefaultLocalisation(Localisation loc) {
    _controller.add(SynchronizationStatus.searching);

    defaultLocalisation = loc;
    _controller.add(SynchronizationStatus.success);
  }

  Future<void> refreshToken() async {
    final Dio dio = Dio();
    User user = await User.auth();
    try {
      var response = await dio.post('${LARAVEL_ADDRESS}api/auth/refresh_token',
          data: {"refresh_token": user.refresh_token});

      // Update the token in your authentication repository after refreshing
      user.token = response.data['access_token'];
      user.refresh_token = response.data['refresh_token'];

      db.insert('User', user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print("############# Token refreshed successfully.");
    } catch (e) {
      print("############### Error refreshing token: ${e.toString()}");
    }
  }
}
