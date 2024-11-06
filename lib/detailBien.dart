import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:naftinv/Login.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/cubit/number_of_articles_cubit_cubit.dart';
import 'package:naftinv/blocs/settings_bloc/bloc/settings_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/create_Non_etiqu.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/detailSn.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class DetailBienPage extends StatelessWidget {
  final Bien_materiel bien;
  TextEditingController codeBarController = TextEditingController();
  TextEditingController natureController = TextEditingController();
  TextEditingController numSerieController = TextEditingController();
  TextEditingController marqueController = TextEditingController();
  TextEditingController modeleController = TextEditingController();
  DetailBienPage({super.key, required this.bien});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Set to transparent for a fullscreen effect
      statusBarIconBrightness:
          Brightness.light, // Set to Brightness.dark for light icons
      statusBarBrightness:
          Brightness.light, // Set to Brightness.dark for light icons on iOS
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: CustomBottomBarWidget(context, 2),
      body: SingleChildScrollView(
        child: BlocBuilder<SynchronizationBloc, SynchronizationState>(
          builder: (context, state) {
            if (state is SynchronizationInitial) {
              return Column(children: [
                Container(
                  decoration: const BoxDecoration(
                      color: MAINCOLOR,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50))),
                  padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: IconButton(
                                  onPressed: () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: YELLOW,
                                  )),
                            ),
                            Flexible(
                              flex: 3,
                              child: Text(bien.code_bar,
                                  textAlign: TextAlign.center,
                                  style: defaultTextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                            const Flexible(flex: 1, child: Text(""))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      scanBarcodeNormal(context, operation: 2);
                                    },
                                    style: unactiveStyleElevated,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        Text(
                                          "   Scanner",
                                          style: defaultTextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      SettingsBloc settingsBloc =
                                          context.read<SettingsBloc>();
                                      showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return BlocProvider.value(
                                              value: settingsBloc,
                                              child: BlocBuilder<SettingsBloc,
                                                  SettingsState>(
                                                builder: (context, state) {
                                                  if (state
                                                      is SettingsInitial) {
                                                    return Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      padding: EdgeInsets.all(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.05),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(Icons
                                                                  .settings),
                                                              Text(
                                                                "Paramétrer votre application",
                                                                style: defaultTextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.038),
                                                              )
                                                            ],
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(
                                                                vertical: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.025),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  flex: 1,
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .flash_on,
                                                                        color:
                                                                            YELLOW,
                                                                      ),
                                                                      Text(
                                                                        "Flash",
                                                                        style:
                                                                            defaultTextStyle(),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 1,
                                                                  child:
                                                                      Expanded(
                                                                    child:
                                                                        RadioListTile<
                                                                            bool>(
                                                                      title: const Text(
                                                                          'On'),
                                                                      value:
                                                                          true,
                                                                      groupValue:
                                                                          state
                                                                              .flash,
                                                                      onChanged:
                                                                          (val) {
                                                                        settingsBloc
                                                                            .add(SettingsUpdateFlash());
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      RadioListTile<
                                                                          bool>(
                                                                    title: const Text(
                                                                        'Off'),
                                                                    value:
                                                                        false,
                                                                    groupValue:
                                                                        state
                                                                            .flash,
                                                                    onChanged:
                                                                        (val) {
                                                                      settingsBloc
                                                                          .add(
                                                                              SettingsUpdateFlash());
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.025),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  flex: 1,
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .barcode_reader,
                                                                        color:
                                                                            YELLOW,
                                                                      ),
                                                                      Text(
                                                                        " Lecteur",
                                                                        style:
                                                                            defaultTextStyle(),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 1,
                                                                  child:
                                                                      RadioListTile<
                                                                          int>(
                                                                    title:
                                                                        const Text(
                                                                            '1'),
                                                                    value: 1,
                                                                    groupValue:
                                                                        state
                                                                            .lecteur,
                                                                    onChanged:
                                                                        (val) {
                                                                      settingsBloc.add(SettingsUpdateLecteur(
                                                                          lecteur:
                                                                              1));
                                                                    },
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      RadioListTile<
                                                                          int>(
                                                                    title:
                                                                        const Text(
                                                                            '2'),
                                                                    value: 2,
                                                                    groupValue:
                                                                        state
                                                                            .lecteur,
                                                                    onChanged:
                                                                        (val) {
                                                                      settingsBloc.add(SettingsUpdateLecteur(
                                                                          lecteur:
                                                                              2));
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.025),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  flex: 1,
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .check_circle_outline,
                                                                        color:
                                                                            YELLOW,
                                                                      ),
                                                                      Text(
                                                                        " Etat du bien",
                                                                        style:
                                                                            defaultTextStyle(),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4,
                                                                        horizontal:
                                                                            8),
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            LIGHTYELLOW,
                                                                        borderRadius:
                                                                            BorderRadius.circular(25)),
                                                                    child:
                                                                        DropdownButton<
                                                                            int>(
                                                                      style:
                                                                          defaultTextStyle(),
                                                                      dropdownColor:
                                                                          Colors
                                                                              .white,
                                                                      underline:
                                                                          Container(),
                                                                      iconSize:
                                                                          0,
                                                                      hint: const Text(
                                                                          'Select an option'), // Hint when no item is selected
                                                                      value: state
                                                                          .modeScan, // The currently selected item
                                                                      items: [
                                                                        1,
                                                                        2,
                                                                        3
                                                                      ].map((int
                                                                          item) {
                                                                        return DropdownMenuItem<
                                                                            int>(
                                                                          value:
                                                                              item, // Set the value to the current item, not state.modeScan
                                                                          child:
                                                                              Text(valueState(item)),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged:
                                                                          (int?
                                                                              newValue) {
                                                                        // Update the selected value with the new selection
                                                                        settingsBloc.add(SettingsUpdateMode(
                                                                            modeScan:
                                                                                newValue!));
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    return const CircularProgressIndicator();
                                                  }
                                                },
                                              ),
                                            );
                                          });
                                    },
                                    style: unactiveStyleElevated,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.settings,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        Text(
                                          "   PARAMÉTRES",
                                          style: defaultTextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nouveau article",
                        style: defaultTextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      TextButton(
                          onPressed: () {
                            final syncBloc =
                                context.read<SynchronizationBloc>();
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return BlocProvider.value(
                                    value: syncBloc,
                                    child: BlocBuilder<SynchronizationBloc,
                                        SynchronizationState>(
                                      builder: (context, state) {
                                        if (state is SynchronizationInitial) {
                                          return Container(
                                            padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            child: BlocProvider(
                                              create: (context) =>
                                                  NumberOfArticlesCubit(),
                                              child: SingleChildScrollView(
                                                child: BlocBuilder<
                                                    NumberOfArticlesCubit,
                                                    AddSnFields>(
                                                  builder:
                                                      (context, stateAddSn) {
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.add_box,
                                                              color: YELLOW,
                                                            ),
                                                            Text(
                                                              "Ajouter un article SN",
                                                              style: defaultTextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 18),
                                                            )
                                                          ],
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          margin: EdgeInsets.symmetric(
                                                              vertical: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.02),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: GRAY),
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                          ),
                                                          child: TextFormField(
                                                            initialValue: state
                                                                    .localisation
                                                                    ?.code_bar ??
                                                                bien.code_localisation,
                                                            decoration:
                                                                snInputDecoration(
                                                                    title:
                                                                        "Code localité"),
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            enabled: false,
                                                            style:
                                                                defaultTextStyle(),
                                                          ),
                                                        ),
                                                        Autocomplete<String>(
                                                          optionsBuilder:
                                                              (TextEditingValue
                                                                  textEditingValue) {
                                                            if (textEditingValue
                                                                    .text ==
                                                                '') {
                                                              return const Iterable<
                                                                  String>.empty();
                                                            }
                                                            return state.natures
                                                                .where((String
                                                                    option) {
                                                              return option
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      textEditingValue
                                                                          .text
                                                                          .toLowerCase());
                                                            });
                                                          },
                                                          onSelected: (String
                                                              selection) {
                                                            print(selection);
                                                            debugPrint(
                                                                'You just selected $selection');
                                                          },
                                                          fieldViewBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  natureController,
                                                                  FocusNode
                                                                      focusNode,
                                                                  VoidCallback
                                                                      onFieldSubmitted) {
                                                            return TextField(
                                                              controller:
                                                                  natureController,
                                                              focusNode:
                                                                  focusNode,
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintText:
                                                                    'Nature',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            );
                                                          },
                                                          optionsViewBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  AutocompleteOnSelected<
                                                                          String>
                                                                      onSelected,
                                                                  Iterable<
                                                                          String>
                                                                      options) {
                                                            return Material(
                                                              elevation: 4.0,
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.9,
                                                                color: Colors
                                                                    .white,
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        option =
                                                                        options.elementAt(
                                                                            index);

                                                                    return ListTile(
                                                                      title: Text(
                                                                          option),
                                                                      onTap:
                                                                          () {
                                                                        context
                                                                            .read<NumberOfArticlesCubit>()
                                                                            .update(stateAddSn.copyWith(nature: option));
                                                                        onSelected(
                                                                            option);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          margin: EdgeInsets.symmetric(
                                                              vertical: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.02),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: GRAY),
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                numSerieController,
                                                            decoration:
                                                                snInputDecoration(
                                                                    title:
                                                                        "Numéro de série"),
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            style:
                                                                defaultTextStyle(),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          margin: EdgeInsets.symmetric(
                                                              vertical: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.02),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: GRAY),
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                marqueController,
                                                            decoration:
                                                                snInputDecoration(
                                                                    title:
                                                                        "Marque d'article"),
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            style:
                                                                defaultTextStyle(),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          margin: EdgeInsets.symmetric(
                                                              vertical: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.02),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: GRAY),
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                modeleController,
                                                            decoration:
                                                                snInputDecoration(
                                                                    title:
                                                                        "Modèle"),
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            style:
                                                                defaultTextStyle(),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  10, 5, 0, 0),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(Icons
                                                                    .format_list_numbered),
                                                                Text(
                                                                  "Nombre d'article ",
                                                                  style:
                                                                      defaultTextStyle(),
                                                                )
                                                              ]),
                                                        ),
                                                        NumberPicker(
                                                            value: stateAddSn
                                                                .numberOfArticles,
                                                            minValue: 1,
                                                            maxValue: 20,
                                                            onChanged: (int a) {
                                                              context
                                                                  .read<
                                                                      NumberOfArticlesCubit>()
                                                                  .update(stateAddSn
                                                                      .copyWith(
                                                                          numberOfArticles:
                                                                              a));
                                                            }),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 12),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              12),
                                                                      backgroundColor:
                                                                          YELLOW,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25))),
                                                                  onPressed: (stateAddSn
                                                                          .nature
                                                                          .isNotEmpty)
                                                                      ? () async {
                                                                          var numSerie = (numSerieController.text.length < 5)
                                                                              ? generateRandomString(12)
                                                                              : numSerieController.text;
                                                                          Non_Etiquete newSn = Non_Etiquete(
                                                                              numSerie,
                                                                              context.read<SettingsBloc>().settingsrepository.modeScan,
                                                                              DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                                                                              state.localisation!.code_bar,
                                                                              1,
                                                                              state.localisation!.cop_id,
                                                                              context.read<AuthenticationBloc>().authenticationRepository.user!.matricule,
                                                                              marqueController.text,
                                                                              modeleController.text,
                                                                              stateAddSn.nature,
                                                                              stateAddSn.numberOfArticles,
                                                                              null,
                                                                              null);
                                                                          syncBloc
                                                                              .add(SynchronizationAddSn(sn: newSn));
                                                                          Navigator.pop(
                                                                              context);
                                                                          showTopSnackBar(
                                                                            Overlay.of(context),
                                                                            const CustomSnackBar.success(
                                                                              message: 'Ajouté avec succès !',
                                                                            ),
                                                                          );

                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) {
                                                                            return DetailSnPage(sn: newSn);
                                                                          }));
                                                                        }
                                                                      : null,
                                                                  child: Text(
                                                                    "Valider",
                                                                    style: defaultTextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                    ),
                                  );
                                });
                          },
                          child: Text(
                            "+ SN",
                            style: defaultTextStyle(
                                color: purple, fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(25, 10, 25, 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        )
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.edit,
                              color: MAINCOLOR,
                            ),
                          )),
                      Flexible(
                          flex: 5,
                          child: TextFormField(
                            textCapitalization: TextCapitalization.characters,
                            controller: codeBarController,
                            decoration: InputDecoration(
                              hintText: "Saisir le code bar",
                              hintStyle: defaultTextStyle(color: GRAY),
                              fillColor: Colors.white,
                              filled: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          )),
                      Flexible(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: purple, // Background color
                              shape: BoxShape.circle, // Circular shape
                            ),
                            child: IconButton(
                                onPressed: () async {
                                  if (BienMaterielRegex.hasMatch(
                                      codeBarController.text.trim())) {
                                    Bien_materiel newBien = Bien_materiel(
                                        codeBarController.text.trim(),
                                        context
                                            .read<SettingsBloc>()
                                            .settingsrepository
                                            .modeScan,
                                        DateFormat('yyyy-MM-dd HH:mm')
                                            .format(DateTime.now()),
                                        state.localisation?.code_bar ?? "",
                                        1,
                                        state.localisation?.cop_id ?? "",
                                        context
                                                .read<AuthenticationBloc>()
                                                .authenticationRepository
                                                .user
                                                ?.matricule ??
                                            "",
                                        context
                                            .read<AuthenticationBloc>()
                                            .authenticationRepository
                                            .user
                                            ?.INV_ID,
                                        context
                                            .read<SynchronizationBloc>()
                                            .synchronizationRepository
                                            .pos1,
                                        context
                                            .read<SynchronizationBloc>()
                                            .synchronizationRepository
                                            .pos2);
                                    context.read<SynchronizationBloc>().add(
                                        SynchronizationAddBien(bien: newBien));
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      const CustomSnackBar.success(
                                        message: 'Ajouté avec succès !',
                                      ),
                                    );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => DetailBienPage(
                                                bien: newBien,
                                              )),
                                    );
                                  } else {
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      const CustomSnackBar.error(
                                        message: 'Code bar incorrect !',
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                )),
                          ))
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Article",
                        style: defaultTextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      TextButton(
                          onPressed: () {
                            scanBarcodeNormal(context);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.sync_alt,
                                color: YELLOW,
                              ),
                              Text(
                                "Changer localité",
                                style: defaultTextStyle(
                                    color: YELLOW, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: MAINCOLOR,
                            borderRadius: BorderRadius.circular(13)),
                        margin: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.05,
                            0,
                            MediaQuery.of(context).size.width * 0.025,
                            MediaQuery.of(context).size.width * 0.025),
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.width * 0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              color: YELLOW,
                            ),
                            Text(
                              "Code bar",
                              style: defaultTextStyle(color: Colors.white),
                            ),
                            Text(
                              bien.code_bar,
                              style: defaultTextStyle(color: YELLOW),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13)),
                        margin: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.025,
                            0,
                            MediaQuery.of(context).size.width * 0.05,
                            MediaQuery.of(context).size.width * 0.025),
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.width * 0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: GRAY,
                            ),
                            Text(
                              "Date de scan",
                              style: defaultTextStyle(color: GRAY),
                            ),
                            Text(
                              bien.date_scan,
                              style: defaultTextStyle(color: GRAY),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13)),
                        margin: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.05,
                            MediaQuery.of(context).size.width * 0.025,
                            MediaQuery.of(context).size.width * 0.025,
                            MediaQuery.of(context).size.width * 0.025),
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.width * 0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.home,
                              color: GRAY,
                            ),
                            Text(
                              "Localité",
                              style: defaultTextStyle(color: GRAY),
                            ),
                            Text(
                              "${state.localisation?.designation}",
                              style: defaultTextStyle(color: GRAY),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13)),
                        margin: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.025,
                            MediaQuery.of(context).size.width * 0.025,
                            MediaQuery.of(context).size.width * 0.05,
                            MediaQuery.of(context).size.width * 0.025),
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.width * 0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.person,
                              color: GRAY,
                            ),
                            Text(
                              "Scanné par",
                              style: defaultTextStyle(color: GRAY),
                            ),
                            Text(
                              "${context.read<AuthenticationBloc>().authenticationRepository.user?.nom}",
                              style: defaultTextStyle(color: GRAY),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ]);
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
