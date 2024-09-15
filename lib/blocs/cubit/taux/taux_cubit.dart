import 'package:bloc/bloc.dart';
import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:naftinv/data/User.dart';
import 'package:naftinv/main.dart';
import 'package:naftinv/repositories/authentication_repository.dart';

part 'taux_state.dart';

// Cubit to manage the API call and state
class TauxCubit extends Cubit<TauxState> {
  final Dio _dio = Dio();
  final AuthenticationRepository authenticationRepository;
  TauxCubit({required this.authenticationRepository})
      : super(TauxState(isLoading: true)) {
    _fetchTaux();
  }

  void _fetchTaux() async {
    try {
      User user = await User.auth();

      _dio.options.headers["Authorization"] = 'Bearer ' + await user.getToken();
      String imeiNo = await DeviceInformation.deviceIMEINumber;
      print(authenticationRepository.year);
      final response = await _dio.get(
          '${LARAVEL_ADDRESS}api/taux_progress?code=$imeiNo&cop=${user.COP_ID}&date=${authenticationRepository.year}1231');

      print(response.data);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final double? taux = data['taux'] as double?;
        if (taux != null) {
          emit(TauxState(taux: taux));
        } else {
          emit(TauxState(taux: 0, error: 'Key "taux" not found'));
        }
      } else {
        emit(TauxState(taux: 0, error: 'Failed to load data'));
      }
    } catch (e) {
      print(e.toString());
      emit(TauxState(taux: 0, error: 'Error: $e'));
    }
  }
}
