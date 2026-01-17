import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/errors/app_error.dart';
import 'package:app/core/errors/app_error_mapper.dart';

void main() {
  group('AppErrorMapper', () {
    test('maps SocketException to network error', () {
      final mapper = AppErrorMapper();

      final error = mapper.map(const SocketException('offline'), StackTrace.empty);

      expect(error.type, AppErrorType.network);
    });

    test('maps HttpException to server error', () {
      final mapper = AppErrorMapper();

      final error = mapper.map(const HttpException('server'), StackTrace.empty);

      expect(error.type, AppErrorType.server);
    });

    test('maps unknown error to unexpected', () {
      final mapper = AppErrorMapper();

      final error = mapper.map(Exception('boom'), StackTrace.empty);

      expect(error.type, AppErrorType.unexpected);
    });
  });
}
