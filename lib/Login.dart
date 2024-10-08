import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naftinv/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/constante.dart';


class LoginPage extends StatelessWidget {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        decoration: const BoxDecoration(color: LIGHTGRAY),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.65,
                decoration: const BoxDecoration(
                    color: MAINCOLOR,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        30,
                        0,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // ignore: deprecated_member_use
                          IconButton(
                            onPressed: () {
                              // Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: YELLOW,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      height: MediaQuery.of(context).size.width * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage(
                                "assets/Logo_NAFTAL.png",
                              ))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        "Commencez l'inventaire",
                        style: defaultTextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: MediaQuery.of(context).size.width * 0.1,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.035),
                            child: Text(
                              "Se connecter",
                              style: defaultTextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 24),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextFormField(
                              controller: emailController,
                              decoration:
                                  defaultInputDecoration(title: "Matricule"),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.remove_red_eye,
                                    color: MAINCOLOR,
                                  ),
                                ),
                                labelText: "Mot de passe",
                                fillColor: Colors.white,
                                labelStyle: const TextStyle(color: GRAY),

                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: GRAY),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: GRAY),
                                ),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: GRAY),
                                ),
                                //fillColor: Colors.green
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Problème de connexion ?",
                                style: defaultTextStyle(
                                  color: MAINCOLOR,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: MAINCOLOR,
                                textStyle: const TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                context.read<AuthenticationBloc>().add(
                                    SubmitAuthentication(
                                        matricule: emailController.text,
                                        password: passwordController.text));

                                context
                                    .read<SynchronizationBloc>()
                                    .add(SynchronizationRefresh());
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: <Widget>[
                                    Text(
                                      'Connexion',
                                      style: defaultTextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous n'avez pas un compte?",
                          style: defaultTextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "S'INSCRIRE",
                              style:
                                  defaultTextStyle(fontWeight: FontWeight.w700),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}

InputDecoration defaultInputDecoration({required String title}) {
  return InputDecoration(
    labelText: title,
    hintText: title,
    labelStyle: defaultTextStyle(),

    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: GRAY),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: GRAY),
    ),
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: GRAY),
    ),
    fillColor: Colors.white,

    //fillColor: Colors.green
  );
}

InputDecoration snInputDecoration({required String title}) {
  return InputDecoration(
    labelText: title,

    hintText: title,
    labelStyle: defaultTextStyle(color: MAINCOLOR),
    hintStyle: defaultTextStyle(color: MAINCOLOR),
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    border: InputBorder.none,
    fillColor: Colors.white,

    //fillColor: Colors.green
  );
}
