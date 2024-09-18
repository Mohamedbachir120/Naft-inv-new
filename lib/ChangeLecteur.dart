import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:naftinv/all_objects.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/data/Localisation.dart';

import 'package:naftinv/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:path/path.dart';

import 'data/User.dart';
import 'main.dart';

void main() {
  runApp(const ChangeLecteur());
}

class ChangeLecteur extends StatelessWidget {
  const ChangeLecteur({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChangeLecteurPage(title: 'naftinvAppScann');
  }
}

class ChangeLecteurPage extends StatefulWidget {
  const ChangeLecteurPage({super.key, required this.title});

  final String title;

  @override
  State<ChangeLecteurPage> createState() => _ChangeLecteurPageState();
}

class _ChangeLecteurPageState extends State<ChangeLecteurPage> {
  late List<Non_Etiquete> list;
  late Localisation loc;
  late User user;
  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);
  final _currentIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  TextStyle textStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  Future<int> fetchActiveLecteur(BuildContext context) async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;
    final List<Map<String, dynamic>> devices =
        await db.rawQuery('SELECT * FROM "DEVICE"');
    if (devices.isNotEmpty) {
      return devices[0]['SCANNER'];
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchActiveLecteur(context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('naftinv Scanner',
                  style: TextStyle(color: yellow)),
              backgroundColor: blue,
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration:
                      const BoxDecoration(color: Color.fromARGB(255, 244, 246, 247)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bar_chart, size: 30, color: blue),
                          Text(
                            "Choix du lecteur",
                            style: TextStyle(
                                fontSize: 20,
                                color: blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: blue, width: 1.0)),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        color: blue,
                        size: 28,
                      ),
                      const Text(
                        'Ancien lecteur',
                        style: TextStyle(
                            fontSize: 25,
                            color: blue,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextButton(
                                onPressed: () async {
                                  final database = openDatabase(
                                      join(await getDatabasesPath(), DBNAME));
                                  final db = await database;
                                  await db.rawUpdate('''
                                                UPDATE DEVICE 
                                                SET SCANNER = ?
                                                ''', [1]);
                                  setState(() {
                                    fetchActiveLecteur(context);
                                  });
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.green)),
                                child: const Text(
                                  "Choisir",
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              flex: 2,
                              child: TextButton(
                                  onPressed: () async {
                                    String barcodeScanRes = "";
                                    barcodeScanRes =
                                        await FlutterBarcodeScanner.scanBarcode(
                                            '#ff6666',
                                            'Cancel',
                                            true,
                                            ScanMode.BARCODE);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.check,
                                              color: Colors.white, size: 25),
                                          Text(
                                            " Code obtenu : $barcodeScanRes",
                                            style: const TextStyle(fontSize: 17.0),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                    ));
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all(
                                              Colors.amber)),
                                  child: const Text(
                                    "Tester",
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.020),
                              padding: const EdgeInsets.all(0),
                              height:
                                  MediaQuery.of(context).size.height * 0.045,
                              width: MediaQuery.of(context).size.height * 0.045,
                              decoration: BoxDecoration(
                                  color:
                                      snapshot.data == 1 ? blue : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.height *
                                          0.05),
                                  border: Border.all(color: blue)),
                              child: Icon(
                                Icons.check,
                                color: snapshot.data == 1 ? Colors.white : blue,
                                size: 14,
                              ))
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: blue, width: 1.0)),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.camera_outlined,
                        color: blue,
                        size: 28,
                      ),
                      const Text(
                        'Nouveau lecteur',
                        style: TextStyle(
                            fontSize: 25,
                            color: blue,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextButton(
                                onPressed: () async {
                                  final database = openDatabase(
                                      join(await getDatabasesPath(), DBNAME));
                                  final db = await database;
                                  await db.rawUpdate('''
                                                UPDATE DEVICE 
                                                SET SCANNER = ?
                                                ''', [0]);
                                  setState(() {
                                    fetchActiveLecteur(context);
                                  });
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.green)),
                                child: const Text(
                                  "Choisir",
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              flex: 2,
                              child: TextButton(
                                  onPressed: () async {
                                    final result = await BarcodeScanner.scan(
                                      options: const ScanOptions(
                                        autoEnableFlash: true,
                                        android: AndroidOptions(
                                          aspectTolerance: 0.00,
                                          useAutoFocus: true,
                                        ),
                                      ),
                                    );
                                    String barcodeScanRes = result.rawContent;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.check,
                                              color: Colors.white, size: 25),
                                          Text(
                                            " Code obtenu : $barcodeScanRes",
                                            style: const TextStyle(fontSize: 17.0),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                    ));
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all(
                                              Colors.amber)),
                                  child: const Text(
                                    "Tester",
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.020),
                              padding: const EdgeInsets.all(0),
                              height:
                                  MediaQuery.of(context).size.height * 0.045,
                              width: MediaQuery.of(context).size.height * 0.045,
                              decoration: BoxDecoration(
                                  color:
                                      snapshot.data == 0 ? blue : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.height *
                                          0.05),
                                  border: Border.all(color: blue)),
                              child: Icon(
                                Icons.check,
                                color: snapshot.data == 0 ? Colors.white : blue,
                                size: 14,
                              ))
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
            bottomNavigationBar: SalomonBottomBar(
              currentIndex: _currentIndex,
              onTap: (i) {
                switch (i) {
                  case 0:
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                      ModalRoute.withName('/'),
                    );
                    break;

                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangeLecteur()),
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BiensPage()),
                    );
                    break;
                }
              },
              items: [
                /// Home
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home),
                  title: const Text("Accueil"),
                  selectedColor: const Color.fromARGB(255, 4, 50, 88),
                ),

                /// Search
                SalomonBottomBarItem(
                  icon: const Icon(Icons.bar_chart),
                  title: const Text("Choix Lecteur"),
                  selectedColor: const Color.fromARGB(255, 4, 50, 88),
                ),

                /// Profile
                SalomonBottomBarItem(
                  icon: const Icon(Icons.storage),
                  title: const Text("Serveur"),
                  selectedColor: const Color.fromARGB(255, 4, 50, 88),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: Container(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                        height: 5,
                        width: double.infinity,
                        child: LinearProgressIndicator()),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
