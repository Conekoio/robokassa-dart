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
    final url = await robokassa.payment.sendCurl(
      const CurlPaymentRequest(
        outSum: 100.00,
        invoiceId: 123456,
        description: 'Оплата заказа #123456',
        receipt: Receipt(
          items: [
            ReceiptItem(
              name: 'Товар 1',
              quantity: 1,
              sum: 100.00,
              paymentMethod: 'full_payment',
              paymentObject: 'commodity',
              tax: 'none',
            ),
          ],
        ),
      ),
    );
    stdout.writeln('Ссылка на оплату: $url');
  } on RobokassaException catch (e) {
    stderr.writeln('Ошибка: ${e.message}');
  }
}
