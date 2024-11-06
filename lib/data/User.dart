import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:naftinv/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  late String matricule;
  late String nom;
  late String COP_ID;
  late String INV_ID;
  late String validity;
  late String token;
  late String refresh_token;

  User(String matricule, String nom, String COP_ID, String INV_ID,
      String validity, String token, String refresh_token) {
    this.matricule = matricule;
    this.nom = nom;
    this.COP_ID = COP_ID;
    this.INV_ID = INV_ID;
    this.validity = validity;
    this.token = token;
    this.refresh_token = refresh_token;
  }

  Map<String, dynamic> toMap() {
    return {
      'matricule': matricule,
      'nom': nom,
      'COP_ID': COP_ID,
      'INV_ID': INV_ID,
      "validity": validity,
      "token": token,
      "refresh_token": refresh_token
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
    return User(
        maps[0]['matricule'],
        maps[0]['nom'],
        maps[0]['COP_ID'],
        maps[0]['INV_ID'],
        maps[0]["validity"],
        maps[0]["token"],
        maps[0]["refresh_token"]);
  }

  Future<void> save_token(Database db, String password) async {
    String imeiNo = await DeviceInformation.deviceIMEINumber;
    try {
      var dio = Dio();

      final response = await dio.post(
        '${LARAVEL_ADDRESS}api/auth/signin',
        data: {"email": matricule, "password": password, "code": imeiNo},
      );
      final data = response.data;
      token = data["token"];
      refresh_token = data["refresh_token"];
      db.insert('User', toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {

      var dio = Dio();

      final response = await dio.post(
        '${LARAVEL_ADDRESS}api/auth/register',
        data: {
          "name": matricule,
          "email": matricule,
          "password": "a",
          "code": imeiNo
        },
      );
      token = response.data["token"];
      refresh_token = response.data["refresh_token"];
      db.insert('User', toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<String> getToken() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('User');

      return maps[0]["token"];
    } catch (e) {
      return "";
    }
  }

  static Future<String> getStructure() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getString("structure") ?? "";
    } catch (e) {
      return "";
    }
  }

  @override
  String toString() {
    return 'User{matricule: $matricule, name: $nom}';
  }
}
