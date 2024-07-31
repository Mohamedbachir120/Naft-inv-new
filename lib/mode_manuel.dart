import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/data/User.dart';
import 'package:path/path.dart';

import 'package:naftinv/detail_operation.dart';
import 'package:naftinv/main.dart';
import 'package:naftinv/operations.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(ModeManuel());

class ModeManuel extends StatefulWidget {
  @override
  _ModeManuelState createState() => _ModeManuelState();
}

class _ModeManuelState extends State<ModeManuel> {
  TextEditingController codeBar = TextEditingController();
  List<String> Localites = [];

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
  }

  String formattedText(String text) {
    String result =
        text.replaceAll('-', "").replaceAll(" ", "").replaceAll("_", "");
    result = result.toUpperCase();

    return result;
  }

  Future<void> Check_localite(BuildContext context) async {
    if (check_format(0, formattedText(codeBar.text)) == false) {
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
      User user = await User.auth();
      Localisation loc = Localisation(
          codeBar.text,
          DateTime.now().toIso8601String(),
          "   ",
          user.COP_ID.toString(),
          await Localisation.get_linked_Object(codeBar.text),
          await Localisation.get_linked_SN(codeBar.text));

      loc.exists().then((exist) async {
        if (exist == true) {
          Localisation localisation =
              await Localisation.get_localisation(codeBar.text);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Detail_Operation(
                      localisation: localisation,
                    ),
                settings: RouteSettings()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.white, size: 25),
                Text(
                  "Localité inexistante",
                  style: TextStyle(fontSize: 17.0),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ));
        }
      });
    }
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
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: blue,
                                ),
                                Text(
                                  " Trouver une localité",
                                  style: TextStyle(color: blue, fontSize: 20.0),
                                )
                              ],
                            ),
                          ),
                          Card(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Container(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 20, 20),
                                      alignment: Alignment.center,
                                      child: EasyAutocomplete(
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.qr_code_2,
                                            color: Colors.black,
                                          ),
                                          labelText: "Code localité",
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                          enabledBorder: InputBorder.none,

                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
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
                                      )),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                              textStyle: TextStyle(
                                                  color: Colors.white),
                                              backgroundColor: Colors.green
                                              // Text Color
                                              ),
                                          icon: Icon(Icons.check,
                                              color: Colors.white),
                                          label: Text("Valider"),
                                          onPressed: () async {
                                            await Check_localite(context);
                                          },
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
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
              }));
        }));
  }
}
// ignore_for_file: prefer_const_constructors