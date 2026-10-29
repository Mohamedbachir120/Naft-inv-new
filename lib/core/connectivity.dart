import 'package:connectivity_plus/connectivity_plus.dart';

/// Returns true when the device has a mobile, wifi or ethernet connection.
///
/// connectivity_plus >= 6 returns a list of active connection types, so the
/// result must be checked with `contains`, not compared with `==`.
Future<bool> hasNetworkConnection() async {
  final List<ConnectivityResult> results =
      await Connectivity().checkConnectivity();
  return results.contains(ConnectivityResult.mobile) ||
      results.contains(ConnectivityResult.wifi) ||
      results.contains(ConnectivityResult.ethernet);
}
