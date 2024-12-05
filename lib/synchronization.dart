import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:naftinv/Login.dart';
import 'package:naftinv/blocs/synchronization_bloc/bloc/synchronization_bloc.dart';
import 'package:naftinv/repositories/authentication_repository.dart';
import 'package:naftinv/repositories/synchronization_repository.dart';

class SynchronizationPage extends StatelessWidget {
  const SynchronizationPage(
      {super.key, required this.authenticationRepository});
  final AuthenticationRepository authenticationRepository;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SynchronizationBloc(
          synchronizationRepository: SynchronizationRepository(
            db: authenticationRepository.db,
          ),
          authenticationRepository: authenticationRepository),
      child: SafeArea(
          child: Scaffold(
              body: BlocListener<SynchronizationBloc, SynchronizationState>(
        listener: (context, state) {
          if (state is SynchronizationInitial) {
            if (state.status == SynchronizationStatus.success) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return LoginPage();
              }));
            }
          }
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          child: Lottie.asset('assets/105673-sync-data.json',
              height: MediaQuery.of(context).size.height * 0.95),
        ),
      ))),
    );
  }
}
