import 'package:logger/logger.dart';

class AppLogger {

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
    );
  }
  static final AppLogger _instance = AppLogger._internal();

  late final Logger _logger;

  static AppLogger get instance => _instance;

  void info(String message) {
    _logger.i(message);
  }

  void debug(String message) {
    _logger.d(message);
  }

  void warning(String message) {
    _logger.w(message);
  }

  void error(String message, [error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
