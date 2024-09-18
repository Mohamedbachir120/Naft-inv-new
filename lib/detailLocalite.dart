import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:naftinv/Login.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/cubit/number_of_articles_cubit_cubit.dart';
import 'package:naftinv/blocs/settings_bloc/bloc/settings_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/data/Non_Etiquete.dart';
import 'package:naftinv/detailBien.dart';
import 'package:naftinv/detailSn.dart';
import 'package:naftinv/localites.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class DetailLocalitePage extends StatelessWidget {
  final Localisation localisation;
  TextEditingController codeBarController = TextEditingController();
  TextEditingController natureController = TextEditingController();
  TextEditingController numSerieController = TextEditingController();
  TextEditingController marqueController = TextEditingController();
  TextEditingController modeleController = TextEditingController();

  DetailLocalitePage({super.key, required this.localisation});
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

    return Scaffold(
      bottomNavigationBar: CustomBottomBarWidget(context, 1),
      body: SingleChildScrollView(
        child: BlocBuilder<SynchronizationBloc, SynchronizationState>(
          builder: (context, state) {
            if (state is SynchronizationInitial) {
              return Column(children: [
                Container(
                  decoration: BoxDecoration(
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LocalitePage()),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: YELLOW,
                                  )),
                            ),
                            Flexible(
                              flex: 3,
                              child: Text(localisation.designation,
                                  textAlign: TextAlign.center,
                                  style: defaultTextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                            Flexible(flex: 1, child: Text(""))
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localisation.code_bar,
                              style: defaultTextStyle(color: Colors.white),
                            ),
                            Text(
                              "${state.localites.firstWhere((e) => e.code_bar == localisation.code_bar).biens.length + state.localites.firstWhere((e) => e.code_bar == localisation.code_bar).nonEtiqu.length} Articles",
                              style: defaultTextStyle(color: GRAY),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 25),
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
                                        if (state is SettingsInitial) {
                                          return Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.73,
                                            padding: EdgeInsets.all(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.settings),
                                                    Text(
                                                      "Paramétrer votre application",
                                                      style: defaultTextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.038),
                                                    )
                                                  ],
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          MediaQuery.of(context)
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
                                                            Icon(
                                                              Icons.flash_on,
                                                              color: YELLOW,
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
                                                        flex: 2,
                                                        child: Expanded(
                                                          child: RadioListTile<
                                                              bool>(
                                                            title: const Text(
                                                                'On'),
                                                            value: true,
                                                            groupValue:
                                                                state.flash,
                                                            onChanged: (val) {
                                                              settingsBloc.add(
                                                                  SettingsUpdateFlash());
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 2,
                                                        child:
                                                            RadioListTile<bool>(
                                                          title:
                                                              const Text('Off'),
                                                          value: false,
                                                          groupValue:
                                                              state.flash,
                                                          onChanged: (val) {
                                                            settingsBloc.add(
                                                                SettingsUpdateFlash());
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
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
                                                            Icon(
                                                              Icons
                                                                  .barcode_reader,
                                                              color: YELLOW,
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
                                                            RadioListTile<int>(
                                                          title:
                                                              const Text('1'),
                                                          value: 1,
                                                          groupValue:
                                                              state.lecteur,
                                                          onChanged: (val) {
                                                            settingsBloc.add(
                                                                SettingsUpdateLecteur(
                                                                    lecteur:
                                                                        1));
                                                          },
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            RadioListTile<int>(
                                                          title:
                                                              const Text('2'),
                                                          value: 2,
                                                          groupValue:
                                                              state.lecteur,
                                                          onChanged: (val) {
                                                            settingsBloc.add(
                                                                SettingsUpdateLecteur(
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
                                                      bottom:
                                                          MediaQuery.of(context)
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
                                                            Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color: YELLOW,
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
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 4,
                                                                  horizontal:
                                                                      8),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  LIGHTYELLOW,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25)),
                                                          child: DropdownButton<
                                                              int>(
                                                            style:
                                                                defaultTextStyle(),
                                                            dropdownColor:
                                                                Colors.white,
                                                            underline:
                                                                Container(),
                                                            iconSize: 0,
                                                            hint: Text(
                                                                'Select an option'), // Hint when no item is selected
                                                            value: state
                                                                .modeScan, // The currently selected item
                                                            items: [
                                                              1,
                                                              2,
                                                              3
                                                            ].map((int item) {
                                                              return DropdownMenuItem<
                                                                  int>(
                                                                value:
                                                                    item, // Set the value to the current item, not state.modeScan
                                                                child: Text(
                                                                    valueState(item)),
                                                              );
                                                            }).toList(),
                                                            onChanged: (int?
                                                                newValue) {
                                                              // Update the selected value with the new selection
                                                              settingsBloc.add(
                                                                  SettingsUpdateMode(
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
                                          return CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                  );
                                });
                          },
                          child: Icon(
                            Icons.more_horiz,
                            color: purple,
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              scanBarcodeNormal(context, operation: 2);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    " Scanner",
                                    style:
                                        defaultTextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            )),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          final syncBloc = context.read<SynchronizationBloc>();
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
                                                builder: (context, stateAddSn) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
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
                                                            EdgeInsets.all(8),
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
                                                                  .circular(25),
                                                        ),
                                                        child: TextFormField(
                                                          initialValue: state
                                                              .localisation!
                                                              .code_bar,
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
                                                        onSelected:
                                                            (String selection) {
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
                                                                InputDecoration(
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
                                                                Iterable<String>
                                                                    options) {
                                                          return Material(
                                                            elevation: 4.0,
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              color:
                                                                  Colors.white,
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
                                                                    onTap: () {
                                                                      context
                                                                          .read<
                                                                              NumberOfArticlesCubit>()
                                                                          .update(
                                                                              stateAddSn.copyWith(nature: option));
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
                                                            EdgeInsets.all(8),
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
                                                                  .circular(25),
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
                                                            EdgeInsets.all(8),
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
                                                                  .circular(25),
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
                                                            EdgeInsets.all(8),
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
                                                                  .circular(25),
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
                                                            EdgeInsets.fromLTRB(
                                                                10, 5, 0, 0),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(Icons
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
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            12),
                                                                    backgroundColor:
                                                                        YELLOW,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(25))),
                                                                onPressed: (numSerieController.text.trim().length >
                                                                            3) &&
                                                                        (stateAddSn.nature.isNotEmpty)
                                                                    ? () {
                                                                        Non_Etiquete newSn = Non_Etiquete(
                                                                            numSerieController.text,
                                                                            context.read<SettingsBloc>().settingsrepository.modeScan,
                                                                            DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                                                                            state.localisation!.code_bar,
                                                                            1,
                                                                            state.localisation!.cop_id,
                                                                            context.read<AuthenticationBloc>().authenticationRepository.user!.matricule,
                                                                            marqueController.text,
                                                                            modeleController.text,
                                                                            stateAddSn.nature,
                                                                            stateAddSn.numberOfArticles);
                                                                        syncBloc
                                                                            .add(SynchronizationAddSn(sn: newSn));
                                                                        Navigator.pop(
                                                                            context);

                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => DetailSnPage(sn: newSn)));
                                                                        showTopSnackBar(
                                                                          Overlay.of(
                                                                              context),
                                                                          const CustomSnackBar
                                                                              .success(
                                                                            message:
                                                                                'Ajouté avec succès !',
                                                                          ),
                                                                        );
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
                                        return SizedBox();
                                      }
                                    },
                                  ),
                                );
                              });
                        },
                        style:
                            ElevatedButton.styleFrom(backgroundColor: purple),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              Text(
                                " SN",
                                style: defaultTextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "OU",
                      style: defaultTextStyle(
                          color: YELLOW,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(25, 10, 25, 0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 4,
                          offset: Offset(0, 3),
                        )
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                            margin: EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: purple, // Background color
                              shape: BoxShape.circle, // Circular shape
                            ),
                            child: IconButton(
                                onPressed: () {
                                  if (BienMaterielRegex.hasMatch(
                                      codeBarController.text.trim())) {
                                    context.read<SynchronizationBloc>().add(
                                        SynchronizationAddBien(
                                            bien: Bien_materiel(
                                                codeBarController.text.trim(),
                                                context
                                                    .read<SettingsBloc>()
                                                    .settingsrepository
                                                    .modeScan,
                                                DateFormat('yyyy-MM-dd HH:mm')
                                                    .format(DateTime.now()),
                                                state.localisation?.code_bar ??
                                                    "",
                                                1,
                                                state.localisation?.cop_id ??
                                                    "",
                                                context
                                                        .read<
                                                            AuthenticationBloc>()
                                                        .authenticationRepository
                                                        .user
                                                        ?.matricule ??
                                                    "",
                                                context
                                                    .read<AuthenticationBloc>()
                                                    .authenticationRepository
                                                    .user
                                                    ?.INV_ID)));
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      const CustomSnackBar.success(
                                        message: 'Ajouté avec succès !',
                                      ),
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
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                )),
                          ))
                    ],
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.width * 0.6,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.black12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${state.localites.firstWhere((e) => e.code_bar == localisation.code_bar).biens.length + state.localites.firstWhere((e) => e.code_bar == localisation.code_bar).nonEtiqu.length}",
                            style: defaultTextStyle(
                                color: YELLOW,
                                fontSize: 46,
                                fontWeight: FontWeight.w800),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory,
                                color: YELLOW,
                                size: 36,
                              ),
                              Text(
                                "   Articles",
                                style: defaultTextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w800,
                                    color: YELLOW),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ]);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class BienWidget extends StatelessWidget {
  const BienWidget({super.key, required this.bien});
  final Bien_materiel bien;

  @override
  Widget build(BuildContext context) {
    DateTime current = DateTime.parse(bien.date_scan);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => DetailBienPage(
                    bien: bien,
                  )),
        );
      },
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                    color: LIGHTGRAY,
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: Offset(0, 15))
              ]),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  flex: 4,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            decoration: BoxDecoration(
                                color: MAINCOLOR,
                                borderRadius: BorderRadius.circular(13)),
                            height: MediaQuery.of(context).size.width * 0.19,
                            padding: EdgeInsets.only(top: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(current.day),
                                  style: defaultTextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  formatDate(current.month),
                                  style: defaultTextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  decoration: BoxDecoration(
                                      color: YELLOW,
                                      borderRadius: BorderRadius.circular(13)),
                                  child: Text(
                                    "${formatDate(current.hour)}:${formatDate(current.minute)}",
                                    style: defaultTextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              ],
                            )),
                      ),
                      Flexible(
                          flex: 3,
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.19,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  get_etat(bien.etat),
                                  style: defaultTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  bien.code_localisation,
                                  style: defaultTextStyle(
                                      fontSize: 12,
                                      color: YELLOW,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  bien.code_bar,
                                  style: defaultTextStyle(
                                      fontSize: 12,
                                      color: GRAY,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ))
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "NEW",
                  style: defaultTextStyle(color: purple),
                ),
              )
            ],
          )),
    );
  }
}
// ignore_for_file: prefer_const_constructors

class SNWidget extends StatelessWidget {
  const SNWidget({super.key, required this.sn});
  final Non_Etiquete sn;

  @override
  Widget build(BuildContext context) {
    DateTime current = DateTime.parse(sn.date_scan);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => DetailSnPage(
                    sn: sn,
                  )),
        );
      },
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                    color: LIGHTGRAY,
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: Offset(0, 15))
              ]),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  flex: 4,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            decoration: BoxDecoration(
                                color: MAINCOLOR,
                                borderRadius: BorderRadius.circular(13)),
                            height: MediaQuery.of(context).size.width * 0.19,
                            padding: EdgeInsets.only(top: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(current.day),
                                  style: defaultTextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  formatDate(current.month),
                                  style: defaultTextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  decoration: BoxDecoration(
                                      color: YELLOW,
                                      borderRadius: BorderRadius.circular(13)),
                                  child: Text(
                                    "${formatDate(current.hour)}:${formatDate(current.minute)}",
                                    style: defaultTextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              ],
                            )),
                      ),
                      Flexible(
                          flex: 3,
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.19,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  get_etat(sn.etat),
                                  style: defaultTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  sn.nature,
                                  overflow: TextOverflow.ellipsis,
                                  style: defaultTextStyle(
                                      fontSize: 12, color: YELLOW),
                                ),
                                Text(
                                  sn.num_serie,
                                  overflow: TextOverflow.ellipsis,
                                  style: defaultTextStyle(
                                      fontSize: 12, color: GRAY),
                                ),
                              ],
                            ),
                          ))
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "NEW",
                  style: defaultTextStyle(color: purple),
                ),
              )
            ],
          )),
    );
  }
}
