import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:naftinv/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  late String matricule;
  late String nom;
  late String COP_ID;
  late String INV_ID;
  late String validity;
  late String token;

  User(String matricule, String nom, String COP_ID, String INV_ID,
      String validity, String token) {
    this.matricule = matricule;
    this.nom = nom;
    this.COP_ID = COP_ID;
    this.INV_ID = INV_ID;
    this.validity = validity;
    this.token = token;
  }

  Map<String, dynamic> toMap() {
    return {
      'matricule': matricule,
      'nom': nom,
      'COP_ID': COP_ID,
      'INV_ID': INV_ID,
      "validity": validity,
      "token": token
    };
  }

  static Future<int> check_user() async {
    try {
      final database = openDatabase(join(await getDatabasesPath(), DBNAME));
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query('User');

      return maps.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<User> auth() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('User');
    return User(maps[0]['matricule'], maps[0]['nom'], maps[0]['COP_ID'],
        maps[0]['INV_ID'], maps[0]["validity"], maps[0]["token"]);
  }

  Future<String> save_token() async {
    String imeiNo = await DeviceInformation.deviceIMEINumber;
    try {
      var dio = Dio();

      final response = await dio.post(
        '${LARAVEL_ADDRESS}api/auth/signin',
        data: {"email": this.matricule, "password": "a", "code": imeiNo},
      );
      final data = response.data;
      return (data["token"]).toString();
    } catch (e) {
      var dio = Dio();

      final response = await dio.post(
        '${LARAVEL_ADDRESS}api/auth/register',
        data: {
          "name": this.matricule,
          "email": this.matricule,
          "password": "a",
          "code": imeiNo
        },
      );
      return response.data["token"].toString();
    }
  }

  Future<String> getToken() async {
    try {
      final database = openDatabase(join(await getDatabasesPath(), DBNAME));
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query('User');
      if (maps[0]["token"] == "") {
        return await save_token();
      }
      return maps[0]["token"];
    } catch (e) {
      return await save_token();
    }
  }

  static Future<String> getStructure() async {
    try {
      final database = openDatabase(join(await getDatabasesPath(), DBNAME));
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query('User');
      return maps[0]["COP_ID"];
    } catch (e) {
      return "";
    }
  }

  @override
  String toString() {
    return 'User{matricule: $matricule, name: $nom}';
  }
}
