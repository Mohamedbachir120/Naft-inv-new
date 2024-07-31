import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:naftinv/all_non_etique.dart';
import 'package:naftinv/all_objects.dart';
import 'package:naftinv/localites.dart';
import 'package:naftinv/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

const MAINCOLOR = Color(0XFF171059);
const LIGHTGRAY = Color(0XFFF5F5F5);
const GRAY = Color(0XFFC5C5C7);
const YELLOW = Color(0XFFFDCA00);
const LIGHTYELLOW = Color(0X64FDCA00);
const purple = Color(0xff8645FF);
TextStyle defaultTextStyle(
    {Color color = MAINCOLOR,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500}) {
  return GoogleFonts.poppins(
      letterSpacing: 0.1,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight);
}

// ignore: constant_identifier_names
Widget CustomBottomBarWidget(BuildContext context1,int index) {
  return Container(
    margin: EdgeInsets.all(10),
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
        color: MAINCOLOR, borderRadius: BorderRadius.circular(50)),
    child: SalomonBottomBar(
      backgroundColor: Colors.transparent,
      unselectedItemColor: GRAY,
      currentIndex: index,
      onTap: (i) {
        switch (i) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context1,
              MaterialPageRoute(builder: (context1) => MyApp()),
              ModalRoute.withName('/'),
            );
            break;

          case 1:
            Navigator.push(
              context1,
              MaterialPageRoute(builder: (context1) => LocalitePage()),
            );
            break;
          case 2:
            Navigator.push(
              context1,
              MaterialPageRoute(builder: (context1) => All_objects()),
            );
            break;
        }
      },
      items: [
        /// Home
        SalomonBottomBarItem(
          icon: Icon(Icons.home_outlined),
          title: Text("Accueil"),
          selectedColor: YELLOW,
        ),

        /// Search
        SalomonBottomBarItem(
          icon: Icon(Icons.home_max_outlined),
          title: Text("Localite"),
          selectedColor: YELLOW,
        ),

        /// Profile
        SalomonBottomBarItem(
          icon: Icon(Icons.mail_outline),
          title: Text("Serveur"),
          selectedColor: YELLOW,
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.person_2_outlined),
          title: Text("Profile"),
          selectedColor: YELLOW,
        ),
      ],
    ),
  );
}

var activeStyleElevated = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)));

var unactiveStyleElevated = ElevatedButton.styleFrom(
  backgroundColor: MAINCOLOR,
  shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.white, width: 2),
      borderRadius: BorderRadius.circular(25)),
);
