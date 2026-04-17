import 'dart:convert';
import 'dart:io';

import 'package:robokassa_dart/robokassa_dart.dart';

Future<void> main() async {
  final login = Platform.environment['ROBOKASSA_LOGIN'] ?? '';
  final robokassa = Robokassa(
    RobokassaConfig(
      login: login,
      password1: Platform.environment['ROBOKASSA_PASSWORD1'] ?? '',
      password2: Platform.environment['ROBOKASSA_PASSWORD2'] ?? '',
    ),
  );

  final status = await robokassa.receipt.getCheckStatus(
    CheckStatusRequest(merchantId: login, id: '1337'),
  );
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(status));
}
