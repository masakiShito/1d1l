enum AppErrorType {
  validation,
  network,
  auth,
  notFound,
  conflict,
  server,
  unexpected,
}

class AppError {
  const AppError({
    required this.type,
    required this.userMessage,
    this.debugMessage,
    this.cause,
    this.stackTrace,
  });

  final AppErrorType type;
  final String userMessage;
  final String? debugMessage;
  final Object? cause;
  final StackTrace? stackTrace;
}
