import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/ChangeLecteur.dart';
import 'package:naftinv/all_non_etique.dart';
import 'package:naftinv/all_objects.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/components/AvatarComponent.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/create_Non_etiqu.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/detailLocalite.dart';
import 'package:naftinv/detail_bien.dart';
import 'package:naftinv/detail_operation.dart';
import 'package:naftinv/history.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:naftinv/mode_manuel.dart';
import 'package:naftinv/repositories/authentication_repository.dart';
import 'package:naftinv/repositories/synchronization_repository.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:skeleton_animation/skeleton_animation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'main.dart';

bool check_format(int type, String value) {
  if (type == 0) {
    // Expression réguliére pour les localisations
    value.replaceAll('-', '');
    final localisation = RegExp(r'^([A-Z]|[0-9]){4}L([A-Z]|[0-9]){6,8}$');
    final localisation2 = RegExp(r'^K[0-9]{4}L[0-9]{5}$');
    return localisation.hasMatch(value) || localisation2.hasMatch(value);
  } else if (type == 1) {
    // Expression réguliére pour les bien Matériaux

    final BienMateriel = RegExp(r'^[A-Z]([0-9]|[A-Z]){7,}$');
    return BienMateriel.hasMatch(value);
  }
  return true;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  String _scanBarcode = '';
  String username = "";
  String post_user = "";
  String annee = "";
  bool flash = false;
  String cop_lib = "";
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  late Future<int> initAPP;

  // Future<int> _initPackageInfo() async {
  //   if (_connectionStatus == ConnectivityResult.wifi) {
  //     try {
  //       User user = await User.auth();
  //       Dio dio = Dio();
  //       String token = await user.getToken();

  //       dio.options.headers["Authorization"] = 'Bearer ' + await token;

  //       final database = openDatabase(join(await getDatabasesPath(), DBNAME));
  //       final db = await database;
  //       String imeiNo = await DeviceInformation.deviceIMEINumber;

  //       var response = await dio.get(
  //           '${LARAVEL_ADDRESS}api/localite_par_centre/${user.COP_ID}',
  //           queryParameters: {"code": imeiNo});
  //       List temp = response.data;

  //       List<Localisation> loc = List.generate(temp.length, (i) {
  //         return Localisation(temp[i]['loc_ID'], temp[i]['loc_LIB'],
  //             temp[i]['cop_LIB'], temp[i]['cop_ID'], [], []);
  //       });

  //       var batch = db.batch();
  //       batch.execute(
  //           "DELETE FROM T_E_LOCATION_LOC WHERE COP_ID = '${user.COP_ID}' ;");

  //       for (var item in loc) {
  //         batch.insert('T_E_LOCATION_LOC', item.toMap(),
  //             conflictAlgorithm: ConflictAlgorithm.replace);
  //       }

  //       await batch.commit(noResult: true);
  //     } catch (e) {
  //       print(e.toString());
  //     }
  //   }

  //   final info = await PackageInfo.fromPlatform();
  //   _packageInfo = info;

  //   return 0;
  // }

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
    // initAPP = _initPackageInfo();
    // _connectivity.onConnectivityChanged
    //     .listen((List<ConnectivityResult> result) {
    //   print(result);
    //   setState(() {
    //     _connectionStatus = result.first;
    //   });
    // });
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> scanBarcodeNormal(BuildContext context) async {
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

    if (check_format(0, _scanBarcode) == false) {
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
          _scanBarcode,
          DateTime.now().toIso8601String(),
          " ",
          user.COP_ID,
          await Localisation.get_linked_Object(_scanBarcode),
          await Localisation.get_linked_SN(_scanBarcode));

      loc.exists().then((exist) async {
        if (exist == true) {
          Localisation localisation =
              await Localisation.get_localisation(_scanBarcode);

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

  Future<void> poursuivre_operation(BuildContext context) async {
    List<Bien_materiel> biens = await Bien_materiel.history();

    if (biens.length >= 1) {
      Localisation localisation =
          await Localisation.get_localisation(biens.last.code_localisation);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Detail_Bien(
            bien_materiel: biens.last,
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
              "Vous n'avez aucune opération précédente",
              style: TextStyle(fontSize: 17.0),
            ),
          ],
        ),
        backgroundColor: Colors.red,
      ));
      scanBarcodeNormal(context);
    }
  }

  void synchronize(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.sync, color: Colors.black87, size: 25),
          Text(
            "Synchronisation en cours",
            style: TextStyle(fontSize: 17.0, color: Colors.black87),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 214, 214, 214),
    ));
    List<Bien_materiel> objects = await Bien_materiel.synchonized_objects();
    List<Non_Etiquete> object2 = await Non_Etiquete.synchonized_objects();
    User user = await User.auth();
    Dio dio = Dio();
    dio.options.headers["Authorization"] = 'Bearer ' + await user.getToken();
    String imeiNo = await DeviceInformation.deviceIMEINumber;

    var response = await dio.post('${LARAVEL_ADDRESS}api/save_many/${imeiNo}',
        data: jsonEncode(objects));

    response = await dio.post(
        '${LARAVEL_ADDRESS}api/save_manyNonEtiqu/${imeiNo}',
        data: jsonEncode(object2));

    if (response.toString() == "true") {
      final database = openDatabase(join(await getDatabasesPath(), DBNAME));
      final db = await database;
      await db.rawUpdate(
          "UPDATE Bien_materiel SET stockage = 1 where stockage = 0");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.check, color: Colors.white, size: 25),
            Text(
              "Synchronisation effectuée avec succès",
              style: TextStyle(fontSize: 17.0, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green,
      ));
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

  Future<String> User_infos() async {
    User user = await User.auth();
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;
    final List<Map<String, dynamic>> list1 = await db.query(
        'T_E_LOCATION_LOC where COP_ID = "${user.COP_ID}"',
        distinct: true,
        columns: ['COP_LIB']);

    final List<Map<String, dynamic>> list2 = await db.query(
        'T_E_GROUPE_INV where EMP_ID = "${user.matricule}"',
        distinct: true,
        columns: ['JOB_LIB', 'YEAR']);

    cop_lib = list1[0]["COP_LIB"];
    username = user.nom;
    annee = list2[0]["YEAR"].toString();
    post_user = list2[0]["JOB_LIB"];

    return username;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Set to transparent for a fullscreen effect
      statusBarIconBrightness:
          Brightness.light, // Set to Brightness.dark for light icons
      statusBarBrightness:
          Brightness.light, // Set to Brightness.dark for light icons on iOS
    ));

    return BlocProvider.value(
        value: context.read<SynchronizationBloc>(),
        child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: CustomBottomBarWidget(context, 0),
            body: Builder(builder: (BuildContext context) {
              return SingleChildScrollView(
                  child: BlocBuilder<SynchronizationBloc, SynchronizationState>(
                builder: (context, state) {
                  if (state is SynchronizationInitial) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          BlocBuilder<AuthenticationBloc, AuthenticationState>(
                            builder: (context, state) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: MAINCOLOR,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(50),
                                        bottomRight: Radius.circular(50))),
                                padding:
                                    const EdgeInsets.fromLTRB(25, 40, 25, 30),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                flex: 2,
                                                child: Avatarcomponent(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.37,
                                                    backgroundColor: purple,
                                                    color: Colors.white,
                                                    text: state.user?.nom[0] ??
                                                        "U"),
                                              ),
                                              Flexible(
                                                flex: 5,
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        state.user?.nom ?? "",
                                                        style: defaultTextStyle(
                                                            fontSize: 17,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 10.0),
                                                        child: Row(
                                                          children: [
                                                            Text(state.centre,
                                                                style:
                                                                    defaultTextStyle(
                                                                  color: GRAY,
                                                                )),
                                                            Icon(
                                                              Icons
                                                                  .location_on_outlined,
                                                              color: GRAY,
                                                              size: 14,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.notifications_outlined,
                                              color: YELLOW,
                                              size: 32,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(13),
                                            topRight: Radius.circular(13),
                                          )),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "25 %",
                                                      style: defaultTextStyle(
                                                          color: YELLOW),
                                                    ),
                                                    Text(
                                                      " opérations terminés",
                                                      style: defaultTextStyle(),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "10 j restants",
                                                  style: defaultTextStyle(
                                                      color: GRAY),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Stack(
                                            children: [
                                              Container(
                                                height: 10,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: LIGHTYELLOW,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              Positioned(
                                                left: 0,
                                                child: Container(
                                                  height: 10,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  decoration: BoxDecoration(
                                                    color: YELLOW,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ElevatedButton(
                                        style: TextButton.styleFrom(
                                            side: BorderSide(
                                              color: MAINCOLOR,
                                            ),
                                            backgroundColor: Colors.white),
                                        onPressed: () {},
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.play_circle,
                                                color: MAINCOLOR,
                                              ),
                                              Text(
                                                'Poursuivre',
                                                style: defaultTextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ElevatedButton(
                                        style: TextButton.styleFrom(
                                            side: BorderSide(
                                              color: MAINCOLOR,
                                            ),
                                            backgroundColor: MAINCOLOR),
                                        onPressed: () {},
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                'Nouveau scan',
                                                style: defaultTextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Localités visités",
                                  style: defaultTextStyle(fontSize: 18.0),
                                ),
                                TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Afficher plus ",
                                      style: defaultTextStyle(color: purple),
                                    ))
                                // IconButton(
                                //     color: flash == true ? blue : Colors.amberAccent,
                                //     onPressed: () => {
                                //           setState(() {
                                //             flash = !flash;
                                //           })
                                //         },
                                //     icon: flash == true
                                //         ? Icon(Icons.flash_on)
                                //         : Icon(Icons.flash_off))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                                itemCount: state.localites.length,
                                itemBuilder: (context, index) {
                                  if (index != state.localites.length - 1) {
                                    return LocaliteWidget(
                                      localisation: state.localites[index],
                                    );
                                  } else {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 40.0),
                                      child: LocaliteWidget(
                                        localisation: state.localites[index],
                                      ),
                                    );
                                  }
                                }),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.13,
                          )
                          // LocaliteWidget(),
                          // LocaliteWidget(),
                          // LocaliteWidget(),
                          // LocaliteWidget(),
                          // LocaliteWidget(),

                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.end,
                          //     children: [
                          //       TextButton(
                          //         onPressed: () {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (context) => ChangeLecteur()));
                          //         },
                          //         child: Column(children: [
                          //           Icon(
                          //             Icons.bar_chart,
                          //             size: 30,
                          //             color: blue,
                          //           ),
                          //           Text(
                          //             'Choix du lecteur',
                          //             style: TextStyle(color: blue, fontSize: 18.0),
                          //           )
                          //         ]),
                          //       ),
                          //       Text(
                          //         "New",
                          //         style: TextStyle(color: Colors.red, fontSize: 11),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextButton(
                          //     onPressed: () => scanBarcodeNormal(context),
                          //     child: Column(children: [
                          //       Icon(
                          //         Icons.camera_alt,
                          //         size: 30,
                          //         color: blue,
                          //       ),
                          //       Text(
                          //         'Scanner localité',
                          //         style: TextStyle(color: blue, fontSize: 18.0),
                          //       )
                          //     ]),
                          //   ),
                          // ),
                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextButton(
                          //     onPressed: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => ModeManuel()),
                          //       );
                          //     },
                          //     child: Column(children: [
                          //       Icon(
                          //         Icons.edit,
                          //         size: 30,
                          //         color: blue,
                          //       ),
                          //       Text(
                          //         'Saisir localité',
                          //         style: TextStyle(color: blue, fontSize: 18.0),
                          //       )
                          //     ]),
                          //   ),
                          // ),
                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextButton(
                          //     child: Column(
                          //       children: [
                          //         Icon(
                          //           Icons.arrow_circle_right_outlined,
                          //           color: blue,
                          //           size: 30,
                          //         ),
                          //         Text(
                          //           'Poursuivre la derniére opération',
                          //           style: TextStyle(color: blue, fontSize: 18.0),
                          //         )
                          //       ],
                          //     ),
                          //     onPressed: () {
                          //       poursuivre_operation(context);
                          //     },
                          //   ),
                          // ),
                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextButton(
                          //     child: Column(children: [
                          //       Icon(
                          //         Icons.history,
                          //         color: blue,
                          //         size: 30,
                          //       ),
                          //       Text(
                          //         'Historique des opérations',
                          //         style: TextStyle(color: blue, fontSize: 18),
                          //       )
                          //     ]),
                          //     onPressed: () => {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(builder: (context) => History()),
                          //       )
                          //     },
                          //   ),
                          // ),
                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextButton(
                          //     child: Column(children: [
                          //       Icon(
                          //         Icons.library_books,
                          //         color: blue,
                          //         size: 30,
                          //       ),
                          //       Text(
                          //         'Consulter toutes les localités',
                          //         style: TextStyle(color: blue, fontSize: 18.0),
                          //       )
                          //     ]),
                          //     onPressed: () async {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => All_objects()),
                          //       );
                          //     },
                          //   ),
                          // ),
                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextButton(
                          //     child: Column(children: [
                          //       Icon(
                          //         Icons.add,
                          //         color: blue,
                          //         size: 30,
                          //       ),
                          //       Text(
                          //         'Ajouter un article SN',
                          //         style: TextStyle(color: blue, fontSize: 18.0),
                          //       )
                          //     ]),
                          //     onPressed: () async {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => Create_Non_etiqu(
                          //                   localite: "",
                          //                 )),
                          //       );
                          //     },
                          //   ),
                          // ),
                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextButton(
                          //     child: Column(children: [
                          //       Icon(
                          //         Icons.device_unknown_sharp,
                          //         color: blue,
                          //         size: 30,
                          //       ),
                          //       Text(
                          //         'Liste des articles SN',
                          //         style: TextStyle(color: blue, fontSize: 18.0),
                          //       )
                          //     ]),
                          //     onPressed: () async {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => All_Non_Etiqu()),
                          //       );
                          //     },
                          //   ),
                          // ),
                          // Container(
                          //   width: double.infinity,
                          //   margin: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: new BorderRadius.circular(7),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.2),
                          //         spreadRadius: 3,
                          //         blurRadius: 3,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextButton(
                          //     child: Column(children: [
                          //       Icon(
                          //         Icons.refresh,
                          //         color: blue,
                          //         size: 30,
                          //       ),
                          //       Text(
                          //         'Réinitialiser',
                          //         style: TextStyle(color: blue, fontSize: 18.0),
                          //       )
                          //     ]),
                          //     onPressed: () async {
                          //       final database = openDatabase(
                          //           join(await getDatabasesPath(), DBNAME));
                          //       final db = await database;
                          //       await db.execute("DELETE FROM User;");

                          //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //         content: Row(
                          //           mainAxisAlignment: MainAxisAlignment.start,
                          //           children: [
                          //             Icon(Icons.check,
                          //                 color: Colors.white, size: 25),
                          //             Text(
                          //               "Données réinitialisées avec succès",
                          //               style: TextStyle(
                          //                   fontSize: 17.0, color: Colors.white),
                          //             ),
                          //           ],
                          //         ),
                          //         backgroundColor: Colors.green,
                          //       ));

                          //       Navigator.pushAndRemoveUntil(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => ChoixStructure()),
                          //         ModalRoute.withName('/structure'),
                          //       );
                          //     },
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.end,
                          //   children: [
                          //     Text(
                          //       "version : 2.0.9",
                          //       style: TextStyle(
                          //           fontWeight: FontWeight.bold, color: Colors.grey),
                          //     )
                          //   ],
                          // )
                        ]);
                  } else {
                    return SkeleteonOperations();
                  }
                },
              ));
            })));
  }
}

class SkeleteonOperations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(
              width: 300,
              height: 30,
            ),
            SizedBox(
              height: 30,
            ),
            Skeleton(
              width: double.infinity,
              height: 80,
            ),
            SizedBox(
              height: 10,
            ),
            Skeleton(
              width: double.infinity,
              height: 80,
            ),
            SizedBox(
              height: 10,
            ),
            Skeleton(
              width: double.infinity,
              height: 80,
            ),
            SizedBox(
              height: 10,
            ),
            Skeleton(
              width: double.infinity,
              height: 80,
            ),
            SizedBox(
              height: 10,
            ),
            Skeleton(
              width: double.infinity,
              height: 80,
            )
          ],
        ));
  }
}

class LocaliteWidget extends StatelessWidget {
  const LocaliteWidget({super.key, required this.localisation});
  final Localisation localisation;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: LIGHTGRAY,
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(0, 15))
            ]),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                flex: 4,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Avatarcomponent(
                          height: MediaQuery.of(context).size.width * 0.33,
                          backgroundColor: MAINCOLOR,
                          color: Colors.white,
                          text: localisation.designation.substring(0, 2)),
                    ),
                    Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localisation.designation,
                                style: defaultTextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                localisation.code_bar,
                                style:
                                    defaultTextStyle(fontSize: 12, color: GRAY),
                              ),
                              Text(
                                "${localisation.biens.length} ARTICLES",
                                style: defaultTextStyle(
                                    fontSize: 12,
                                    color: YELLOW,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ))
                  ],
                )),
            Flexible(
                flex: 1,
                child: IconButton(
                  style: TextButton.styleFrom(backgroundColor: purple),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => DetailLocalitePage(
                                localisation: localisation,
                              )),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ))
          ],
        ));
  }
}
// ignore_for_file: prefer_const_constructors
