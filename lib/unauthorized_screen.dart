import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naftinv/constante.dart';

class UnauthorizedScreen extends StatefulWidget {
  UnauthorizedScreen({Key? key, required this.code}) : super(key: key);
  late final String code;
  @override
  State<UnauthorizedScreen> createState() =>
      _UnauthorizedScreenState(code: code);
}

class _UnauthorizedScreenState extends State<UnauthorizedScreen> {
  _UnauthorizedScreenState({required this.code});
  late final String code;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/restricted.jpg"),
            Container(
              width: double.infinity,
              child: Center(
                  child: Text(
                code,
                style: TextStyle(color: MAINCOLOR, fontSize: 18),
              )),
            ),
            Container(
              child: TextButton.icon(
                  style: TextButton.styleFrom(backgroundColor: MAINCOLOR),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));

                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Text(
                                "le code a été copié",
                                textAlign: TextAlign.center,
                              ),
                            ));
                    Timer(Duration(milliseconds: 500),
                        () => Navigator.pop(context));
                  },
                  icon: Icon(
                    Icons.copy,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Copier",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Vous n'êtes pas autorisé à utiliser cette application veuillez communiquer le code ci-dessus avec votre ING",
                    style: TextStyle(color: MAINCOLOR, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
