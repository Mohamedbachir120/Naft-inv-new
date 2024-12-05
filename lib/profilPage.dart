import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/components/AvatarComponent.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/main.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Set to transparent for a fullscreen effect
      statusBarIconBrightness:
          Brightness.dark, // Set to Brightness.dark for light icons
      statusBarBrightness:
          Brightness.dark, // Set to Brightness.dark for light icons on iOS
    ));
    return Scaffold(
      body: BlocListener<SynchronizationBloc, SynchronizationState>(
        listener: (context, state) {
          if (state is SynchronizationInitial) {
            print("###  ${state.status}");
            switch (state.status) {
              case SynchronizationStatus.loading:
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.sync, color: Colors.black87, size: 25),
                      Text(
                        "Synchronisation en cours",
                        style: defaultTextStyle(
                            fontSize: 17.0, color: Colors.black87),
                      ),
                    ],
                  ),
                  backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                ));
                break;
              case SynchronizationStatus.synchronized:
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 25),
                      Text(
                        "Synchronisation success",
                        style: defaultTextStyle(
                            fontSize: 17.0, color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ));
                break;
              case SynchronizationStatus.failed:
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.clear, color: Colors.white, size: 25),
                      Text(
                        "Synchronisation failed",
                        style: defaultTextStyle(
                            fontSize: 17.0, color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                ));
                break;
              default:
            }
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width * 0.05,
                          MediaQuery.of(context).size.width * 0.09,
                          MediaQuery.of(context).size.width * 0.05,
                          0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: MAINCOLOR,
                              )),
                          const Spacer(
                            flex: 2,
                          ),
                          Text(
                            "User profile",
                            style: defaultTextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                    Container(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.6,
                        child: Stack(
                          children: [
                            Positioned(
                              // top: MediaQuery.of(context).size.width * 0.13,
                              child: CustomPaint(
                                size: Size(MediaQuery.of(context).size.width,
                                    MediaQuery.of(context).size.width * 0.6),
                                painter: RhombicPainter(),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${state.user?.nom}",
                                              style: defaultTextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      BlocBuilder<SynchronizationBloc,
                                          SynchronizationState>(
                                        builder: (context, state) {
                                          if (state is SynchronizationInitial) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.inventory,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    "   ${context.read<SynchronizationBloc>().synchronizationRepository.localisations.expand((loc) => loc.biens).toList().length + context.read<SynchronizationBloc>().synchronizationRepository.localisations.expand((loc) => loc.nonEtiqu).toList().length}   Articles scanés",
                                                    style: defaultTextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            );
                                          } else {
                                            return const SizedBox();
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                right: MediaQuery.of(context).size.width * 0.4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Avatarcomponent(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.65,
                                      backgroundColor: YELLOW,
                                      color: Colors.white,
                                      text: state.user?.nom[0] ?? "U"),
                                ))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InfoWidget(
                      title: 'Nom Complet:',
                      value: state.user?.nom ?? "",
                    ),
                    InfoWidget(
                      title: 'Matricule:',
                      value: state.user?.matricule ?? "",
                    ),
                    InfoWidget(
                      title: 'Centre:',
                      value: state.user?.COP_ID ?? "",
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.012,
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: InkWell(
                        onTap: () {
                          context
                              .read<AuthenticationBloc>()
                              .add(AuthenticationSignOut());
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          decoration: BoxDecoration(
                              border: Border.all(color: GRAY),
                              borderRadius: BorderRadius.circular(13)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.logout_outlined,
                                  color: MAINCOLOR,
                                ),
                                Text(
                                  "Déconnexion",
                                  style: defaultTextStyle(),
                                )
                              ]),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.012,
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: InkWell(
                        onTap: () {
                          context
                              .read<SynchronizationBloc>()
                              .add(SynchronizationStart());
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          decoration: BoxDecoration(
                              border: Border.all(color: GRAY),
                              borderRadius: BorderRadius.circular(13)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.sync,
                                  color: Color(0xff04AA6D),
                                ),
                                Text(
                                  "Synchroniser",
                                  style: defaultTextStyle(
                                      color: const Color(0xff04AA6D)),
                                )
                              ]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copyright, color: GRAY),
                          Text(
                            "DCSI 2024 All rights reserved",
                            style: defaultTextStyle(color: GRAY),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Version $CurrentVersion",
                            style: defaultTextStyle(color: MAINCOLOR),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const LoadingProfileWidget();
            }
          },
        ),
      ),
    );
  }
}

class LoadingProfileWidget extends StatelessWidget {
  const LoadingProfileWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.05,
                MediaQuery.of(context).size.width * 0.05,
                MediaQuery.of(context).size.width * 0.05,
                0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: MAINCOLOR,
                    )),
                const Spacer(
                  flex: 2,
                ),
                Text(
                  "User profile",
                  style: defaultTextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
          Container(
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.6,
              child: Stack(
                children: [
                  Positioned(
                    // top: MediaQuery.of(context).size.width * 0.13,
                    child: CustomPaint(
                      size: Size(MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.width * 0.6),
                      painter: RhombicPainter(),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.6,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.width * 0.35),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "XXXX",
                                    style: defaultTextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.inventory,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "   XXX Articles scanés",
                                    style:
                                        defaultTextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      right: MediaQuery.of(context).size.width * 0.4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Avatarcomponent(
                            height: MediaQuery.of(context).size.width * 0.65,
                            backgroundColor: YELLOW,
                            color: Colors.white,
                            text: "U"),
                      ))
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const InfoWidget(
            title: 'Nom Complet:',
            value: "",
          ),
          const InfoWidget(
            title: 'Matricule:',
            value: "",
          ),
          const InfoWidget(
            title: 'Centre:',
            value: "",
          ),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.012,
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: InkWell(
              onTap: () {
                context.read<AuthenticationBloc>().add(AuthenticationSignOut());
              },
              child: Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                    border: Border.all(color: GRAY),
                    borderRadius: BorderRadius.circular(13)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Icon(
                    Icons.logout_outlined,
                    color: MAINCOLOR,
                  ),
                  Text(
                    "Déconnexion",
                    style: defaultTextStyle(),
                  )
                ]),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.012,
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: InkWell(
              onTap: () {},
              child: Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                    border: Border.all(color: GRAY),
                    borderRadius: BorderRadius.circular(13)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Icon(
                    Icons.sync,
                    color: Color(0xff04AA6D),
                  ),
                  Text(
                    "Synchroniser",
                    style: defaultTextStyle(color: const Color(0xff04AA6D)),
                  )
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key, required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.012,
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            decoration: BoxDecoration(
                border: Border.all(color: GRAY),
                borderRadius: BorderRadius.circular(13)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: defaultTextStyle(color: GRAY),
                  ),
                  Text(
                    value,
                    style: defaultTextStyle(),
                  )
                ]),
          )
        ],
      ),
    );
  }
}

class RhombicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = MAINCOLOR
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Starting from the top center of the canvas
    path.moveTo(0, size.height);

    // Draw line to the right middle
    path.lineTo(size.width, size.height - 20);

    // Draw line to the bottom center
    path.lineTo(size.width, size.height - 170);

    // // Draw line to the left middle
    path.lineTo(0, size.height - 150);

    // Close the path to form the rhombus
    path.close();

    // Draw the rhombus on the canvas
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
