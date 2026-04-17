import 'dart:io';

import 'package:robokassa_dart/robokassa_dart.dart';

Future<void> main() async {
  final robokassa = Robokassa(
    RobokassaConfig(
      login: Platform.environment['ROBOKASSA_LOGIN'] ?? '',
      password1: Platform.environment['ROBOKASSA_PASSWORD1'] ?? '',
      password2: Platform.environment['ROBOKASSA_PASSWORD2'] ?? '',
    ),
  );

  final methods = await robokassa.webService.getPaymentMethods(language: 'ru');
  stdout.writeln(methods);
}
