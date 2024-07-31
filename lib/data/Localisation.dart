import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Localisation {
  static final TABLENAME = "T_E_LOCATION_LOC";

  late final String code_bar;
  late final String designation;
  late final String cop_lib;
  late final String cop_id;
  late final List<Bien_materiel> biens;
  late final List<Non_Etiquete> nonEtiqu;
  // Constructeur
  Localisation(this.code_bar, this.designation, this.cop_lib, this.cop_id,
      this.biens, this.nonEtiqu);
  Localisation copyWith({
    String? codeBar,
    String? designation,
    String? copLib,
    String? copId,
    List<Bien_materiel>? biens,
    List<Non_Etiquete>? nonEtiqu,
  }) {
    return Localisation(
      codeBar ?? this.code_bar,
      designation ?? this.designation,
      copLib ?? this.cop_lib,
      copId ?? this.cop_id,
      biens ?? this.biens,
      nonEtiqu ?? this.nonEtiqu,
    );
  }

  static Future<Localisation> get_localisation(String code_bar) async {
    User user = await User.auth();
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
        "${TABLENAME} where LOC_ID  = '$code_bar' and  COP_ID = '${user.COP_ID}' ");
    List<Bien_materiel> biens = await get_linked_Object(code_bar);
    List<Non_Etiquete> sns = await get_linked_SN(code_bar);

    return Localisation(maps[0]['LOC_ID'], maps[0]['LOC_LIB'],
        maps[0]['COP_LIB'], maps[0]['COP_ID'], biens, sns);
  }

  //to Json
  Map<String, dynamic> toJson() => {
        'code_bar': code_bar,
      };
  // Maping pour l'insertion dans la base de donnés
  Map<String, dynamic> toMap() {
    return {
      'LOC_ID': code_bar,
      'LOC_LIB': designation,
      'COP_LIB': cop_lib,
      'COP_ID': cop_id
    };
  }

  Future<bool> local_check() async {
    User user = await User.auth();

    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
        "${TABLENAME} where LOC_ID  = '$code_bar' and  COP_ID = '${user.COP_ID}' ");

    return (maps.length > 0);
  }

  Future<bool> exists() async {
    return await local_check();
  }

  static show_localisations() async {
    User user = await User.auth();
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("${TABLENAME} where COP_ID  = '${user.COP_ID}' ");
    return List.generate(maps.length, (i) async {
      List<Bien_materiel> biens = await get_linked_Object(maps[i]['LOC_ID']);
      List<Non_Etiquete> sns = await get_linked_SN(maps[i]['LOC_ID']);

      return Localisation(maps[i]['LOC_ID'], maps[i]['LOC_LIB'],
          maps[i]['COP_LIB'], maps[i]['COP_ID'], biens, sns);
    });
  }

  static Future<List<Localisation>> synchonized_objects(String code_bar) async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("${TABLENAME} where cop_lib  = 0 ");
    List<Bien_materiel> biens = await get_linked_Object(code_bar);
    List<Non_Etiquete> sns = await get_linked_SN(code_bar);

    return List.generate(maps.length, (i) {
      return Localisation(maps[i]['code_bar'], maps[i]['designation'],
          maps[i]['cop_lib'], maps[i]['cop_id'], biens, sns);
    });
  }

  static Future<List<Bien_materiel>> get_linked_Object(String code_bar) async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query("Bien_materiel where code_localisation  = '${code_bar}' ");

    return List.generate(maps.length, (i) {
      return Bien_materiel(
          maps[i]['code_bar'],
          maps[i]['etat'],
          maps[i]['date_scan'],
          maps[i]['code_localisation'],
          maps[i]['stockage'],
          maps[i]['CODE_COP'],
          maps[i]['matricule'],
          maps[i]['inv_id']);
    });
  }

  static Future<List<Non_Etiquete>> get_linked_SN(String code_bar) async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query("Non_Etiquete where code_localisation  = '${code_bar}' ");

    return List.generate(maps.length, (i) {
      return Non_Etiquete(
          maps[i]["num_serie"],
          maps[i]["etat"],
          maps[i]["date_scan"],
          maps[i]["code_localisation"],
          maps[i]["stockage"],
          maps[i]["CODE_COP"],
          maps[i]["matricule"],
          maps[i]["marque"],
          maps[i]["modele"],
          maps[i]["nature"],
          maps[i]["nombre"]);
    });
  }

  Future<int> count_linked_object() async {
    List<Bien_materiel> list = await get_linked_Object(code_bar);
    return list.length;
  }

  @override
  String toString() {
    return 'Localisationcode bar: ${code_bar}';
  }
}
