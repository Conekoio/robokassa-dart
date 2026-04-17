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

  final response = await robokassa.receipt.sendSecondCheck(
    SecondCheckRequest(
      merchantId: login,
      id: '100',
      originId: '162103662',
      operation: 'sell',
      sno: 'osn',
      url: 'https://www.robokassa.ru/',
      total: 1,
      items: const [
        FiscalItem(
          name: 'Тестовый товар',
          quantity: 1,
          sum: 1,
          tax: 'none',
          paymentMethod: 'full_payment',
          paymentObject: 'payment',
        ),
      ],
      client: const FiscalClient(email: 'test@test.ru'),
      payments: const [FiscalPayment(type: 2, sum: 1)],
      vats: const [FiscalVat(type: 'none', sum: 0)],
    ),
  );
  stdout.writeln(response);
}
