import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:naftinv/main.dart';
import 'package:naftinv/repositories/authentication_repository.dart';
import 'package:sqflite/sqflite.dart';

// Define Cubit States
abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {
  final String message;
  ChangePasswordSuccess(this.message);
}

class ChangePasswordFailure extends ChangePasswordState {
  final String error;
  ChangePasswordFailure(this.error);
}

// Cubit Class
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final Dio dio = Dio();
  final AuthenticationRepository authenticationRepository;
  ChangePasswordCubit(this.authenticationRepository)
      : super(ChangePasswordInitial());

  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(ChangePasswordLoading());

    try {
      var headers = {
        "Authorization":
            "Bearer ${await authenticationRepository.user?.getToken()}"
      };
      var data = FormData.fromMap({
        "password": newPassword,
        "oldpassword": oldPassword,
      });
      var response = await dio.request(
        '${LARAVEL_ADDRESS}api/update_password',
        options: Options(
          method: "POST",
          headers: headers,
        ),
        data: data,
      );

      emit(ChangePasswordSuccess("Password changed successfully!"));
    } catch (e) {
      // Check for token expiration error (e.g., statusCode 401)
      // Token expired, call refreshToken and retry

      await refreshToken();

      // Retry the password update after refreshing the token
      try {
        dio.options.headers["Authorization"] =
            'Bearer ${await authenticationRepository.user?.getToken()}';
        var response = await dio.post(
          '${LARAVEL_ADDRESS}api/update_password',
          data: FormData.fromMap({
            "oldpassword": oldPassword,
            "password": newPassword,
          }),
        );

        emit(ChangePasswordSuccess(
            "Password changed successfully after token refresh!"));
      } catch (e) {
        emit(ChangePasswordFailure(
            "Failed after token refresh: ${e.toString()}"));
      }
    }
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
    } catch (e) {}
  }
}
