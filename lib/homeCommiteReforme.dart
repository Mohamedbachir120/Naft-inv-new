import 'package:barcode_scan2/model/android_options.dart';
import 'package:barcode_scan2/model/scan_options.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/cubit/bien_immo/bien_immo_cubit.dart';
import 'package:naftinv/blocs/cubit/password/password_cubit.dart';
import 'package:naftinv/blocs/settings_bloc/bloc/settings_bloc.dart';
import 'package:naftinv/components/AvatarComponent.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/data/BienImmo.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/repositories/authentication_repository.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomeCommiteReforme extends StatelessWidget {
  HomeCommiteReforme({super.key});
  TextEditingController codeBarController = TextEditingController();

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: BlocProvider(
          create: (context) =>
              ChangePasswordCubit(context.read<AuthenticationRepository>()),
          child: MultiBlocListener(
            listeners: [
              BlocListener<BienImmoCubit, BienImmoState>(
                listener: (context, state) {
                  if (state is BienImmoUpdated) {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.success(
                        message: 'Modifié avec succès !',
                      ),
                    );
                  } else if (state is BienImmoError) {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.error(
                        message: 'Erreur  article introuvable!',
                      ),
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                return Container(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width * 0.4,
                        decoration: const BoxDecoration(
                            color: MAINCOLOR,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50))),
                        padding: const EdgeInsets.fromLTRB(25, 40, 25, 30),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Avatarcomponent(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.37,
                                            backgroundColor: purple,
                                            color: Colors.white,
                                            text: state.user?.nom[0] ?? "U"),
                                      ),
                                      Flexible(
                                        flex: 5,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                state.user?.nom ??
                                                    "User commite ",
                                                style: defaultTextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "${state.user?.COP_ID}",
                                                      style: defaultTextStyle(
                                                        color: GRAY,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const Icon(
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
                                                                  flex: 2,
                                                                  child:
                                                                      RadioListTile<
                                                                          bool>(
                                                                    title:
                                                                        const Text(
                                                                            'On'),
                                                                    value: true,
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
                                                                Flexible(
                                                                  flex: 2,
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
                                    icon: const Icon(
                                      Icons.settings,
                                      color: YELLOW,
                                      size: 32,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Liste des dossiers",
                                  style: defaultTextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            Text(
                              "Wednesday, 11 May",
                              style: defaultTextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            const FilterDocumentWidget(
                              title: "Tous",
                              isSelected: true,
                              value: 35,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                color: Colors.grey[300],
                              ),
                              width: 5,
                              height: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const FilterDocumentWidget(
                              title: "Ouverts",
                              isSelected: false,
                              value: 27,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const FilterDocumentWidget(
                              title: "Fermés",
                              isSelected: false,
                              value: 8,
                            ),
                          ],
                        ),
                      ),
                      const DocumentWidget(
                        name: 'DOC_12345678T67',
                        date: "Jan 2025",
                        isClosed: true,
                        percentage: 0.6,
                      )
                      // BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                      //   builder: (context, state) {
                      //     return Container(
                      //       padding: EdgeInsets.symmetric(
                      //           vertical:
                      //               MediaQuery.of(context).size.width * 0.012,
                      //           horizontal:
                      //               MediaQuery.of(context).size.width * 0.05),
                      //       child: InkWell(
                      //         onTap: () {
                      //           ChangePasswordCubit cubit =
                      //               context.read<ChangePasswordCubit>();
                      //           final oldPasswordController =
                      //               TextEditingController();
                      //           final newPasswordController =
                      //               TextEditingController();

                      //           showDialog(
                      //             context: context,
                      //             builder: (BuildContext context) {
                      //               return BlocProvider.value(
                      //                 value: cubit,
                      //                 child: AlertDialog(
                      //                   titleTextStyle: defaultTextStyle(
                      //                     fontSize: MediaQuery.of(context)
                      //                             .size
                      //                             .width *
                      //                         0.04,
                      //                     fontWeight: FontWeight.w700,
                      //                   ),
                      //                   backgroundColor: Colors.white,
                      //                   title: const Text(
                      //                       'Changer le mot de passe'),
                      //                   content: BlocListener<
                      //                       ChangePasswordCubit,
                      //                       ChangePasswordState>(
                      //                     listener: (context, state) {
                      //                       if (state
                      //                           is ChangePasswordSuccess) {
                      //                         // Show success message
                      //                         showTopSnackBar(
                      //                           Overlay.of(context),
                      //                           const CustomSnackBar.success(
                      //                             message:
                      //                                 'Modifié avec succès !',
                      //                           ),
                      //                         );
                      //                         Navigator.pop(
                      //                             context); // Close dialog
                      //                       } else if (state
                      //                           is ChangePasswordFailure) {
                      //                         // Show failure message
                      //                         showTopSnackBar(
                      //                           Overlay.of(context),
                      //                           const CustomSnackBar.error(
                      //                             message:
                      //                                 'Ancier mot de passe incorrect !',
                      //                           ),
                      //                         );
                      //                       }
                      //                     },
                      //                     child: Container(
                      //                       child: Column(
                      //                         crossAxisAlignment:
                      //                             CrossAxisAlignment.start,
                      //                         mainAxisSize: MainAxisSize.min,
                      //                         children: [
                      //                           // Old Password Input Field
                      //                           Container(
                      //                             decoration: BoxDecoration(
                      //                               color: Colors.white,
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       25),
                      //                             ),
                      //                             child: TextFormField(
                      //                               controller:
                      //                                   oldPasswordController,
                      //                               decoration: InputDecoration(
                      //                                 labelText:
                      //                                     "Ancien mot de passe",
                      //                                 suffixIcon: IconButton(
                      //                                   onPressed: () {},
                      //                                   icon: const Icon(
                      //                                     Icons.remove_red_eye,
                      //                                     color: MAINCOLOR,
                      //                                   ),
                      //                                 ),
                      //                                 labelStyle:
                      //                                     defaultTextStyle(),
                      //                                 focusedBorder:
                      //                                     const UnderlineInputBorder(
                      //                                   borderSide: BorderSide(
                      //                                       color: GRAY),
                      //                                 ),
                      //                                 enabledBorder:
                      //                                     const UnderlineInputBorder(
                      //                                   borderSide: BorderSide(
                      //                                       color: GRAY),
                      //                                 ),
                      //                                 border:
                      //                                     const UnderlineInputBorder(
                      //                                   borderSide: BorderSide(
                      //                                       color: GRAY),
                      //                                 ),
                      //                               ),
                      //                               obscureText:
                      //                                   true, // Make it password field
                      //                               style: const TextStyle(
                      //                                 fontFamily: "Poppins",
                      //                               ),
                      //                             ),
                      //                           ),
                      //                           const SizedBox(height: 20),

                      //                           // New Password Input Field
                      //                           Container(
                      //                             decoration: BoxDecoration(
                      //                               color: Colors.white,
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       25),
                      //                             ),
                      //                             child: TextFormField(
                      //                               controller:
                      //                                   newPasswordController,
                      //                               decoration: InputDecoration(
                      //                                 labelText:
                      //                                     "Nouveau mot de passe",
                      //                                 suffixIcon: IconButton(
                      //                                   onPressed: () {},
                      //                                   icon: const Icon(
                      //                                     Icons.remove_red_eye,
                      //                                     color: MAINCOLOR,
                      //                                   ),
                      //                                 ),
                      //                                 labelStyle:
                      //                                     defaultTextStyle(),
                      //                                 focusedBorder:
                      //                                     const UnderlineInputBorder(
                      //                                   borderSide: BorderSide(
                      //                                       color: GRAY),
                      //                                 ),
                      //                                 enabledBorder:
                      //                                     const UnderlineInputBorder(
                      //                                   borderSide: BorderSide(
                      //                                       color: GRAY),
                      //                                 ),
                      //                                 border:
                      //                                     const UnderlineInputBorder(
                      //                                   borderSide: BorderSide(
                      //                                       color: GRAY),
                      //                                 ),
                      //                               ),
                      //                               obscureText:
                      //                                   true, // Make it password field
                      //                               style: const TextStyle(
                      //                                 fontFamily: "Poppins",
                      //                               ),
                      //                             ),
                      //                           ),
                      //                           const SizedBox(height: 20),

                      //                           // Submit Button
                      //                           ElevatedButton(
                      //                             style:
                      //                                 ElevatedButton.styleFrom(
                      //                               shape:
                      //                                   RoundedRectangleBorder(
                      //                                 borderRadius:
                      //                                     BorderRadius.circular(
                      //                                         20),
                      //                               ),
                      //                               backgroundColor: purple,
                      //                               textStyle: const TextStyle(
                      //                                   color: Colors.white),
                      //                             ),
                      //                             onPressed: () async {
                      //                               final oldPassword =
                      //                                   oldPasswordController
                      //                                       .text;
                      //                               final newPassword =
                      //                                   newPasswordController
                      //                                       .text;

                      //                               if (oldPassword.isEmpty ||
                      //                                   newPassword.isEmpty) {
                      //                                 showTopSnackBar(
                      //                                   Overlay.of(context),
                      //                                   const CustomSnackBar
                      //                                       .error(
                      //                                     message:
                      //                                         'Veuillez remplir tous les champs !',
                      //                                   ),
                      //                                 );
                      //                                 return;
                      //                               }

                      //                               // Call cubit to change password
                      //                               cubit.changePassword(
                      //                                 oldPassword,
                      //                                 newPassword,
                      //                               );
                      //                             },
                      //                             child: Padding(
                      //                               padding: const EdgeInsets
                      //                                   .symmetric(
                      //                                 vertical: 12,
                      //                                 horizontal: 12,
                      //                               ),
                      //                               child: Row(
                      //                                 mainAxisAlignment:
                      //                                     MainAxisAlignment
                      //                                         .center,
                      //                                 children: <Widget>[
                      //                                   Text(
                      //                                     'Changer le mot de passe',
                      //                                     style:
                      //                                         defaultTextStyle(
                      //                                       fontSize: 14.0,
                      //                                       fontWeight:
                      //                                           FontWeight.w700,
                      //                                       color: Colors.white,
                      //                                     ),
                      //                                   ),
                      //                                 ],
                      //                               ),
                      //                             ),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //           );
                      //         },
                      //         child: Container(
                      //           padding: EdgeInsets.all(
                      //               MediaQuery.of(context).size.width * 0.05),
                      //           decoration: BoxDecoration(
                      //               border: Border.all(color: GRAY),
                      //               borderRadius: BorderRadius.circular(13)),
                      //           child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.start,
                      //               children: [
                      //                 const Icon(
                      //                   Icons.lock_outline,
                      //                   color: purple,
                      //                 ),
                      //                 Text(
                      //                   "Modifier mot de passe",
                      //                   style: defaultTextStyle(color: purple),
                      //                 )
                      //               ]),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //       vertical: MediaQuery.of(context).size.width * 0.012,
                      //       horizontal:
                      //           MediaQuery.of(context).size.width * 0.05),
                      //   child: InkWell(
                      //     onTap: () {
                      //       context
                      //           .read<AuthenticationBloc>()
                      //           .add(AuthenticationSignOut());
                      //     },
                      //     child: Container(
                      //       padding: EdgeInsets.all(
                      //           MediaQuery.of(context).size.width * 0.05),
                      //       decoration: BoxDecoration(
                      //           border: Border.all(color: GRAY),
                      //           borderRadius: BorderRadius.circular(13)),
                      //       child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.start,
                      //           children: [
                      //             const Icon(
                      //               Icons.logout_outlined,
                      //               color: MAINCOLOR,
                      //             ),
                      //             Text(
                      //               "Déconnexion",
                      //               style: defaultTextStyle(),
                      //             )
                      //           ]),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentWidget extends StatelessWidget {
  final String name;
  final String date;
  final bool isClosed;
  final double percentage;

  const DocumentWidget({
    super.key,
    required this.name,
    required this.date,
    required this.isClosed,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Color(0xffD8D8D8))),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: itemTextColors[
                            name.codeUnitAt(0) % itemTextColors.length],
                      ),
                      child: Icon(
                        Icons.file_present,
                        color: Colors.white,
                      )),
                ),
                SizedBox(
                  width: 8,
                ),
                Flexible(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: defaultTextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        date,
                        style: defaultTextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          !isClosed
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: itemBgColors[8],
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    "Clôturé",
                    style: defaultTextStyle(color: itemTextColors[8]),
                  ),
                )
              : Flexible(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            // Background of the progress bar
                            Container(
                              width:
                                  80, // Ensure this matches the full width of the bar
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey[300], // Light grey for the background
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            // Foreground (progress)
                            Container(
                              width: 80.0 *
                                  percentage, // Adjust width dynamically based on progress (e.g., 70%)
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: MAINCOLOR, // Blue for the progress
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${(percentage * 100).round()}%',
                          style: defaultTextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

class FilterDocumentWidget extends StatelessWidget {
  const FilterDocumentWidget(
      {super.key,
      required this.isSelected,
      required this.title,
      required this.value});
  final String title;
  final int value;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(
            title,
            style:
                defaultTextStyle(color: isSelected ? MAINCOLOR : Colors.grey),
          ),
          const SizedBox(
            width: 5,
          ),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: isSelected ? MAINCOLOR : Colors.grey[200],
                  borderRadius: BorderRadius.circular(13)),
              child: Text(
                "$value",
                style: defaultTextStyle(
                    color: isSelected ? Colors.white : Colors.grey),
              ))
        ],
      ),
    );
  }
}

class InitialWidget extends StatelessWidget {
  const InitialWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(25)),
      height: MediaQuery.of(context).size.height * 0.4,
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.redAccent,
          ),
          Text(
            "Aucun article sélectionné",
            style: defaultTextStyle(color: Colors.redAccent),
          ),
        ],
      )),
    );
  }
}

class ViewDetailsBienImmo extends StatelessWidget {
  final BienImmo bienImmo;
  const ViewDetailsBienImmo({super.key, required this.bienImmo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(25)),
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(
          vertical: 10, horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded),
              Text(
                '  CODE BAR:',
                style: defaultTextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            bienImmo.AST_CB,
            style: defaultTextStyle(color: purple),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(Icons.copy),
              Text(
                '  LIBELLÉ:',
                style: defaultTextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            "${bienImmo.AST_LIB}",
            style: defaultTextStyle(color: purple),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(Icons.branding_watermark_outlined),
              Text(
                '  MARQUE:',
                style: defaultTextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            "${bienImmo.AST_MARQUE}",
            style: defaultTextStyle(color: purple),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(Icons.badge_rounded),
              Text(
                '  MODÉLE:',
                style: defaultTextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            "${bienImmo.AST_MODELE}",
            style: defaultTextStyle(color: purple),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(Icons.numbers),
              Text(
                '  NUMÉRO DE SERIE:',
                style: defaultTextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            "${bienImmo.AST_SERIAL_NEMBER}",
            style: defaultTextStyle(color: purple),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(Icons.person_2_outlined),
              Text(
                '  AFFECTÉ A:',
                style: defaultTextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            "${bienImmo.EMP_FULLNAME_AMU} - ${bienImmo.EMP_ID_AMU}",
            style: defaultTextStyle(color: purple),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () {
                  context.read<BienImmoCubit>().editBien(bienImmo);
                },
                child: Text(
                  "Modifier",
                  style: defaultTextStyle(color: Colors.white),
                ),
              ))
            ],
          )
        ],
      ),
    );
  }
}

Widget buildFieldRow(IconData icon, String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon),
          Text('  $label', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      Text(value, style: const TextStyle(color: Colors.purple)),
      const SizedBox(height: 10),
    ],
  );
}

Widget buildBienImmoEditForm(BuildContext context, BienImmo bienImmo) {
  final TextEditingController astCbController =
      TextEditingController(text: bienImmo.AST_CB);
  final TextEditingController astLibController =
      TextEditingController(text: bienImmo.AST_LIB);
  final TextEditingController astModeleController =
      TextEditingController(text: bienImmo.AST_MODELE);
  final TextEditingController astSerialNumberController =
      TextEditingController(text: bienImmo.AST_SERIAL_NEMBER);
  final TextEditingController astMarqueController =
      TextEditingController(text: bienImmo.AST_MARQUE);
  final TextEditingController empIdAmuController = TextEditingController(
    text: bienImmo.EMP_ID_AMU,
  );
  final TextEditingController empFullNameAmuController =
      TextEditingController(text: bienImmo.EMP_FULLNAME_AMU);

  final TextEditingController matriculeCarController =
      TextEditingController(text: bienImmo.AST_TV_MATRICULE);

  final TextEditingController codeCarController =
      TextEditingController(text: bienImmo.AST_TV_CODE);

  return Container(
    decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(25)),
    padding: const EdgeInsets.all(10),
    margin: EdgeInsets.symmetric(
        vertical: 10, horizontal: MediaQuery.of(context).size.width * 0.05),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input fields for editing attributes
        buildEditableFieldRow(context, 'CODE BAR:', astCbController),
        buildEditableFieldRow(context, 'LIBELLÉ:', astLibController),
        buildEditableFieldRow(context, 'MARQUE:', astMarqueController),
        buildEditableFieldRow(context, 'MODÉLE:', astModeleController),
        buildEditableFieldRow(
            context, 'NUMÉRO DE SERIE:', astSerialNumberController,
            isScannbel: true),
        buildEditableFieldRow(context, 'AFFECTÉ A:', empIdAmuController,
            isDisabled: bienImmo.EMP_ID_AMU?.trim().isNotEmpty),
        buildEditableFieldRow(context, 'Code Véhicule:', codeCarController),
        buildEditableFieldRow(
            context, 'Matricule Véhicule:', matriculeCarController),

        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () {
                    context.read<BienImmoCubit>().switchToView(bienImmo);
                  },
                  child: Text(
                    "Annuler",
                    style: defaultTextStyle(color: Colors.white),
                  )),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Update the BienImmo object
                  final updatedBien = bienImmo.copyWith(
                      AST_CB: astCbController.text,
                      AST_LIB: astLibController.text,
                      AST_MODELE: astModeleController.text,
                      AST_SERIAL_NEMBER: astSerialNumberController.text,
                      AST_MARQUE: astMarqueController.text,
                      EMP_ID_AMU: empIdAmuController.text,
                      EMP_FULLNAME_AMU: empFullNameAmuController.text,
                      AST_TV_CODE: codeCarController.text,
                      AST_TV_MATRICULE: matriculeCarController.text);

                  context
                      .read<BienImmoCubit>()
                      .updateBien(bienImmo, updatedBien);
                },
                child: Text(
                  "Enregistrer",
                  style: defaultTextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        )
      ],
    ),
  );
}

Widget buildEditableFieldRow(
    BuildContext context, String label, TextEditingController controller,
    {isScannbel = false, isDisabled = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isDisabled,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(25))),
            ),
          ),
          isScannbel
              ? IconButton(
                  onPressed: () async {
                    try {
                      if (context
                              .read<SettingsBloc>()
                              .settingsrepository
                              .lecteur ==
                          0) {
                        final result = await BarcodeScanner.scan(
                          options: ScanOptions(
                            autoEnableFlash: context
                                .read<SettingsBloc>()
                                .settingsrepository
                                .flash,
                            android: const AndroidOptions(
                              aspectTolerance: 0.00,
                              useAutoFocus: true,
                            ),
                          ),
                        );
                        controller.text = result.rawContent;
                      } else {
                        controller.text =
                            await FlutterBarcodeScanner.scanBarcode(
                                '#ff6666', 'Cancel', true, ScanMode.BARCODE);
                      }
                    } on PlatformException {
                      controller.text = 'Failed to get platform version.';
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined))
              : const SizedBox.shrink()
        ],
      ),
      const SizedBox(height: 10),
    ],
  );
}
