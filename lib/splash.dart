import 'dart:async';
import 'package:flutter/material.dart';
import 'package:naftinv/operations.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashPage());
  }

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    // Navigate to the next screen after a delay
    Timer(const Duration(seconds: 1), () {
      // Navigate to your main content screen

      // Navigator.push(context,
      //     MaterialPageRoute(builder: (BuildContext context) {
      //   return const MyApp();
      // }));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset(
            "assets/logo.png",
            height: 100,
          ),
        ),
      ),
    );
  }
}
