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

  try {
    final url = await robokassa.payment.sendJwt(
      JwtPaymentRequest(
        invId: 133765623,
        outSum: 10,
        description: 'Оплата тестового заказа',
        merchantComments: 'Без комментариев',
        invoiceType: InvoiceType.reusable,
        invoiceItems: const [
          InvoiceItem(
            name: 'Тестовый товар 1',
            quantity: 1,
            cost: 10,
            tax: 'vat0',
            paymentMethod: 'full_payment',
            paymentObject: 'commodity',
          ),
        ],
        userFields: const {'shp_info': 'test', 'shp_user': 'admin'},
        successUrl: const UrlData(url: 'https://example.com/success'),
        failUrl: const UrlData(url: 'https://example.com/fail', method: 'POST'),
      ),
    );
    stdout.writeln('Ссылка на оплату (JWT): $url');
  } on RobokassaException catch (e) {
    stderr.writeln('Ошибка: ${e.message}');
  }
}
