import 'dart:async';
import 'dart:convert';

import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/constante.dart';
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
  double? pos1;
  double? pos2;
  Timer? _positionTimer;

  final _controller = StreamController<SynchronizationStatus>();

  Stream<SynchronizationStatus> get status async* {
    print(status);
    if (!_controller.isClosed) {
      getStatus();
    }

    yield* _controller.stream;
  }

  Future<void> startPositionUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Notify the user that location services are disabled
      _controller.add(SynchronizationStatus.locationServiceDisabled);
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return;
    }

    // If permission is granted, start the timer to retrieve the position

    _positionTimer?.cancel(); // Cancel any previous timer if active
    _positionTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      _controller.add(SynchronizationStatus.searching);

      Position? position = await GetPosition();
      pos1 = position?.latitude;
      pos2 = position?.longitude;

      // Notify listeners (Bloc) about the updated position
      _controller.add(SynchronizationStatus.found);
    });
  }

  void stopPositionUpdates() {
    _positionTimer?.cancel();
  }

  Future<void> getStatus() async {
    deviceID = await DeviceInformation.deviceIMEINumber;

    String structure = await User.getStructure();

    final List<Map<String, dynamic>> naturesQ = await db.query(
        'FIM_IMMOBILISATION',
        distinct: true,
        columns: ['FIM_ID', 'FIM_LIB']);
    natures = List.generate(naturesQ.length, (i) {
      return "${naturesQ[i]['FIM_ID']} ${naturesQ[i]['FIM_LIB']}";
    });
    List<Bien_materiel> biens = await Bien_materiel.all_objects(db);
    List<Non_Etiquete> sns = await Non_Etiquete.synchonized_objects(db);
    if (deviceID != "" && structure != "") {
      if (await User.check_user() != 0) {
        print(
            "##_ user Authenticated on Sync get status object found ${sns.length} ${biens.length}");
        final List<Map<String, dynamic>> maps =
            await db.query("T_E_LOCATION_LOC where COP_ID = '$structure' ");
        print("#### ${maps.length}");
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
        _controller.add(SynchronizationStatus.success);
      } else {
        try {
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
            return Localisation(
                temp[i]['loc_ID'],
                temp[i]['loc_LIB'],
                temp[i]['cop_LIB'],
                temp[i]['cop_ID'],
                biens
                    .where((ele) => ele.code_localisation == temp[i]['loc_ID'])
                    .toList(),
                sns
                    .where((ele) => ele.code_localisation == temp[i]['loc_ID'])
                    .toList());
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
          batch.delete('T_E_LOCATION_LOC',
              where: 'COP_ID = ?', whereArgs: [structure]);
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

    // Sort a copy so "no filter" can still restore the original order.
    localisations = List.of(original);
    if (param == "ASC") {
      localisations.sort((a, b) => a.designation.compareTo(b.designation));
    } else if (param == "DESC") {
      localisations.sort((a, b) => b.designation.compareTo(a.designation));
    }
    _controller.add(SynchronizationStatus.success);
  }

  Future<void> addBien(Bien_materiel bien) async {
    _controller.add(SynchronizationStatus.searching);

    // await db.query("Bien_materiel where code_bar  = '$code_bar'  ");
    Bien_materiel stored = bien.copyWith(latitude: pos1, longitude: pos2);

    await stored.storeBien();
    localisations = localisations.map((e) {
      if (e.code_bar == bien.code_localisation &&
          e.biens
              .where((bienSearch) => bienSearch.code_bar == bien.code_bar)
              .toList()
              .isEmpty) {
        return e.copyWith(biens: [bien, ...e.biens]);
      } else {
        return e;
      }
    }).toList();
    _controller.add(SynchronizationStatus.success);
  }

  void addSn(Non_Etiquete sn) {
    _controller.add(SynchronizationStatus.searching);
    Non_Etiquete newSn = sn.copyWith(latitude: pos1, longitude: pos2);
    newSn.Store_Non_Etique();
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

    try {
      await _uploadPending(objects, object2);
    } catch (e) {
      await refreshToken();
      try {
        await _uploadPending(objects, object2);
      } catch (e) {
        _controller.add(SynchronizationStatus.failed);
        return;
      }
    }
    _controller.add(SynchronizationStatus.synchronized);
    _controller.add(SynchronizationStatus.success);
  }

  /// Sends all local items to the server and marks each table as sent
  /// once the server has accepted it.
  Future<void> _uploadPending(
      List<Bien_materiel> biens, List<Non_Etiquete> nonEtiquetes) async {
    User user = await User.auth();
    Dio dio = Dio();
    dio.options.headers["Authorization"] = 'Bearer ${await user.getToken()}';
    String imeiNo = await DeviceInformation.deviceIMEINumber;

    var response = await dio.post('${LARAVEL_ADDRESS}api/save_many/$imeiNo',
        data: jsonEncode(biens));
    if (response.toString() == "true") {
      await db.rawUpdate(
          "UPDATE Bien_materiel SET stockage = 1 where stockage = 0");
    }

    response = await dio.post('${LARAVEL_ADDRESS}api/save_manyNonEtiqu/$imeiNo',
        data: jsonEncode(nonEtiquetes));
    if (response.toString() == "true") {
      await db.rawUpdate(
          "UPDATE Non_Etiquete SET stockage = 1 where stockage = 0");
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
    } catch (e) {}
  }
}
