import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/operations.dart';

class DetailLocalitePage extends StatelessWidget {
  final Localisation localisation;

  DetailLocalitePage({required this.localisation});
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
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: YELLOW,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Text(localisation.designation,
                                  style: defaultTextStyle(
                                      color: Colors.white, fontSize: 18)),
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
                              "${localisation.biens.length} Articles",
                              style: defaultTextStyle(color: GRAY),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nouveau article",
                        style: defaultTextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            "+ SN",
                            style: defaultTextStyle(color: GRAY),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Scanner un article",
                                    style:
                                        defaultTextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            )),
                      )
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
                            onChanged: (value) {
                              context.read<SynchronizationBloc>().add(
                                  SynchronizationRequestSearch(keyword: value));
                            },
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
                                  context.read<SynchronizationBloc>().add(
                                      SynchronizationRequestSearch(
                                          keyword: ""));
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
                    height: MediaQuery.of(context).size.width * 1,
                    child: ListView.builder(
                        itemCount: state.localites.length,
                        itemBuilder: (context, index) {
                          if (index != state.localites.length - 1) {
                            return LocaliteWidget(
                              localisation: state.localites[index],
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: LocaliteWidget(
                                localisation: state.localites[index],
                              ),
                            );
                          }
                        })),
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
