import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:naftinv/all_non_etique.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/operations.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path/path.dart';
import 'dart:math';

import 'package:naftinv/main.dart';
import 'package:sqflite/sqflite.dart';

class Create_Non_etiqu extends StatefulWidget {
  final String localite;

  const Create_Non_etiqu({required this.localite});
  @override
  _Create_Non_etiquState createState() =>
      _Create_Non_etiquState(localite: this.localite);
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

class _Create_Non_etiquState extends State<Create_Non_etiqu> {
  final String localite;
  _Create_Non_etiquState({required this.localite});
  int _value = 1;
  TextEditingController codeBar = TextEditingController();
  List<String> Localites = [];
  List<String> Natures = [];

  TextEditingController nomController = TextEditingController();
  TextEditingController num_versionController = TextEditingController();
  TextEditingController marqueController = TextEditingController();
  TextEditingController modeleController = TextEditingController();
  TextEditingController natureController = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    print(localite);
    super.initState();
  }

  Future<int> getItems() async {
    User user = await User.auth();
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> Struct = await db.query(
        'T_E_LOCATION_LOC where COP_ID = "${user.COP_ID}"',
        distinct: true,
        columns: ['LOC_ID']);

    Localites = List.generate(Struct.length, (i) {
      return "${Struct[i]['LOC_ID']}";
    });
    final List<Map<String, dynamic>> natures = await db.query(
        'FIM_IMMOBILISATION',
        distinct: true,
        columns: ['FIM_ID', 'FIM_LIB']);
    Natures = List.generate(natures.length, (i) {
      return "${natures[i]['FIM_ID']} ${natures[i]['FIM_LIB']}";
    });

    return Localites.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('naftinv Scanner', style: TextStyle(color: yellow)),
          backgroundColor: blue,
        ),
        body: Builder(builder: (BuildContext context) {
          return FutureBuilder(
            future: getItems(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                Color.fromRGBO(235, 242, 250, 1),
                                Color.fromRGBO(235, 242, 250, 0.7),
                                Color.fromRGBO(235, 242, 250, 0.5)
                              ])),
                          margin: EdgeInsets.only(bottom: 15),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: blue,
                              ),
                              Expanded(
                                child: Text(
                                  "Ajouter un article non etiqueté",
                                  style: TextStyle(color: blue, fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                              localite == ""
                                  ? Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      alignment: Alignment.center,
                                      child: EasyAutocomplete(
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.home_sharp,
                                            color: Colors.black,
                                          ),
                                          labelText: "Code localité",
                                          labelStyle:
                                              TextStyle(color: Colors.black),

                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          //fillColor: Colors.green
                                        ),
                                        suggestions: Localites,
                                        onChanged: (value) => setState(() {
                                          codeBar.text = value;
                                        }),
                                        onSubmitted: (value) =>
                                            (value) => setState(() {
                                                  codeBar.text = value;
                                                }),
                                      ))
                                  : Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(children: [
                                        Expanded(
                                          flex: 1,
                                          child: Icon(
                                            Icons.home_sharp,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                            flex: 5,
                                            child: Text(
                                              localite,
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20),
                                            ))
                                      ]),
                                    ),
                              Container(
                                  padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                                  alignment: Alignment.center,
                                  child: EasyAutocomplete(
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.badge,
                                        color: Colors.black,
                                      ),
                                      labelText: "Nature d'article",
                                      labelStyle:
                                          TextStyle(color: Colors.black),

                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    suggestions: Natures,
                                    onChanged: (value) => setState(() {
                                      natureController.text = value;
                                    }),
                                    onSubmitted: (value) =>
                                        (value) => setState(() {
                                              natureController.text = value;
                                            }),
                                  )),
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: TextFormField(
                                    controller: num_versionController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.numbers,
                                        color: Colors.black,
                                      ),
                                      labelText: "Numéro de série",
                                      hintText: "example : 1234898374",
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                  )),
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: TextFormField(
                                    controller: marqueController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.ballot_rounded,
                                        color: Colors.black,
                                      ),
                                      labelText: "Marque",
                                      hintText: "Marque d'article",
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                  )),
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: TextFormField(
                                    controller: modeleController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.merge_type_sharp,
                                        color: Colors.black,
                                      ),
                                      labelText: "Modèle",
                                      hintText: "Modèle d'article",
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                  )),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.format_list_numbered),
                                      Text(
                                        "Nombre d'article ",
                                        style: TextStyle(fontSize: 18),
                                      )
                                    ]),
                              ),
                              Builder(builder: (context) {
                                return NumberPicker(
                                  value: _value,
                                  minValue: 0,
                                  maxValue: 20,
                                  onChanged: (value) =>
                                      setState(() => _value = value),
                                );
                              }),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                          textStyle:
                                              TextStyle(color: Colors.white),
                                          backgroundColor: Colors.green
                                          // Text Color
                                          ),
                                      icon: Icon(Icons.check,
                                          color: Colors.white),
                                      label: Text("Valider"),
                                      onPressed: () async {
                                        var cond = (localite != "" ||
                                            (check_format(0, codeBar.text)) ==
                                                true);

                                        if (cond &&
                                            natureController.text
                                                    .trim()
                                                    .length >
                                                0 &&
                                            num_versionController.text
                                                    .trim()
                                                    .length >
                                                0 &&
                                            (localite != "" ||
                                                codeBar.text.trim().length >
                                                    0)) {
                                          User user = await User.auth();
                                          var num_serie = (num_versionController
                                                      .text.length <
                                                  5)
                                              ? generateRandomString(12)
                                              : num_versionController.text;
                                          Non_Etiquete etiqu = Non_Etiquete(
                                              num_serie,
                                              MODE_SCAN,
                                              DateTime.now().toIso8601String(),
                                              localite == ""
                                                  ? codeBar.text
                                                  : localite,
                                              0,
                                              user.COP_ID,
                                              user.matricule,
                                              marqueController.text,
                                              modeleController.text,
                                              natureController.text,
                                              _value);

                                          etiqu.date_scan = etiqu.date_format();

                                          bool stored =
                                              await etiqu.Store_Non_Etique();

                                          if (stored == true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SNsPage(),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.info,
                                                      color: Colors.white,
                                                      size: 25),
                                                  Text(
                                                    "une erreur est survenue veuillez réessayer",
                                                    style: TextStyle(
                                                        fontSize: 17.0),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.red,
                                            ));
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.info,
                                                    color: Colors.white,
                                                    size: 25),
                                                Text(
                                                  "Veuillez remplir tous les champs",
                                                  style:
                                                      TextStyle(fontSize: 17.0),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      },
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                ));
              } else {
                return Scaffold(
                    body: Container(
                  child: Column(
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
                ));
              }
            },
          );
        }));
  }
}
// ignore_for_file: prefer_const_constructors