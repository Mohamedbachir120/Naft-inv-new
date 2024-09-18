import 'package:flutter/material.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Localisation.dart';

import 'package:naftinv/detailBien.dart';
import 'package:naftinv/main.dart';

class Create_Bien extends StatefulWidget {
  final Localisation localisation;
  const Create_Bien({super.key, required this.localisation});

  @override
  _Create_BienState createState() =>
      _Create_BienState(localisation: localisation);
}

class _Create_BienState extends State<Create_Bien> {
  _Create_BienState({required this.localisation});
  final Localisation localisation;

  late Bien_materiel bien;
  TextEditingController nomController = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bien = ModalRoute.of(context)!.settings.arguments as Bien_materiel;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                      children: const [
                        Icon(
                          Icons.add,
                          color: blue,
                        ),
                        Text(
                          " L'ajout d'un bien matériel",
                          style: TextStyle(color: blue, fontSize: 20.0),
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
                                'Bien Matériel : ${bien.code_bar}',
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
                                'Etat: ${bien.code_bar}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                    textStyle: TextStyle(color: Colors.white),
                                    backgroundColor: Colors.green
                                    // Text Color
                                    ),
                                icon: Icon(Icons.check, color: Colors.white),
                                label: Text("Valider"),
                                onPressed: () async {
                                  bien.etat = MODE_SCAN;

                                  bool stored = await bien.Store_Bien();

                                  if (stored == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailBienPage(
                                          bien: bien,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
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
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ]),
          ));
        }));
  }
}
// ignore_for_file: prefer_const_constructors