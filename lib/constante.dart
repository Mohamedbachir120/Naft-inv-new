import 'dart:ui';

import 'package:barcode_scan2/model/android_options.dart';
import 'package:barcode_scan2/model/scan_options.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:naftinv/all_non_etique.dart';
import 'package:naftinv/all_objects.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/settings_bloc/bloc/settings_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/data/Bien_materiel.dart';
import 'package:naftinv/data/Localisation.dart';
import 'package:naftinv/detailBien.dart';
import 'package:naftinv/detailLocalite.dart';
import 'package:naftinv/localites.dart';
import 'package:naftinv/operations.dart';
import 'package:naftinv/profilPage.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
Widget CustomBottomBarWidget(BuildContext context1, int index) {
  var iconWidth = MediaQuery.of(context1).size.width * 0.05;
  var fontWidth = MediaQuery.of(context1).size.width * 0.032;

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
              MaterialPageRoute(builder: (context1) => BiensPage()),
            );
            break;
          case 3:
            Navigator.push(
              context1,
              MaterialPageRoute(builder: (context1) => SNsPage()),
            );
            break;
          case 4:
            Navigator.push(context1,
                MaterialPageRoute(builder: (context1) => ProfilPage()));
            break;
        }
      },
      items: [
        /// Home
        SalomonBottomBarItem(
          icon: Icon(
            Icons.home_outlined,
            size: iconWidth,
          ),
          title: Text(
            "Accueil",
            style: defaultTextStyle(color: YELLOW, fontSize: fontWidth),
          ),
          selectedColor: YELLOW,
        ),

        /// Search
        SalomonBottomBarItem(
          icon: Icon(
            Icons.home_max_outlined,
            size: iconWidth,
          ),
          title: Text(
            "Localite",
            style: defaultTextStyle(color: YELLOW, fontSize: fontWidth),
          ),
          selectedColor: YELLOW,
        ),

        /// Profile
        SalomonBottomBarItem(
          icon: Icon(
            Icons.inventory_2_outlined,
            size: iconWidth,
          ),
          title: Text(
            "Biens",
            style: defaultTextStyle(color: YELLOW, fontSize: fontWidth),
          ),
          selectedColor: YELLOW,
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.inventory_2, size: iconWidth),
          title: Text(
            "SN",
            style: defaultTextStyle(color: YELLOW, fontSize: fontWidth),
          ),
          selectedColor: YELLOW,
        ),
        SalomonBottomBarItem(
          icon: Icon(
            Icons.person_2_outlined,
            size: iconWidth,
          ),
          title: Text(
            "Profile",
            style: defaultTextStyle(color: YELLOW, fontSize: fontWidth),
          ),
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

final localisationRegex = RegExp(r'^([A-Z]|[0-9]){4}L([A-Z]|[0-9]){6,8}$');
final localisation2Regex = RegExp(r'^K[0-9]{4}L[0-9]{5}$');
final BienMaterielRegex = RegExp(r'^[A-Z]([0-9]|[A-Z]){7,15}$');

String get_etat(int mode) {
  switch (mode) {
    case 1:
      return "Bon";
    case 2:
      return "Hors service";
    case 3:
      return "A réformer";
  }
  return "";
}

String formatDate(int a) {
  if (a >= 10)
    return "$a";
  else
    return "0$a";
}

Future<void> scanBarcodeNormal(BuildContext context,
    {int operation = 1}) async {
  String barcodeScanRes = "";
  List<Localisation> localisations = context
      .read<SynchronizationBloc>()
      .synchronizationRepository
      .localisations;
  Localisation? lastLoc = context
      .read<SynchronizationBloc>()
      .synchronizationRepository
      .defaultLocalisation;
  try {
    if (context.read<SettingsBloc>().settingsrepository.lecteur == 0) {
      final result = await BarcodeScanner.scan(
        options: ScanOptions(
          autoEnableFlash:
              context.read<SettingsBloc>().settingsrepository.flash,
          android: AndroidOptions(
            aspectTolerance: 0.00,
            useAutoFocus: true,
          ),
        ),
      );
      barcodeScanRes = result.rawContent;
    } else {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    }
  } on PlatformException {
    barcodeScanRes = 'Failed to get platform version.';
  }

  if (operation == 1 &&
      (localisation2Regex.hasMatch(barcodeScanRes) ||
          localisationRegex.hasMatch(barcodeScanRes))) {
    try {
      Localisation newLoc =
          localisations.firstWhere((e) => e.code_bar == barcodeScanRes);
      context
          .read<SynchronizationBloc>()
          .add(SynchronizationDefaultLocalite(loc: newLoc));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailLocalitePage(localisation: newLoc)));
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Aucune localité n'a été trouvée avec ce code !",
        ),
      );
    }
  } else if (BienMaterielRegex.hasMatch(barcodeScanRes) && operation == 2) {
    if (lastLoc != null) {
      Bien_materiel newBien = Bien_materiel(
          barcodeScanRes,
          context.read<SettingsBloc>().settingsrepository.modeScan,
          DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
          lastLoc.code_bar ?? "",
          1,
          lastLoc.cop_id ?? "",
          context
                  .read<AuthenticationBloc>()
                  .authenticationRepository
                  .user
                  ?.matricule ??
              "",
          context
              .read<AuthenticationBloc>()
              .authenticationRepository
              .user
              ?.INV_ID);
      var exist = await newBien.local_check();

      if (exist == false) {
        context
            .read<SynchronizationBloc>()
            .add(SynchronizationAddBien(bien: newBien));
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: 'Ajouté avec succès !',
          ),
        );
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'Bien existe déjà !',
          ),
        );
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailLocalitePage(localisation: lastLoc)));
    } else {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Aucune localité selectioné !',
        ),
      );
    }
  } else {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.error(
        message: 'Code bar incorrect !',
      ),
    );
  }
}

Future<void> poursuivre_operation(BuildContext context) async {
  List<Bien_materiel> biens = await Bien_materiel.history();

  if (biens.length >= 1) {
    Localisation localisation =
        await Localisation.get_localisation(biens.last.code_localisation);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBienPage(
          bien: biens.last,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.white, size: 25),
          Text(
            "Vous n'avez aucune opération précédente",
            style: TextStyle(fontSize: 17.0),
          ),
        ],
      ),
      backgroundColor: Colors.red,
    ));
    scanBarcodeNormal(context);
  }
}
