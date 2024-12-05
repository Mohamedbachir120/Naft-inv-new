import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LogFileHandler {
  late File logFile;

  /// Initialize the log file
  Future<void> initializeLogFile() async {
    final directory = await getExternalStorageDirectory();
    final logFilePath = '${directory!.path}/app_logs.txt';
    print("### $logFilePath");
    logFile = File(logFilePath);

    // Create the file if it doesn't exist
    if (!await logFile.exists()) {
        await logFile.create(recursive: true);
    }
  }

  /// Write a log entry in append mode
  Future<void> writeLog(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $message\n';

    try {
      await logFile.writeAsString(logEntry, mode: FileMode.append);
      print("### Log appended: $logEntry");
    } catch (e) {
      print("### Error appending log: $e");
    }
  }

  /// Read all logs (optional)
  Future<String> readLogs() async {
    try {
      return await logFile.readAsString();
    } catch (e) {
      print("Error reading log: $e");
      return '';
    }
  }
}
