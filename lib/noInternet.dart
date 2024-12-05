import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/main.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/noInternet.png"),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Impossible d'établir la connexion",
                style: TextStyle(
                    color: MAINCOLOR,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
            ),
            TextButton(
                style: TextButton.styleFrom(
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.8, 50),
                    backgroundColor: MAINCOLOR),
                onPressed: () {
                  context
                      .read<AuthenticationBloc>()
                      .add(AuthenticationRefresh());
                },
                child: const Text(
                  "Réessayer",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        )),
      ),
    );
  }
}
