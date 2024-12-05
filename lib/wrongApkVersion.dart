import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/constante.dart';
import 'package:naftinv/main.dart';
import 'package:url_launcher/url_launcher.dart';

class WrongApkVersion extends StatelessWidget {
  const WrongApkVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/ApkOutdated.png"),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Version $CurrentVersion installée obsolète",
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
                onPressed: () async {
                  // Uri url = Uri.parse(context
                  //     .read<AuthenticationBloc>()
                  //     .authenticationRepository
                  //     .link);

                  // print(context
                  //     .read<AuthenticationBloc>()
                  //     .authenticationRepository
                  //     .link);
                  try {
                    Uri url = Uri.parse(context
                        .read<AuthenticationBloc>()
                        .authenticationRepository
                        .link);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode
                              .externalApplication); // Opens in a browser
                    } else {
                      print('Could not launch $url');
                    }

                    print("Parsed URL: $url");
                  } catch (e) {
                    print("Error parsing URL: $e");
                  }
                },
                child: const Text(
                  "Télécharger la nouvelle version",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        )),
      ),
    );
  }
}
