import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:naftinv/all_objects.dart';
import 'package:naftinv/create_Non_etiqu.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/detail_bien.dart';
import 'package:naftinv/history.dart';
import 'package:naftinv/main.dart';
import 'package:naftinv/mode_manuel_bien.dart';
import 'package:naftinv/operations.dart';
import 'package:sqflite/sqflite.dart';
import 'data/User.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:path/path.dart';

class Detail_Operation extends StatefulWidget {
  const Detail_Operation({Key? key, required this.localisation})
      : super(key: key);

  final Localisation localisation;
  @override
  _Detail_OperationState createState() =>
      _Detail_OperationState(localisation: this.localisation);
}

class _Detail_OperationState extends State<Detail_Operation> {
  _Detail_OperationState({required this.localisation});
  String _scanBarcode = '';
  final Localisation localisation;
  var _currentIndex = 2;
  int _value = MODE_SCAN;
  bool visible = false;
  bool show_detail = false;
  bool flash = false;
  late User user;
  late int nb_objects;
  TextEditingController nomController = TextEditingController();
  List<Bien_materiel> list_objects = [];

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
  }

  Future<int> get_user() async {
    if (list_objects.isEmpty) {
      user = await User.auth();
      ;

      list_objects = await Localisation.get_linked_Object(localisation.code_bar);
      list_objects = list_objects.reversed.toList();
      nb_objects = list_objects.length;
    }

    return nb_objects;
  }

  String date_format(String date) {
    DateTime day = DateTime.parse(date);

    return "${day.day}/${day.month}/${day.year}    ${day.hour}:${day.minute}";
  }

  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  Widget BienWidget(Bien_materiel bien) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.white70, spreadRadius: 1),
        ],
        gradient: LinearGradient(
          // ignore: prefer_const_literals_to_create_immutables
          colors: [
            Colors.white60,
            Colors.white60,
            Color.fromARGB(255, 238, 238, 238),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.qr_code),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Code bar :",
                  style: textStyle,
                ),
                Text(
                  bien.code_bar,
                  style: textStyle,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (context) => Detail_Bien(
                            bien_materiel: bien,
                            localisation: localisation,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(color: Colors.white),
                      backgroundColor: blue,
                    ),
                    icon: Icon(Icons.book),
                    label: Text("Détail"))
              ],
            ),
          )
        ],
      ),
    );
  }

  String get_etat() {
    switch (MODE_SCAN) {
      case 1:
        return "Bon";
      case 2:
        return "Hors service";
      case 3:
        return "A réformer";
    }
    return "";
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
            child: FutureBuilder(
                future: get_user(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
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
                                            " Détail Localité",
                                            style: TextStyle(
                                                color: blue, fontSize: 20.0),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                        color: flash == true
                                            ? blue
                                            : Colors.amberAccent,
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
                                          'Code bar : ${localisation.code_bar}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.home),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${localisation.cop_id} - ${localisation.cop_lib}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.home_work),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${localisation.designation}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Icon(Icons.format_list_numbered),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Nombre des articles :',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          nb_objects.toString(),
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 241, 241, 241)),
                                    padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                                    child: Row(children: [
                                      Icon(
                                        Icons.add,
                                        size: 25,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Ajouter des articles",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ]),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.rate_review),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Etat d'article",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            )
                                          ],
                                        ),
                                        Flex(
                                          direction: Axis.horizontal,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Column(children: [
                                                ListTile(
                                                  title: Text(
                                                    '',
                                                  ),
                                                  leading: Radio(
                                                    value: 3,
                                                    groupValue: _value,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _value = val as int;
                                                        MODE_SCAN = _value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Text('A réformer')
                                              ]),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(children: [
                                                ListTile(
                                                  title: Text(
                                                    '',
                                                  ),
                                                  leading: Radio(
                                                    value: 2,
                                                    groupValue: _value,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _value = val as int;
                                                        MODE_SCAN = _value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Text('Hors service')
                                              ]),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    ListTile(
                                                      title: Text(
                                                        '',
                                                      ),
                                                      leading: Radio(
                                                        value: 1,
                                                        groupValue: _value,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            _value = val as int;
                                                            MODE_SCAN = _value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Text('Bon         ')
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton.icon(
                                            style: TextButton.styleFrom(
                                                textStyle:
                                                    TextStyle(color: blue),
                                                backgroundColor: yellow),
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ModeManuelBien(
                                                          localisation:
                                                              localisation,
                                                        )),
                                              );
                                            },
                                            icon: Icon(Icons.front_hand),
                                            label: Text("Saisir code bar")),
                                        TextButton.icon(
                                            style: TextButton.styleFrom(
                                                textStyle: TextStyle(
                                                    color: Colors.white),
                                                backgroundColor: blue),
                                            onPressed: () async {
                                              await scanBarcodeNormal(context);
                                            },
                                            icon: Icon(Icons.camera_alt),
                                            label: Text("Scanner article"))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: TextButton.icon(
                                        style: TextButton.styleFrom(
                                            textStyle:
                                                TextStyle(color: Colors.white),
                                            backgroundColor: Colors.redAccent),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Create_Non_etiqu(
                                                      localite:
                                                          localisation.code_bar,
                                                    )),
                                          );
                                        },
                                        icon: Icon(Icons.add),
                                        label: Text("un article SN")),
                                  )
                                ],
                              ),
                            ),
                            Card(
                                child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 241, 241, 241)),
                                    padding: EdgeInsets.fromLTRB(5, 5, 10, 5),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Icon(
                                              Icons.list_alt,
                                              size: 25,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("Inventaires",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ]),
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  show_detail = !show_detail;
                                                });
                                              },
                                              icon: (show_detail == true)
                                                  ? Icon(
                                                      Icons
                                                          .arrow_drop_up_outlined,
                                                      size: 35,
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .arrow_drop_down_outlined,
                                                      size: 35,
                                                    ))
                                        ]),
                                  ),
                                  Visibility(
                                    visible: show_detail,
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              230,
                                      child: ListView.builder(
                                          itemCount: list_objects.length,
                                          itemBuilder: (context, index) {
                                            return BienWidget(
                                                list_objects[index]);
                                          }),
                                    ),
                                  )
                                ],
                              ),
                            ))
                          ]),
                    );
                  } else {
                    return LinearProgressIndicator();
                  }
                }));
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