import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:naftinv/all_objects.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/detail_operation.dart';
import 'package:naftinv/history.dart';
import 'package:naftinv/main.dart';
import 'package:naftinv/mode_manuel_bien.dart';
import 'package:naftinv/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'data/Localisation.dart';
import 'data/User.dart';

class Detail_Bien extends StatefulWidget {
  const Detail_Bien(
      {Key? key, required this.bien_materiel, required this.localisation})
      : super(key: key);

  final Bien_materiel bien_materiel;
  final Localisation localisation;

  @override
  _Detail_BienState createState() => _Detail_BienState(
      bien_materiel: this.bien_materiel, localisation: this.localisation);
}

class _Detail_BienState extends State<Detail_Bien> {
  final Localisation localisation;
  _Detail_BienState({required this.bien_materiel, required this.localisation});

  final Bien_materiel bien_materiel;
  var _currentIndex = 2;
  bool flash = false;

  late User user;
  String _scanBarcode = '';
  late int nbrticle;
  Future<int> NBARTICLE() async {
    nbrticle = await localisation.count_linked_object();

    return nbrticle;
  }

  TextEditingController nomController = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanBarcodeNormal(BuildContext context) async {
    User user = await User.auth();
    String barcodeScanRes = "";

    try {
      final database = openDatabase(join(await getDatabasesPath(), DBNAME));
      final db = await database;
      final List<Map<String, dynamic>> devices =
          await db.rawQuery('SELECT * FROM "DEVICE"');
      if (devices.length > 0) {
        if (devices[0]['SCANNER'] == 0) {
          final result = await BarcodeScanner.scan(
            options: ScanOptions(
              autoEnableFlash: flash,
              android: AndroidOptions(
                aspectTolerance: 0.00,
                useAutoFocus: true,
              ),
            ),
          );
          barcodeScanRes = result.rawContent;
        } else {
          barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
              '#ff6666', 'Cancel', true, ScanMode.BARCODE);
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    if (check_format(1, _scanBarcode) == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.info, color: Colors.white, size: 25),
            Text(
              "Opération échouée objet non valide",
              style: TextStyle(fontSize: 17.0),
            ),
          ],
        ),
        backgroundColor: Colors.red,
      ));
    } else {
      Bien_materiel bien = Bien_materiel(
          _scanBarcode,
          MODE_SCAN,
          DateTime.now().toIso8601String(),
          localisation.code_bar,
          0,
          user.COP_ID,
          user.matricule,
          user.INV_ID);

      bool exist = await bien.exists();

      if (exist == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.info, color: Colors.white, size: 25),
              Text(
                "Bien matériel existe déjà",
                style: TextStyle(fontSize: 17.0),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ));
      } else {
        bool stored = await bien.Store_Bien();

        if (stored == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Detail_Bien(
                bien_materiel: bien,
                localisation: localisation,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.white, size: 25),
                Text(
                  "une erreur est survenue veuillez réessayer",
                  style: TextStyle(fontSize: 17.0),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('naftinv Scanner', style: TextStyle(color: yellow)),
        backgroundColor: blue,
      ),
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          child: Row(
                            children: [
                              Icon(
                                Icons.book,
                                color: blue,
                              ),
                              Text(
                                " Détail article",
                                style: TextStyle(color: blue, fontSize: 20.0),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                            color: flash == true ? blue : Colors.amberAccent,
                            onPressed: () => {
                                  setState(() {
                                    flash = !flash;
                                  })
                                },
                            icon: flash == true
                                ? Icon(Icons.flash_on)
                                : Icon(Icons.flash_off)),
                      )
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Icon(Icons.qr_code_2),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Code article : ${bien_materiel.code_bar}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Icon(Icons.emoji_objects),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Etat : ${bien_materiel.get_state()}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Icon(Icons.timer),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Date de scan : ${bien_materiel.date_scan}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Icon(Icons.home),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'code localité : ${bien_materiel.code_localisation}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                          future: NBARTICLE(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                margin: EdgeInsets.all(10),
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Icon(Icons.format_list_numbered),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Nombre d'article scannés: ${nbrticle}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    textStyle: TextStyle(color: Colors.white),
                                    backgroundColor: Colors.blue[800]),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Detail_Operation(
                                        localisation: localisation,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.home_outlined),
                                label: Text("Localité")),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 241, 241, 241)),
                        padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                        child: Row(children: [
                          Icon(
                            Icons.add,
                            size: 25,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Inventaire",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    textStyle: TextStyle(color: blue),
                                    backgroundColor: yellow),
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ModeManuelBien(
                                              localisation: localisation,
                                            )),
                                  );
                                },
                                icon: Icon(Icons.front_hand),
                                label: Text("Saisir code article")),
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    textStyle: TextStyle(color: Colors.white),
                                    backgroundColor: blue),
                                onPressed: () async {
                                  await scanBarcodeNormal(context);
                                },
                                icon: Icon(Icons.camera_alt),
                                label: Text("Scanner un article"))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ));
      }),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                ModalRoute.withName('/'),
              );
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => History()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => All_objects()),
              );
              break;
          }
        },
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Accueil"),
            selectedColor: Color.fromARGB(255, 4, 50, 88),
          ),

          /// Likes

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.history),
            title: Text("Historique"),
            selectedColor: Color.fromARGB(255, 4, 50, 88),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.storage),
            title: Text("Serveur"),
            selectedColor: Color.fromARGB(255, 4, 50, 88),
          ),
        ],
      ),
    );
  }
}
// ignore_for_file: prefer_const_constructors