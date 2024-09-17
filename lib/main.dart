import 'dart:typed_data';

import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:naftinv/Login.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/choix_structure/choix_structure_bloc.dart';
import 'package:naftinv/blocs/cubit/bien_immo/bien_immo_cubit.dart';
import 'package:naftinv/blocs/cubit/taux/taux_cubit.dart';
import 'package:naftinv/blocs/settings_bloc/bloc/settings_bloc.dart';
import 'package:naftinv/blocs/settings_bloc/settingsRepository.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/homeImmobilisation.dart';
import 'package:naftinv/noInternet.dart';
import 'package:naftinv/permissionNotGranted.dart';
import 'package:naftinv/repositories/authentication_repository.dart';
import 'package:naftinv/repositories/choix_structure_repository.dart';
import 'package:naftinv/repositories/synchronization_repository.dart';
import 'package:naftinv/splash.dart';
import 'package:naftinv/synchronization.dart';
import 'package:naftinv/unauthorized_screen.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'operations.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import 'package:easy_autocomplete/easy_autocomplete.dart';

// const LARAVEL_ADDRESS = "http://webimmo.naftinv.dz:8080/naftimobackend/";
const IP_ADDRESS = "https://inventairews.naftinv.dz/NaftImmo_backend/";

const LARAVEL_ADDRESS = "https://naftinventaire.naftal.dz/";
// const LARAVEL_ADDRESS = "http://192.168.0.127:8080/";

int MODE_SCAN = 1;
int YEAR = DateTime.now().year;

var STRUCTURE = "";
const DBNAME = "naftinv_scan.db";

Future<Database> initializeDatabase() async {
  // Get the database path
  String dbPathScan = join(await getDatabasesPath(), DBNAME);

  // Check if the database exists
  bool dbExistsScan = await io.File(dbPathScan).exists();

  if (!dbExistsScan) {
    print("Database creation");
    // Copy from asset8
    ByteData data = await rootBundle.load(join("assets", "naftal_scan.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await io.File(dbPathScan).writeAsBytes(bytes, flush: true);
  } else {
    print("Database already exists");
  }

  // Open the database
  return openDatabase(dbPathScan);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final Database database = await initializeDatabase();

  // Run the app with the initialized repositories
  runApp(App(
    authenticationRepository: AuthenticationRepository(db: database),
    choixStructureRepository: ChoixStructureRepository(db: database),
    settingsrepository: Settingsrepository(db: database),
  ));
}

class App extends StatelessWidget {
  const App(
      {Key? key,
      required this.authenticationRepository,
      required this.choixStructureRepository,
      required this.settingsrepository})
      : super(key: key);

  final AuthenticationRepository authenticationRepository;
  final ChoixStructureRepository choixStructureRepository;
  final Settingsrepository settingsrepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthenticationBloc(
              authenticationRepository: authenticationRepository,
            ),
          ),
          BlocProvider(
              create: (_) =>
                  SettingsBloc(settingsrepository: settingsrepository)),
          BlocProvider(
            create: (_) => ChoixStructureBloc(
              choixStructureRepository: choixStructureRepository,
            ),
          ),
          BlocProvider(
              create: (_) => BienImmoCubit(
                  authenticationRepository: authenticationRepository)),
          BlocProvider(
            create: (_) => SynchronizationBloc(
              authenticationRepository: authenticationRepository,
              synchronizationRepository: SynchronizationRepository(
                db: authenticationRepository.db,
              ),
            ),
          ),
        ],
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    final AuthenticationRepository authenticationRepository =
        RepositoryProvider.of<AuthenticationRepository>(context);
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ChoixStructure',
      theme: ThemeData(
        primaryColor: const Color(0xFF171059),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF171059),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF171059),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          filled: true,
          fillColor: const Color(0XFFF5F5F5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: Color(0XFFC5C5C7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: Color(0XFFC5C5C7)),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: GoogleFonts.poppins(
            color: const Color(0xFF171059),
          ),
        ),
      ),
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.init:
                _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => ChoixStructurePage(),
                  ),
                  ModalRoute.withName('/'),
                );
                break;
              case AuthenticationStatus.authFailedImmo:
                print("##_ auth failed captured");

                break;
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => MyApp(),
                  ),
                  ModalRoute.withName('/home'),
                );
                break;
              case AuthenticationStatus.centreSelected:
                _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => SynchronizationPage(
                      authenticationRepository: authenticationRepository,
                    ),
                  ),
                  ModalRoute.withName('/synchronization_page'),
                );
                break;
              case AuthenticationStatus.uncheckedDevice:
                _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => UnauthorizedScreen(
                      code: context
                          .read<AuthenticationBloc>()
                          .authenticationRepository
                          .deviceId,
                    ),
                  ),
                  ModalRoute.withName('/unAuthorized'),
                );
                break;
              case AuthenticationStatus.noInternet:
                _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const NoInternet(),
                  ),
                  ModalRoute.withName('/noInternet'),
                );
                break;
              case AuthenticationStatus.permissionNotGaranted:
                _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const PermissionNotGranted(),
                  ),
                  ModalRoute.withName('/permissionNotGranted'),
                );
                break;
              case AuthenticationStatus.authenticatedImmo:
                _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => HomeImmo(),
                  ),
                  ModalRoute.withName('/homeImmo'),
                );
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}

class ChoixStructurePage extends StatelessWidget {
  ChoixStructurePage({Key? key}) : super(key: key);
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController structureController = TextEditingController();

  void Show_Error(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.white, size: 20),
          Text(
            "Centre d'opération invalide",
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChoixStructureBloc, ChoixStructureState>(
      builder: (context, state) {
        if (state is ChoixStructureInitial) {
          return Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                  child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/team.jpg",
                      width: double.infinity,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 30, 10, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Votre centre opérationel',
                              style: defaultTextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                                "Assurez que vous faites partie de l'équipe d'inventaire du centre choisis",
                                textAlign: TextAlign.center,
                                style: defaultTextStyle(
                                  color: YELLOW,
                                  fontSize: 12,
                                )),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.home_filled,
                                  size: 23,
                                  color: Color(0xFF171059),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    "Centre d'opération",
                                    style: defaultTextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: Color(0xFF171059)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      titleTextStyle: defaultTextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          fontWeight: FontWeight.w700),
                                      backgroundColor: Colors.white,
                                      title:
                                          Text('Gestion des immobilisations'),
                                      content: BlocListener<AuthenticationBloc,
                                          AuthenticationState>(
                                        listener: (context, state) {
                                          if (state.status ==
                                              AuthenticationStatus
                                                  .authFailedImmo) {
                                            print("##_ failed auth");
                                            showTopSnackBar(
                                              Overlay.of(context),
                                              const CustomSnackBar.error(
                                                message:
                                                    'Username ou mot de passe incorrecte!',
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 20),
                                                  alignment: Alignment.center,
                                                  child: EasyAutocomplete(
                                                    controller:
                                                        structureController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            "Centre d'opération"),
                                                    inputTextStyle:
                                                        defaultTextStyle(
                                                            color: Color(
                                                                0xFF171059)),
                                                    suggestions:
                                                        state.structures,
                                                    onChanged: (val) {
                                                      context
                                                          .read<
                                                              ChoixStructureBloc>()
                                                          .add(
                                                              ChoixStructurePickStructure(
                                                                  structure:
                                                                      val));
                                                    },
                                                    onSubmitted: (val) {
                                                      context
                                                          .read<
                                                              ChoixStructureBloc>()
                                                          .add(
                                                              ChoixStructurePickStructure(
                                                                  structure:
                                                                      val));
                                                    },
                                                  )),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          25),
                                                ),
                                                child: TextFormField(
                                                  controller: emailController,
                                                  decoration:
                                                      defaultInputDecoration(
                                                    title: "Nom d'utilisateur",
                                                  ),
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  style: defaultTextStyle(),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: TextFormField(
                                                  controller:
                                                      passwordController,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                        Icons.remove_red_eye,
                                                        color: MAINCOLOR,
                                                      ),
                                                    ),
                                                    labelText: "Mot de passe",
                                                    fillColor: Colors.white,
                                                    labelStyle:
                                                        defaultTextStyle(),

                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: GRAY),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: GRAY),
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: GRAY),
                                                    ),
                                                    //fillColor: Colors.green
                                                  ),
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  style: const TextStyle(
                                                    fontFamily: "Poppins",
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    backgroundColor: purple,
                                                    textStyle: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  onPressed: () async {
                                                    context
                                                        .read<
                                                            AuthenticationBloc>()
                                                        .add(SubmitImmobilisationAuthentication(
                                                            matricule:
                                                                emailController
                                                                    .text,
                                                            password:
                                                                passwordController
                                                                    .text,
                                                            centre:
                                                                structureController
                                                                    .text));

                                                    context
                                                        .read<
                                                            SynchronizationBloc>()
                                                        .add(
                                                            SynchronizationRefresh());
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 12,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      // ignore: prefer_const_literals_to_create_immutables
                                                      children: <Widget>[
                                                        Text(
                                                          'Connexion',
                                                          style:
                                                              defaultTextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            icon: Icon(Icons.info_outline),
                          )
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        alignment: Alignment.center,
                        child: EasyAutocomplete(
                          inputTextStyle:
                              defaultTextStyle(color: Color(0xFF171059)),
                          suggestions: state.structures,
                          onChanged: (val) {
                            context.read<ChoixStructureBloc>().add(
                                ChoixStructurePickStructure(structure: val));
                          },
                          onSubmitted: (val) {
                            context.read<ChoixStructureBloc>().add(
                                ChoixStructurePickStructure(structure: val));
                          },
                        )),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 23,
                            color: Color(0xFF171059),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Année d'inventaire",
                            style: defaultTextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Color(0xFF171059)),
                          )
                        ],
                      ),
                    ),
                    Builder(builder: (context) {
                      return NumberPicker(
                          value: state.year,
                          minValue: DateTime.now().year - 1,
                          maxValue: DateTime.now().year + 1,
                          onChanged: (value) {
                            context
                                .read<ChoixStructureBloc>()
                                .add(ChoixStructurePickYear(year: value));
                          });
                    }),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Colors.yellow[700],
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  try {
                                    if (state.selectedStructures
                                        .contains("-")) {
                                      context.read<ChoixStructureBloc>().add(
                                          ChoixStructurePickStructure(
                                              structure: state
                                                  .selectedStructures
                                                  .substring(
                                                      0,
                                                      state.selectedStructures
                                                              .indexOf("-") -
                                                          1)));
                                    }

                                    context.read<AuthenticationBloc>().add(
                                        SelectStructure(
                                            year: state.year,
                                            centre: state.selectedStructures
                                                .substring(
                                                    0,
                                                    state.selectedStructures
                                                            .indexOf("-") -
                                                        1)));
                                  } catch (e) {
                                    print(e.toString());
                                    Show_Error(context);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // ignore: prefer_const_literals_to_create_immutables
                                    children: <Widget>[
                                      Text(
                                        'Continuer',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              )));
        } else {
          return Text("");
        }
      },
    );
  }
}
