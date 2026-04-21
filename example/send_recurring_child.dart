import 'dart:io';

import 'package:robokassa_dart/robokassa_dart.dart';

Future<void> main() async {
  final prev = int.tryParse(Platform.environment['ROBOKASSA_PREVIOUS_INVOICE_ID'] ?? '');
  if (prev == null || prev <= 0) {
    stderr.writeln('Задайте ROBOKASSA_PREVIOUS_INVOICE_ID (положительное число).');
    exitCode = 1;
    return;
  }

  final robokassa = Robokassa(
    RobokassaConfig(
      login: Platform.environment['ROBOKASSA_LOGIN'] ?? '',
      password1: Platform.environment['ROBOKASSA_PASSWORD1'] ?? '',
      password2: Platform.environment['ROBOKASSA_PASSWORD2'] ?? '',
    ),
  );

  final childInvoiceId = DateTime.now().millisecondsSinceEpoch % 2000000000 + 1;

  try {
    final result = await robokassa.payment.sendRecurringChild(
      RecurringPaymentRequest(
        invoiceId: childInvoiceId,
        previousInvoiceId: prev,
        outSum: 10,
        description: 'Повторное списание (пример SDK)',
      ),
    );
    stdout.writeln('Ответ: ${result.rawBody}');
    stdout.writeln('Операция создана: ${result.isOperationCreated}');
    if (result.invoiceIdFromResponse != null) {
      stdout.writeln('InvoiceId из OK+: ${result.invoiceIdFromResponse}');
    }
  } on RobokassaException catch (e) {
    stderr.writeln('Ошибка: ${e.message}');
  }
}
