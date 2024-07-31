import 'package:flutter/material.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/main.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChoixStructurePage(
                              ),
                          settings: RouteSettings()),
                      (route) => false);
                },
                child: Text(
                  "Réessayer",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        )),
      ),
    );
  }
}
