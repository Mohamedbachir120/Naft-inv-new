import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/operations.dart';

class LocalitePage extends StatelessWidget {
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
              final localites = state.localites
                  .where((e) =>
                      e.code_bar.contains(state.keyword) ||
                      e.designation.contains(state.keyword))
                  .toList();
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
                              flex: 2,
                              child: Text("LOCALITÉS",
                                  style: defaultTextStyle(
                                      color: Colors.white, fontSize: 18)),
                            ),
                            Flexible(flex: 1, child: SizedBox())
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    context.read<SynchronizationBloc>().add(
                                        SynchronizationRequestFilter(
                                            filter: "ASC"));
                                  },
                                  style: state.filter == "ASC"
                                      ? activeStyleElevated
                                      : unactiveStyleElevated,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_up,
                                        color: state.filter == "ASC"
                                            ? purple
                                            : Colors.white,
                                        size: 24,
                                      ),
                                      Text(
                                        "ASC",
                                        style: defaultTextStyle(
                                            fontSize: 12,
                                            color: state.filter == "ASC"
                                                ? purple
                                                : Colors.white,
                                            fontWeight: FontWeight.w700),
                                      )
                                    ],
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    context.read<SynchronizationBloc>().add(
                                        SynchronizationRequestFilter(
                                            filter: "DESC"));
                                  },
                                  style: state.filter == "DESC"
                                      ? activeStyleElevated
                                      : unactiveStyleElevated,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: state.filter == "DESC"
                                            ? purple
                                            : Colors.white,
                                        size: 24,
                                      ),
                                      Text(
                                        "DESC",
                                        style: defaultTextStyle(
                                            fontSize: 12,
                                            color: state.filter == "DESC"
                                                ? purple
                                                : Colors.white,
                                            fontWeight: FontWeight.w700),
                                      )
                                    ],
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    context.read<SynchronizationBloc>().add(
                                        SynchronizationRequestFilter(
                                            filter: ""));
                                  },
                                  style: unactiveStyleElevated,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.remove_circle,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      Text(
                                        " DEL",
                                        style: defaultTextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      )
                                    ],
                                  )),
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
                        "Recherche",
                        style: defaultTextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      TextButton(
                          onPressed: () {
                            scanBarcodeNormal(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: purple,
                              ),
                              Text(
                                "  Scanner",
                                style: defaultTextStyle(
                                    color: purple, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
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
                            child: Icon(Icons.search),
                          )),
                      Flexible(
                          flex: 5,
                          child: TextFormField(
                            initialValue: state.keyword,
                            onChanged: (value) {
                              context.read<SynchronizationBloc>().add(
                                  SynchronizationRequestSearch(keyword: value));
                            },
                            decoration: InputDecoration(
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
                                  Icons.clear,
                                  color: Colors.white,
                                )),
                          ))
                    ],
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 20),
                    itemCount: localites.length,
                    itemBuilder: (context, index) {
                      return LocaliteWidget(
                        localisation: localites[index],
                      );
                    }),
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
