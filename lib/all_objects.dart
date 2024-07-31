import 'package:flutter/material.dart';

import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/detail_operation.dart';

import 'package:naftinv/history.dart';
import 'package:naftinv/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() {
  runApp(const All_objects());
}

class All_objects extends StatelessWidget {
  const All_objects({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const All_objectsPage(title: 'naftinvAppScann');
  }
}

class All_objectsPage extends StatefulWidget {
  const All_objectsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<All_objectsPage> createState() => _All_objectsPageState();
}

class _All_objectsPageState extends State<All_objectsPage> {
  List<Localisation> list = [];
  late User user;
  List<Localisation> duplicated = [];

  var _currentIndex = 3;
  TextEditingController editingController = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);
  late Future<List> fetchItems;

  @override
  void initState() {
    super.initState();
    fetchItems = fetchLocalisations(context);
  }

  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  void filterSearchResults(String query) {
    query = query.toUpperCase();
    if (query.isNotEmpty) {
      setState(() {
        list = duplicated
            .where((element) =>
                element.designation.contains(query) ||
                element.code_bar.contains(query))
            .toList();
      });
    } else {
      setState(() {
        list.clear();
        list.addAll(duplicated);
      });
    }
  }

  Widget LocalisationWidget(Localisation loc) {
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
                  "CODE LOCALITE :",
                  style: textStyle,
                ),
                Text(
                  loc.code_bar,
                  style: textStyle,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.home_outlined),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Text(
                  "LIBELLE : ${loc.designation}",
                  style: textStyle,
                )),
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
                        context,
                        MaterialPageRoute(
                          builder: (context) => Detail_Operation(
                            localisation: loc,
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

  Future<List> fetchLocalisations(BuildContext context) async {
    user = await User.auth();
    if (list.length == 0) {
      list = await Localisation.show_localisations();

      duplicated.addAll(list);
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchItems,
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
                child: Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.storage, size: 23, color: blue),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            "${duplicated[0].cop_lib}",
                            style: TextStyle(
                                fontSize: 17,
                                color: blue,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      controller: editingController,
                      decoration: InputDecoration(
                          labelText: "Recherche",
                          hintText: "Recherche",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 260,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return (LocalisationWidget(list[index]));
                      },
                      physics: ScrollPhysics(),
                    ),
                  )
                ],
              ),
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
  }
}
