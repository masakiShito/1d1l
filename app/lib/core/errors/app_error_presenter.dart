import 'app_error.dart';

class AppErrorPresenter {
  const AppErrorPresenter();

  String messageFor(AppError error) {
    return error.userMessage;
  }
}
