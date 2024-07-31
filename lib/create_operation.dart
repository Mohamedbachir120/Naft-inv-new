import 'package:flutter/material.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/detail_operation.dart';

void main() => runApp(Create_Operation());

class Create_Operation extends StatefulWidget {
  @override
  _Create_OperationState createState() => _Create_OperationState();
}

class _Create_OperationState extends State<Create_Operation> {
  late Localisation loc;
  TextEditingController nomController = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
  }

  bool check_format(int type, String value) {
    if (type == 0) {
      // Expression réguliére pour les localisations

      final localisation = RegExp(r'^[a-zA-Z]{2}[0-9]{14}$');

      return localisation.hasMatch(value);
    } else if (type == 1) {
      // Expression réguliére pour les bien Matériaux

      final BienMateriel = RegExp(r'^[a-zA-Z]{1}[0-9]{14}$');

      return BienMateriel.hasMatch(value);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    loc = ModalRoute.of(context)!.settings.arguments as Localisation;

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
                        Icon(
                          Icons.add,
                          color: blue,
                        ),
                        Text(
                          " L'ajout d'une nouvelle localisation",
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
                                'Localisation : ${loc.code_bar}',
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
                                  bool stored = await loc.exists();

                                  if (stored == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Detail_Operation(
                                          localisation: loc,
                                        ),
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