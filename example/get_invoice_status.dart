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

  final result = await robokassa.webService.opState(123456);
  stdout.writeln(result);
}
