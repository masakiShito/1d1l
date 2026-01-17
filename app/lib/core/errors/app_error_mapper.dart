import 'dart:io';

import 'app_error.dart';

class AppErrorMapper {
  const AppErrorMapper();

  AppError map(Object error, StackTrace stackTrace) {
    if (error is AppError) {
      return error;
    }
    if (error is SocketException) {
      return AppError(
        type: AppErrorType.network,
        userMessage: '通信に失敗しました。電波状況をご確認ください。',
        debugMessage: 'SocketException: ${error.message}',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (error is HttpException) {
      return AppError(
        type: AppErrorType.server,
        userMessage: 'サーバーで問題が発生しました。しばらくしてからお試しください。',
        debugMessage: 'HttpException: ${error.message}',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (error is FormatException) {
      return AppError(
        type: AppErrorType.unexpected,
        userMessage: 'データの読み込みに失敗しました。',
        debugMessage: 'FormatException: ${error.message}',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    return AppError(
      type: AppErrorType.unexpected,
      userMessage: '予期しないエラーが発生しました。時間を置いて再度お試しください。',
      debugMessage: error.toString(),
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
