import 'dart:async';

import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

class AuthenticationRepository {
  AuthenticationRepository({required this.db});
  final Database db;
  final _controller = StreamController<AuthenticationStatus>();
  User? user;
  String centre = '';
  String deviceId = '';
  int year = DateTime.now().year;
  Stream<AuthenticationStatus> get status async* {
    if (!_controller.isClosed) {
      getStatus();
    }

    yield* _controller.stream;
  }

  Future<int> getStatus() async {
    try {
      int nb = 0;

      if (await Permission.phone.request().isGranted) {
        String imeiNo = await DeviceInformation.deviceIMEINumber;
        deviceId = imeiNo;
        Dio dio = Dio();
        try {
          final List<Map<String, dynamic>> devices = await db
              .query("DEVICE where IMEI = '${imeiNo}' and IS_VALID = 1");

          if (devices.length == 0) {
            var response =
                await dio.get("${LARAVEL_ADDRESS}api/is_enabled?code=$imeiNo");
            if (response.data["is_enabled"] == 0) {
              _controller.add(AuthenticationStatus.uncheckedDevice);
              return 1;
            } else {
              db.insert('DEVICE', {"IMEI": imeiNo, "IS_VALID": 1},
                  conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        } catch (e) {
          print(e);
          _controller.add(AuthenticationStatus.noInternet);
          return 1;
        }
      } else {
        _controller.add(AuthenticationStatus.permissionNotGaranted);

        return 1;
      }
      final List<Map<String, dynamic>> maps = await db.query('User');

      nb = maps.length;
      if (nb > 0) {
        User localUser = User(
            maps[0]['matricule'],
            maps[0]['nom'],
            maps[0]['COP_ID'],
            maps[0]['INV_ID'],
            maps[0]["validity"],
            maps[0]["token"]);
        user = localUser;
        centre = user?.COP_ID ?? "";
        DateTime date =
            DateTime.parse(user?.validity ?? DateTime.now().toString());
        DateTime now = DateTime.now();
        print("$now ${user?.validity}");
        print("cconnected ");
        if (date.isAfter(now)) {
          centre = user!.COP_ID;
          user = localUser;
          _controller.add(AuthenticationStatus.authenticated);
        } else {
          nb = 0;
          await db.execute("DELETE FROM User;");
          _controller.add(AuthenticationStatus.init);
        }
      } else {
        _controller.add(AuthenticationStatus.init);
      }
    } catch (e) {
      print(e.toString());
    }
    return 0;
  }

  void setStructure(String struct, int y) async {
    centre = struct;
    year = y;
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("T_E_LOCATION_LOC where COP_ID = '$centre'; ");
    if (maps.length > 0) {
      _controller.add(AuthenticationStatus.centreSelected);
    }
  }

  void attemptAuthentication(String matricule, String password) async {
    if (matricule.trim().length > 5 &&
        password.trim() == "a" &&
        matricule.trim() != "999999") {
      final database = openDatabase(join(await getDatabasesPath(), DBNAME));

      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
          "T_E_GROUPE_INV where EMP_ID = '$matricule' and YEAR = $year and COP_ID = '$centre' ");

      if (maps.length > 0) {
        user = User(
            maps[0]["EMP_ID"],
            maps[0]["EMP_FULLNAME"],
            centre,
            maps[0]["INV_ID"],
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            "");
        print(user?.validity);
        try {
          String token = await user?.save_token() ?? "";
          user?.token = token;
        } catch (e) {
          print(e.toString());
        }
        db.insert('User', user!.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        _controller.add(AuthenticationStatus.authenticated);
      } else {
        _controller.add(AuthenticationStatus.centreSelected);
      }
    } else {
      _controller.add(AuthenticationStatus.centreSelected);
    }
  }
}
