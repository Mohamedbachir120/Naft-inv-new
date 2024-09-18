import 'package:flutter/material.dart';
import 'package:naftinv/constante.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

class PermissionNotGranted extends StatefulWidget {
  const PermissionNotGranted({super.key});

  @override
  State<PermissionNotGranted> createState() => _PermissionNotGrantedState();
}

class _PermissionNotGrantedState extends State<PermissionNotGranted> {
  Future<bool?> askPermission() async {
    PermissionStatus status = await Permission.phone.status;

    if (status.isDenied == true) {
      openAppSettings();
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => ChoixStructurePage(),
              settings: const RouteSettings()),
          (route) => false);
      return true;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/permission.jpg"),
              Container(
                margin: const EdgeInsets.all(10),
                child: const Card(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "L'application ne peut pas accèder à votre code IMEI veuillez cliquer sur autoriser afin d'utiliser l'application",
                      style: TextStyle(color: MAINCOLOR, fontSize: 15),
                    ),
                  ),
                ),
              ),
              TextButton(
                  style: TextButton.styleFrom(
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.8, 50),
                    backgroundColor: MAINCOLOR,
                  ),
                  onPressed: () async {
                    askPermission();
                  },
                  child: const Text(
                    "Autoriser",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
