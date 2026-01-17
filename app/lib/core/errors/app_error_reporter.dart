import 'app_error.dart';

class AppErrorReporter {
  const AppErrorReporter();

  void report(AppError error) {
    final details = <String>[
      'type=${error.type.name}',
      if (error.debugMessage != null) 'debug=${error.debugMessage}',
      if (error.cause != null) 'cause=${error.cause}',
    ].join(' | ');
    // ignore: avoid_print
    print('AppError: $details');
    if (error.stackTrace != null) {
      // ignore: avoid_print
      print(error.stackTrace);
    }
  }
}
