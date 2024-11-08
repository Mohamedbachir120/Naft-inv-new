import 'package:device_information/device_information.dart';
import 'package:intl/intl.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class Bien_materiel {
  /*
  état 1 = Bon 
  état 2 = Hors Service 
  état 3 = A réformer 

  */
  String date_format() {
    DateTime day = DateTime.parse(date_scan);

    return "${day.day}-${day.month}-${day.year}    ${day.hour}:${day.minute}";
  }

  late final String code_bar;

  int etat = 3;
  String date_scan;
  int stockage = 0;
  late String code_localisation;
  late String CODE_COP;
  late String matricule;
  String? inv_id;
  final double? latitude;
  final double? longitude;

  Bien_materiel(
      this.code_bar,
      this.etat,
      this.date_scan,
      this.code_localisation,
      this.stockage,
      this.CODE_COP,
      this.matricule,
      this.inv_id,
      this.latitude,
      this.longitude);

  Bien_materiel copyWith({
    String? code_bar,
    int? etat,
    String? date_scan,
    String? code_localisation,
    int? stockage,
    String? CODE_COP,
    String? matricule,
    String? inv_id,
    double? latitude,
    double? longitude,
  }) {
    return Bien_materiel(
      code_bar ?? this.code_bar,
      etat ?? this.etat,
      date_scan ?? this.date_scan,
      code_localisation ?? this.code_localisation,
      stockage ?? this.stockage,
      CODE_COP ?? this.CODE_COP,
      matricule ?? this.matricule,
      inv_id ?? this.inv_id,
      latitude ?? this.latitude,
      longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "code_bar": code_bar,
      "code_localisation": code_localisation,
      "CODE_COP": CODE_COP,
      "etat": etat,
      "date_scan": date_scan,
      "matricule": matricule,
      "stockage": stockage,
      'inv_id': inv_id,
      'latitude': latitude,
      'longitude': longitude
    };
  }

  Future<bool> local_check() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("Bien_materiel ");

    return maps
        .where((ele) =>
            ele['code_localisation'] == code_localisation &&
            ele["code_bar"] == code_bar)
        .toList()
        .isNotEmpty;
  }

  Future<bool> net_check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        User user = await User.auth();
        Dio dio = Dio();
        dio.options.headers["Authorization"] =
            'Bearer ${await user.getToken()}';
        String imeiNo = await DeviceInformation.deviceIMEINumber;

        final response = await dio.post(
          '${LARAVEL_ADDRESS}api/existeBien/$imeiNo',
          data: toJson(),
        );
        if (response.toString() == "true") {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> exists() async {
    bool local = await local_check();
    bool net = await net_check();

    return local || net;
  }

  String get_state() {
    switch (etat) {
      case 1:
        return "Bon";
      case 2:
        return "Hors service";
      case 3:
        return "A réformer";
    }

    return "";
  }

  Future<bool> Store_Bien() async {
    print("store bien called");
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    User user = await User.auth();
    Dio dio = Dio();
    String imeiNo = await DeviceInformation.deviceIMEINumber;
    try {
      dio.options.headers["Authorization"] = 'Bearer ${await user.getToken()}';

      final response = await dio
          .post('${LARAVEL_ADDRESS}api/create_bien/$imeiNo', data: toJson());
      stockage = 1;
    } catch (e) {
      try {
        await refreshToken(db);
        dio.options.headers["Authorization"] =
            'Bearer ${await user.getToken()}';

        final response = await dio
            .post('${LARAVEL_ADDRESS}api/create_bien/$imeiNo', data: toJson());
        stockage = 1;
      } catch (e) {
        stockage = 0;
      }
    }
    await db.insert('Bien_materiel', toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }

  Future<bool> Store_Bien_Soft() async {
    date_scan = date_format();
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    try {
      if (stockage == 0) {
        db.rawUpdate(
            'UPDATE Bien_materiel SET etat = $MODE_SCAN where code_bar = \'$code_bar\' ');
        return true;
      } else {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          try {
            User user = await User.auth();
            Dio dio = Dio();
            dio.options.headers["Authorization"] =
                'Bearer ${await user.getToken()}';
            String imeiNo = await DeviceInformation.deviceIMEINumber;

            final response = await dio.post(
                '${LARAVEL_ADDRESS}api/create_bien/$imeiNo',
                data: toJson());
            if (response.toString() == "true") {
              db.rawUpdate(
                  'UPDATE Bien_materiel SET etat = $MODE_SCAN where code_bar = \'$code_bar\' ');
              return true;
            } else {
              return false;
            }
          } on DioException {
            print("error");
            return false;
          }
        } else {
          db.rawUpdate(
              'UPDATE Bien_materiel SET etat = $MODE_SCAN where code_bar = \'$code_bar\' ');
          return true;
        }
      }
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> toJson() => {
        "code_bar": code_bar,
        "codelocalisation": code_localisation,
        "code_cop": CODE_COP,
        "etat": etat,
        "date_scan": DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
        "matricule": matricule,
        "stockage": stockage,
        "inv_ID": inv_id,
        "latitude": latitude,
        "longitude": longitude
      };
  static Future<List<Bien_materiel>> history() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query("Bien_materiel");

    return List.generate(maps.length, (i) {
      return Bien_materiel(
          maps[i]["code_bar"],
          maps[i]["etat"],
          maps[i]["date_scan"],
          maps[i]["code_localisation"],
          maps[i]["stockage"],
          maps[i]["CODE_COP"],
          maps[i]["matricule"],
          maps[i]["inv_id"],
          maps[i]['latitude'],
          maps[i]['longitude']);
    });
  }

  static Future<List<Bien_materiel>> synchonized_objects(Database db) async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("Bien_materiel where stockage  = 0 ");

    return List.generate(maps.length, (i) {
      return Bien_materiel(
          maps[i]["code_bar"],
          maps[i]["etat"],
          maps[i]["date_scan"],
          maps[i]["code_localisation"],
          maps[i]["stockage"],
          maps[i]["CODE_COP"],
          maps[i]["matricule"],
          maps[i]["inv_id"],
          maps[i]['latitude'],
          maps[i]['longitude']);
    });
  }

  static Future<List<Bien_materiel>> all_objects(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query("Bien_materiel");

    return List.generate(maps.length, (i) {
      return Bien_materiel(
          maps[i]["code_bar"],
          maps[i]["etat"],
          maps[i]["date_scan"],
          maps[i]["code_localisation"],
          maps[i]["stockage"],
          maps[i]["CODE_COP"],
          maps[i]["matricule"],
          maps[i]["inv_id"],
          maps[i]['latitude'],
          maps[i]['longitude']);
    });
  }

  static Future<bool> deleteBien(String codebar) async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    await db.delete(
      'Bien_materiel',
      // Use a `where` clause to delete a specific dog.
      where: 'code_bar = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [codebar],
    );
    return true;
  }

  @override
  String toString() {
    return '''{ "code_bar": "$code_bar",
            "codelocalisation": "$code_localisation",
            "code_cop": "$CODE_COP",
            "etat": $etat,
            "date_scan": "$date_scan",
            "matricule": "$matricule",
            "stockage": $stockage }''';
  }

  Future<void> refreshToken(Database db) async {
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

String valueState(int a) {
  switch (a) {
    case 1:
      return "Bon";
    case 2:
      return "Hors service";
    case 3:
      return "A réformer";
  }
  return "Bon";
}
