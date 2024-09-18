import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:naftinv/data/BienImmo.dart';
import 'package:naftinv/main.dart';
import 'package:naftinv/repositories/authentication_repository.dart';
import 'package:sqflite/sqflite.dart';

part 'bien_immo_state.dart';

class BienImmoCubit extends Cubit<BienImmoState> {
  final Dio dio = Dio();
  AuthenticationRepository authenticationRepository;
  BienImmoCubit({
    required this.authenticationRepository,
  }) : super(BienImmoInitial());

  Future<void> findBien(String codeBar) async {
    print("######## centre  ${authenticationRepository.user?.COP_ID}");
    emit(BienImmoLoading());
    try {
      dio.options.headers["Authorization"] =
          'Bearer ${await authenticationRepository.user?.getToken()}';
      final response = await dio.get(
        '${LARAVEL_ADDRESS}api/bien_details',
        queryParameters: {
          'code': authenticationRepository.deviceId,
          'code_bar': codeBar
        },
      );

      if (response.data != null) {
        print("########## ${response.data}");
        final bienImmo = BienImmo(
          AST_CB: response.data['detail']['AST_CB'],
          AST_LIB: response.data['detail']['AST_LIB'] ?? "",
          AST_MODELE: response.data['detail']['AST_MODELE'] ?? "",
          AST_SERIAL_NEMBER: response.data['detail']['AST_SERIAL_NEMBER'] ?? "",
          AST_MARQUE: response.data['detail']['AST_MARQUE'] ?? "",
          EMP_ID_AMU: response.data['detail']['EMP_ID_AMU'] ?? "",
          EMP_FULLNAME_AMU: response.data['detail']['EMP_FULLNAME_AMU'] ?? "",
          AST_TV_CODE: response.data['detail']['AST_TV_CODE'] ?? "",
          AST_TV_MATRICULE: response.data['detail']['AST_TV_MATRICULE'] ?? "",
        );
        emit(BienImmoLoaded(bienImmo));
      } else {
        emit(BienImmoNotFound());
      }
    } catch (e) {
      try {
        print("###### calling refresh token ");
        await refreshToken();
        dio.options.headers["Authorization"] =
            'Bearer ${await authenticationRepository.user?.getToken()}';
        final response = await dio.get(
          '${LARAVEL_ADDRESS}api/bien_details',
          queryParameters: {
            'code': authenticationRepository.deviceId,
            'code_bar': codeBar
          },
        );
        if (response.data != null) {
          print("########## ${response.data}");
          final bienImmo = BienImmo(
            AST_CB: response.data['detail']['AST_CB'],
            AST_LIB: response.data['detail']['AST_LIB'] ?? "",
            AST_MODELE: response.data['detail']['AST_MODELE'] ?? "",
            AST_SERIAL_NEMBER:
                response.data['detail']['AST_SERIAL_NEMBER'] ?? "",
            AST_MARQUE: response.data['detail']['AST_MARQUE'] ?? "",
            EMP_ID_AMU: response.data['detail']['EMP_ID_AMU'] ?? "",
            EMP_FULLNAME_AMU: response.data['detail']['EMP_FULLNAME_AMU'] ?? "",
            AST_TV_CODE: response.data['detail']['AST_TV_CODE'] ?? "",
            AST_TV_MATRICULE: response.data['detail']['AST_TV_MATRICULE'] ?? "",
          );
          emit(BienImmoLoaded(bienImmo));
        } else {
          emit(BienImmoNotFound());
        }
      } catch (e) {
        emit(BienImmoError(e.toString()));
      }
    }
  }

  void switchToView(BienImmo bienImmo) {
    emit(BienImmoLoaded(bienImmo));
  }

  void updateBien(BienImmo bienImmo, BienImmo updatedBien) async {
    final newBienImmo = bienImmo.copyWith(
        AST_CB: updatedBien.AST_CB,
        AST_LIB: updatedBien.AST_LIB,
        AST_MODELE: updatedBien.AST_MODELE,
        AST_SERIAL_NEMBER: updatedBien.AST_SERIAL_NEMBER,
        AST_MARQUE: updatedBien.AST_MARQUE,
        EMP_ID_AMU: updatedBien.EMP_ID_AMU,
        EMP_FULLNAME_AMU: updatedBien.EMP_FULLNAME_AMU,
        AST_TV_CODE: updatedBien.AST_TV_CODE,
        AST_TV_MATRICULE: updatedBien.AST_TV_MATRICULE);

    try {
      var responseUpdate = await dio.post(
          '${LARAVEL_ADDRESS}api/update_bien/${authenticationRepository.deviceId}',
          data: json.encode({
            "cop_id": authenticationRepository.user?.COP_ID,
            "code_bar": newBienImmo.AST_CB,
            'marque': newBienImmo.AST_MARQUE,
            'modele': newBienImmo.AST_MODELE,
            'fullname': newBienImmo.EMP_FULLNAME_AMU,
            'owner': newBienImmo.EMP_ID_AMU,
            'userId': authenticationRepository.user?.matricule,
            'lib': newBienImmo.AST_LIB,
            'serialNumber': newBienImmo.AST_SERIAL_NEMBER,
            'codeCar': newBienImmo.AST_TV_CODE,
            'matriculeCar': newBienImmo.AST_TV_MATRICULE
          }));
      emit(BienImmoUpdated(newBienImmo));

      print("###### success ${responseUpdate.data}");
    } catch (e) {
      await refreshToken();

      // Retry the original request after refreshing the token
      try {
        await dio.post(
            '${LARAVEL_ADDRESS}api/update_bien/${authenticationRepository.deviceId}',
            data: json.encode({
              "cop_id": authenticationRepository.user?.COP_ID,
              "code_bar": newBienImmo.AST_CB,
              'marque': newBienImmo.AST_MARQUE,
              'modele': newBienImmo.AST_MODELE,
              'fullname': newBienImmo.EMP_FULLNAME_AMU,
              'owner': newBienImmo.EMP_ID_AMU,
              'userId': authenticationRepository.user?.matricule,
              'lib': newBienImmo.AST_LIB,
              'serialNumber': newBienImmo.AST_SERIAL_NEMBER,
              'codeCar': newBienImmo.AST_TV_CODE,
              'matriculeCar': newBienImmo.AST_TV_MATRICULE
            }));
        emit(BienImmoUpdated(newBienImmo));
      } catch (e) {
        emit(BienImmoError(e.toString()));
      }
    }
  }

  void editBien(BienImmo bienImmo) {
    print("##### editing called ");
    emit(BienImmoEdit(bienImmo));
  }

  Future<void> refreshToken() async {
    try {
      var response = await dio.post('${LARAVEL_ADDRESS}api/auth/refresh_token',
          data: {
            "refresh_token": authenticationRepository.user?.refresh_token
          });

      // Update the token in your authentication repository after refreshing
      authenticationRepository.user?.token = response.data['access_token'];
      authenticationRepository.user?.refresh_token =
          response.data['refresh_token'];

      authenticationRepository.db.insert(
          'User', authenticationRepository.user!.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print("############# Token refreshed successfully.");
    } catch (e) {
      print("############### Error refreshing token: ${e.toString()}");
    }
  }
}
