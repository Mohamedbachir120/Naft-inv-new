import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/components/AvatarComponent.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/main.dart';

class SynchronisationpageErrors extends StatelessWidget {
  const SynchronisationpageErrors({super.key});

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
                        "Envoi des logs en cours",
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
                        "Envoi des logs avec success",
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
                        "Opération échouée",
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
                            "Porblème de synchronisations",
                            style: defaultTextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Problèmes de Synchronisation avec le Serveur",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            "Votre application a été conçue pour fonctionner efficacement, même sans connexion Internet, en enregistrant les fichiers de l'inventaire physique en local. Cependant, lorsque l'application détecte une connectivité au serveur, elle tente automatiquement de synchroniser ces fichiers pour assurer que toutes les données soient mises à jour et disponibles en ligne.",
                            style: TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            "Il peut arriver que des erreurs de synchronisation surviennent. Ces erreurs peuvent être dues à plusieurs raisons, notamment :",
                            style: TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          const BulletPoint(
                            text:
                                "Une connexion Internet instable ou absente : L'application ne peut pas se connecter au serveur.",
                          ),
                          const BulletPoint(
                            text:
                                "Problèmes de serveur : Le serveur peut être temporairement indisponible.",
                          ),
                          const BulletPoint(
                            text:
                                "Fichiers corrompus : Certains fichiers locaux peuvent être endommagés ou non conformes.",
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            "Que faire en cas de problème de synchronisation ?",
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          const BulletPoint(
                            text:
                                "Vérifiez votre connexion Internet : Assurez-vous que votre appareil est connecté à un réseau stable (Wi-Fi ou données mobiles).",
                          ),
                          const BulletPoint(
                            text:
                                "Essayez à nouveau plus tard : Si le problème persiste, il est possible que le serveur soit temporairement indisponible.",
                          ),
                          const BulletPoint(
                            text:
                                "Utilisez le bouton \"Envoyer les logs\" : En cas de problème récurrent, utilisez le bouton situé au bas de cette page.",
                          ),
                          const SizedBox(height: 16.0),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Ajouter ici la logique pour envoyer les logs
                                context
                                    .read<SynchronizationBloc>()
                                    .add(SynchronizationSendLog());
                              },
                              child: const Text(
                                "Envoyer les Logs",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "\u2022 ",
          style: TextStyle(fontSize: 14.0),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14.0),
          ),
        ),
      ],
    );
  }
}
