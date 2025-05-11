import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<void> requestAll() async {
    // Request Storage and Install Unknown Apps permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.requestInstallPackages, // Only required for Android
    ].request();

    // Check if any permission was denied
    if (statuses.values.any((status) => status.isDenied)) {
      print("Some permissions are denied.");
    }

    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      print(
          "Some permissions are permanently denied. Open app settings to enable them.");
      await openAppSettings();
    }
  }
}
