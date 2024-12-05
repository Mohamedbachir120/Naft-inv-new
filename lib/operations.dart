import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/cubit/taux/taux_cubit.dart';
import 'package:naftinv/blocs/settings_bloc/bloc/settings_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/components/AvatarComponent.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/detailLocalite.dart';

import 'package:naftinv/localites.dart';
import 'package:skeleton_animation/skeleton_animation.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

bool check_format(int type, String value) {
  if (type == 0) {
    // Expression réguliére pour les localisations
    value.replaceAll('-', '');
    final localisation = RegExp(r'^([A-Z]|[0-9]){4}L([A-Z]|[0-9]){6,8}$');
    final localisation2 = RegExp(r'^K[0-9]{4}L[0-9]{5}$');
    return localisation.hasMatch(value) || localisation2.hasMatch(value);
  } else if (type == 1) {
    // Expression réguliére pour les bien Matériaux

    final BienMateriel = RegExp(r'^[A-Z]([0-9]|[A-Z]){7,15}$');
    return BienMateriel.hasMatch(value);
  }
  return true;
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor:
//           Colors.transparent, // Set to transparent for a fullscreen effect
//       statusBarIconBrightness:
//           Brightness.light, // Set to Brightness.dark for light icons
//       statusBarBrightness:
//           Brightness.light, // Set to Brightness.dark for light icons on iOS
//     ));

//     return BlocProvider.value(
//       value: context.read<SynchronizationBloc>(),
//       child: Scaffold(
//           backgroundColor: Colors.white,
//           bottomNavigationBar: CustomBottomBarWidget(context, 0),
//           body: Builder(builder: (BuildContext context) {
//             return SingleChildScrollView(
//                 child: BlocListener<SynchronizationBloc, SynchronizationState>(
//               listener: (context, state) {
//                 // TODO: implement listener
//                 if (state is SynchronizationInitial) {
//                   if (state.status ==
//                       SynchronizationStatus.locationServiceDisabled) {
//                     showTopSnackBar(
//                       Overlay.of(context),
//                       const CustomSnackBar.info(
//                         message:
//                             "Localisation inaccessible, Activer le service de localisation !",
//                       ),
//                     );
//                   }
//                 }
//               },
//               child: BlocBuilder<SynchronizationBloc, SynchronizationState>(
//                 builder: (context, state) {
//                   if (state is SynchronizationInitial) {
//                     return Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           BlocBuilder<AuthenticationBloc, AuthenticationState>(
//                             builder: (context, state) {
//                               return Container(
//                                 decoration: BoxDecoration(
//                                     color: MAINCOLOR,
//                                     borderRadius: BorderRadius.only(
//                                         bottomLeft: Radius.circular(50),
//                                         bottomRight: Radius.circular(50))),
//                                 padding:
//                                     const EdgeInsets.fromLTRB(25, 40, 25, 30),
//                                 child: Column(
//                                   children: [
//                                     UserHolderInfo(
//                                       state: state,
//                                     ),
//                                     ProgressionBarWidget()
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 0),
//                             child: Row(
//                               children: [
//                                 Flexible(
//                                   flex: 1,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(4.0),
//                                     child: ElevatedButton(
//                                         style: TextButton.styleFrom(
//                                             side: BorderSide(
//                                               color: MAINCOLOR,
//                                             ),
//                                             backgroundColor: Colors.white),
//                                         onPressed: () {
//                                           poursuivre_operation(context);
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 10),
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.play_circle,
//                                                 color: MAINCOLOR,
//                                               ),
//                                               Text(
//                                                 'Poursuivre',
//                                                 style: defaultTextStyle(
//                                                     fontWeight: FontWeight.w700,
//                                                     fontSize: 12),
//                                               )
//                                             ],
//                                           ),
//                                         )),
//                                   ),
//                                 ),
//                                 Flexible(
//                                   flex: 1,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(4.0),
//                                     child: ElevatedButton(
//                                         style: TextButton.styleFrom(
//                                             side: BorderSide(
//                                               color: MAINCOLOR,
//                                             ),
//                                             backgroundColor: MAINCOLOR),
//                                         onPressed: () {
//                                           scanBarcodeNormal(context);
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 10.0),
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.camera_alt_outlined,
//                                                 color: Colors.white,
//                                               ),
//                                               Text(
//                                                 '   Localité',
//                                                 style: defaultTextStyle(
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.w700,
//                                                     fontSize: 12),
//                                               )
//                                             ],
//                                           ),
//                                         )),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           Container(
//                             margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Localités visités",
//                                   style: defaultTextStyle(fontSize: 18.0),
//                                 ),
//                                 TextButton(
//                                     onPressed: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context1) =>
//                                                 LocalitePage()),
//                                       );
//                                     },
//                                     child: Text(
//                                       "Afficher plus ",
//                                       style: defaultTextStyle(color: purple),
//                                     ))
//                               ],
//                             ),
//                           ),
//                           ListView.builder(
//                               physics: ScrollPhysics(),
//                               shrinkWrap: true,
//                               itemCount: context
//                                   .read<SynchronizationBloc>()
//                                   .synchronizationRepository
//                                   .localisations
//                                   .length,
//                               padding: EdgeInsets.only(bottom: 20),
//                               itemBuilder: (context, index) {
//                                 return LocaliteWidget(
//                                   localisation: context
//                                       .read<SynchronizationBloc>()
//                                       .synchronizationRepository
//                                       .localisations[index],
//                                 );
//                               }),
//                         ]);
//                   } else {
//                     return SkeleteonOperations();
//                   }
//                 },
//               ),
//             ));
//           })),
//     );

//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Set to transparent for a fullscreen effect
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ));

    return BlocProvider.value(
      value: context.read<SynchronizationBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: CustomBottomBarWidget(context, 0),
        body: Builder(builder: (BuildContext context) {
          return BlocListener<SynchronizationBloc, SynchronizationState>(
            listener: (context, state) {
              if (state is SynchronizationInitial &&
                  state.status ==
                      SynchronizationStatus.locationServiceDisabled) {
                showTopSnackBar(
                  Overlay.of(context),
                  const CustomSnackBar.info(
                    message:
                        "Localisation inaccessible, Activer le service de localisation !",
                  ),
                );
              }
            },
            child: BlocBuilder<SynchronizationBloc, SynchronizationState>(
              builder: (context, state) {
                if (state is SynchronizationInitial) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: BlocBuilder<AuthenticationBloc,
                            AuthenticationState>(
                          builder: (context, authState) {
                            return Container(
                              decoration: BoxDecoration(
                                color: MAINCOLOR,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(50),
                                  bottomRight: Radius.circular(50),
                                ),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(25, 40, 25, 30),
                              child: Column(
                                children: [
                                  UserHolderInfo(state: authState),
                                  ProgressionBarWidget(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton(
                                    style: TextButton.styleFrom(
                                      side: BorderSide(color: MAINCOLOR),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () =>
                                        poursuivre_operation(context),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Row(
                                        children: [
                                          Icon(Icons.play_circle,
                                              color: MAINCOLOR),
                                          Text(
                                            'Poursuivre',
                                            style: defaultTextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton(
                                    style: TextButton.styleFrom(
                                      side: BorderSide(color: MAINCOLOR),
                                      backgroundColor: MAINCOLOR,
                                    ),
                                    onPressed: () => scanBarcodeNormal(context),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.camera_alt_outlined,
                                              color: Colors.white),
                                          Text(
                                            '   Localité',
                                            style: defaultTextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Localités visités",
                                style: defaultTextStyle(fontSize: 18.0),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LocalitePage()),
                                  );
                                },
                                child: Text(
                                  "Afficher plus ",
                                  style: defaultTextStyle(color: purple),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final localisation = context
                                .read<SynchronizationBloc>()
                                .synchronizationRepository
                                .localisations[index];

                            return LocaliteWidget(localisation: localisation);
                          },
                          childCount: context
                              .read<SynchronizationBloc>()
                              .synchronizationRepository
                              .localisations
                              .length,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SkeleteonOperations();
                }
              },
            ),
          );
        }),
      ),
    );
  }
}

class UserHolderInfo extends StatelessWidget {
  final AuthenticationState state;
  const UserHolderInfo({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 4,
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: Avatarcomponent(
                    height: MediaQuery.of(context).size.width * 0.37,
                    backgroundColor: purple,
                    color: Colors.white,
                    text: state.user?.nom[0] ?? "U"),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.user?.nom ?? "",
                        style: defaultTextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Text(state.centre,
                                style: defaultTextStyle(
                                  color: GRAY,
                                )),
                            Icon(
                              Icons.location_on_outlined,
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
        SettingsWidget()
      ],
    );
  }
}

class ProgressionBarWidget extends StatelessWidget {
  const ProgressionBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TauxCubit(
          authenticationRepository:
              context.read<AuthenticationBloc>().authenticationRepository),
      child: BlocBuilder<TauxCubit, TauxState>(
        builder: (context, state) {
          return Container(
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
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            " Nombre de jours restants",
                            style: defaultTextStyle(),
                          ),
                        ],
                      ),
                      state.isLoading
                          ? LoadingAnimationWidget.waveDots(
                              color: YELLOW,
                              size: 30,
                            )
                          : Text(
                              "${state.diffDays ?? "..."} jours",
                              style: defaultTextStyle(
                                  color: (state.diffDays ?? 0) > 0
                                      ? Colors.green
                                      : Colors.red),
                            )
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: LIGHTYELLOW,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: Container(
                        height: 10,
                        width: MediaQuery.of(context).size.width *
                            0.9 *
                            (state.taux ?? 0),
                        decoration: BoxDecoration(
                          color: YELLOW,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: IconButton(
        onPressed: () {
          SettingsBloc settingsBloc = context.read<SettingsBloc>();
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return BlocProvider.value(
                  value: settingsBloc,
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      if (state is SettingsInitial) {
                        return Container(
                          height: MediaQuery.of(context).size.width * 0.73,
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.settings),
                                  Text(
                                    "Paramétrer votre application",
                                    style: defaultTextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.038),
                                  )
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.025),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            style: defaultTextStyle(),
                                          )
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: RadioListTile<bool>(
                                        title: const Text('On'),
                                        value: true,
                                        groupValue: state.flash,
                                        onChanged: (val) {
                                          settingsBloc
                                              .add(SettingsUpdateFlash());
                                        },
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: RadioListTile<bool>(
                                        title: const Text('Off'),
                                        value: false,
                                        groupValue: state.flash,
                                        onChanged: (val) {
                                          settingsBloc
                                              .add(SettingsUpdateFlash());
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.width *
                                        0.025),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.barcode_reader,
                                            color: YELLOW,
                                          ),
                                          Text(
                                            " Lecteur",
                                            style: defaultTextStyle(),
                                          )
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: RadioListTile<int>(
                                        title: const Text('1'),
                                        value: 1,
                                        groupValue: state.lecteur,
                                        onChanged: (val) {
                                          settingsBloc.add(
                                              SettingsUpdateLecteur(
                                                  lecteur: 1));
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<int>(
                                        title: const Text('2'),
                                        value: 2,
                                        groupValue: state.lecteur,
                                        onChanged: (val) {
                                          settingsBloc.add(
                                              SettingsUpdateLecteur(
                                                  lecteur: 2));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.width *
                                        0.025),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: YELLOW,
                                          ),
                                          Text(
                                            " Etat du bien",
                                            style: defaultTextStyle(),
                                          )
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                            color: LIGHTYELLOW,
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: DropdownButton<int>(
                                          style: defaultTextStyle(),
                                          dropdownColor: Colors.white,
                                          underline: Container(),
                                          iconSize: 0,
                                          hint: Text(
                                              'Select an option'), // Hint when no item is selected
                                          value: state
                                              .modeScan, // The currently selected item
                                          items: [1, 2, 3].map((int item) {
                                            return DropdownMenuItem<int>(
                                              value:
                                                  item, // Set the value to the current item, not state.modeScan
                                              child: Text(valueState(item)),
                                            );
                                          }).toList(),
                                          onChanged: (int? newValue) {
                                            // Update the selected value with the new selection
                                            settingsBloc.add(SettingsUpdateMode(
                                                modeScan: newValue!));
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
        icon: Icon(
          Icons.settings,
          color: YELLOW,
          size: 32,
        ),
      ),
    );
  }
}

class SkeleteonOperations extends StatelessWidget {
  const SkeleteonOperations({super.key});

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
    return InkWell(
      onTap: () {
        context
            .read<SynchronizationBloc>()
            .add(SynchronizationDefaultLocalite(loc: localisation));
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => DetailLocalitePage(
                    localisation: localisation,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  localisation.code_bar,
                                  style: defaultTextStyle(
                                      fontSize: 12, color: GRAY),
                                ),
                                Text(
                                  "${localisation.biens.length + localisation.nonEtiqu.length} ARTICLES",
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
                      context.read<SynchronizationBloc>().add(
                          SynchronizationDefaultLocalite(loc: localisation));
                      Navigator.of(context).push(
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
          )),
    );
  }
}
// ignore_for_file: prefer_const_constructors

