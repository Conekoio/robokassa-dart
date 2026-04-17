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

  final result = await robokassa.status.getInvoiceInformationList(
    InvoiceInformationFilters(
      currentPage: 1,
      pageSize: 10,
      invoiceStatuses: const [
        InvoiceStatus.paid,
        InvoiceStatus.expired,
        InvoiceStatus.notPaid,
      ],
      dateFrom: DateTime.utc(2023, 1, 1),
      dateTo: DateTime.utc(2025, 9, 5),
      invoiceTypes: const [
        InvoiceTypeFilter.oneTime,
        InvoiceTypeFilter.reusable,
      ],
      isAscending: true,
      paymentAliases: const ['BankCard'],
      sumFrom: 1,
      sumTo: 10000,
    ),
  );
  stdout.writeln(result);
}
