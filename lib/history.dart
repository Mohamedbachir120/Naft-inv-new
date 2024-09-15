import 'dart:convert';

import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:naftinv/all_objects.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/detailBien.dart';
import 'package:naftinv/main.dart';
import 'package:naftinv/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sqflite/sqflite.dart';

import 'data/User.dart';
import 'package:path/path.dart';

void main() {
  runApp(const History());
}

class History extends StatelessWidget {
  const History({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HistoryPage(title: 'naftinvAppScann');
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<Bien_materiel> list;
  late List<Bien_materiel> tempList = [];

  late Localisation loc;
  late User user;
  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);
  var _currentIndex = 1;
  TextEditingController codeBar = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  Widget BienWidget(Bien_materiel bien, BuildContext context) {
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
            Colors.white,
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
              children: [
                Icon(Icons.timer),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Scanné le :",
                  style: textStyle,
                ),
                Text(
                  bien.date_scan.toString(),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton.icon(
                      onPressed: () async {
                        bool deleted =
                            await Bien_materiel.deleteBien(bien.code_bar);
                        if (deleted == true) {
                          final snackBar = SnackBar(
                            content: const Text(
                              'Bien supprimé avec succès',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyApp(),
                              ),
                              (route) => false);
                        }
                      },
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(color: Colors.white),
                        backgroundColor: Colors.red,
                      ),
                      icon: Icon(Icons.delete),
                      label: Text("Supprimer")),
                ),
                TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailBienPage(
                            bien: bien,
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

  Future<List> fetchBien(BuildContext context) async {
    user = await User.auth();
    list = await Bien_materiel.history();
    list = list.reversed.toList();
    if (list.length > 0) {
      loc = await Localisation.get_localisation(list[0].code_localisation);
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchBien(context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && list.length > 0) {
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
                  padding: EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(color: Color.fromARGB(255, 244, 246, 247)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history, size: 30, color: blue),
                          Text(
                            "Historique des articles",
                            style: TextStyle(
                                fontSize: 20,
                                color: blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.green,
                        child: IconButton(
                            onPressed: () async {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.sync,
                                        color: Colors.black87, size: 25),
                                    Text(
                                      "Synchronisation en cours",
                                      style: TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                                backgroundColor:
                                    Color.fromARGB(255, 214, 214, 214),
                              ));
                              List<Bien_materiel> objects =
                                  await Bien_materiel.synchonized_objects();
                              List<Non_Etiquete> object2 =
                                  await Non_Etiquete.synchonized_objects();
                              User user = await User.auth();
                              Dio dio = Dio();
                              dio.options.headers["Authorization"] =
                                  'Bearer ' + await user.getToken();
                              String imeiNo =
                                  await DeviceInformation.deviceIMEINumber;
                              var response = await dio.post(
                                  '${LARAVEL_ADDRESS}api/save_many/${imeiNo}',
                                  data: jsonEncode(objects));

                              response = await dio.post(
                                  '${LARAVEL_ADDRESS}api/save_manyNonEtiqu/${imeiNo}',
                                  data: jsonEncode(object2));

                              if (response.toString() == "true") {
                                final database = openDatabase(join(
                                    await getDatabasesPath(),
                                    'naftinv_scan.db'));
                                final db = await database;
                                await db.rawUpdate(
                                    "UPDATE Bien_materiel SET stockage = 1 where stockage = 0");

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check,
                                          color: Colors.white, size: 25),
                                      Text(
                                        "Synchronisation effectuée avec succès",
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                ));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.info,
                                          color: Colors.white, size: 25),
                                      Text(
                                        "une erreur est survenue veuillez réessayer",
                                        style: TextStyle(fontSize: 17.0),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            },
                            icon: Icon(
                              Icons.sync_sharp,
                              size: 20,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
                Container(
                    child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        onChanged: ((value) {
                          setState(() {
                            tempList = list.where((element) {
                              return element.code_bar.contains(value);
                            }).toList();
                          });
                        }),
                        controller: codeBar,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          labelText: "Code bar",
                          hintText: "Code bar",
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          //fillColor: Colors.green
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    )
                  ],
                )),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 250,
                  child: codeBar.text.trim().length == 0
                      ? ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return (BienWidget(list[index], context));
                          },
                          physics: ScrollPhysics(),
                        )
                      : ListView.builder(
                          itemCount: tempList.length,
                          itemBuilder: (context, index) {
                            return (BienWidget(tempList[index], context));
                          },
                          physics: ScrollPhysics(),
                        ),
                ),
              ],
            )),
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
                      MaterialPageRoute(builder: (context) => BiensPage()),
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
        } else if (snapshot.connectionState == ConnectionState.done &&
            list.length == 0) {
          return Scaffold(
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                      child: Icon(
                    Icons.history,
                    size: 35,
                  )),
                  Center(
                      child: Text(
                    "La liste d'historique est vide",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ))
                ],
              ),
            ),
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
                      MaterialPageRoute(builder: (context) => BiensPage()),
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
        } else {
          return Scaffold(
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 244, 246, 247)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, size: 30, color: blue),
                            Text(
                              "Historique des articles",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.green,
                          child: IconButton(
                              onPressed: () async {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.sync,
                                          color: Colors.black87, size: 25),
                                      Text(
                                        "Synchronisation en cours",
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  backgroundColor:
                                      Color.fromARGB(255, 214, 214, 214),
                                ));
                                List<Bien_materiel> objects =
                                    await Bien_materiel.synchonized_objects();
                                List<Non_Etiquete> object2 =
                                    await Non_Etiquete.synchonized_objects();
                                User user = await User.auth();
                                Dio dio = Dio();
                                dio.options.headers["Authorization"] =
                                    'Bearer ' + await user.getToken();
                                String imeiNo =
                                    await DeviceInformation.deviceIMEINumber;
                                var response = await dio.post(
                                    '${LARAVEL_ADDRESS}api/save_many/${imeiNo}',
                                    data: jsonEncode(objects));

                                response = await dio.post(
                                    '${LARAVEL_ADDRESS}api/save_manyNonEtiqu/${imeiNo}',
                                    data: jsonEncode(object2));

                                if (response.toString() == "true") {
                                  final database = openDatabase(join(
                                      await getDatabasesPath(),
                                      'naftinv_scan.db'));
                                  final db = await database;
                                  await db.rawUpdate(
                                      "UPDATE Bien_materiel SET stockage = 1 where stockage = 0");

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.check,
                                            color: Colors.white, size: 25),
                                        Text(
                                          "Synchronisation effectuée avec succès",
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.info,
                                            color: Colors.white, size: 25),
                                        Text(
                                          "une erreur est survenue veuillez réessayer",
                                          style: TextStyle(fontSize: 17.0),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              },
                              icon: Icon(
                                Icons.sync_sharp,
                                size: 20,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                  ),
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
