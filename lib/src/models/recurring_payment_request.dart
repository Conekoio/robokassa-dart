import 'package:robokassa_dart/src/exceptions.dart';

import 'receipt.dart';

class RecurringPaymentRequest {
  final int invoiceId;

  final int previousInvoiceId;

  final num outSum;
  final String description;
  final String culture;
  final String? email;
  final Receipt? receipt;
  final Map<String, String> shpParams;

  const RecurringPaymentRequest({
    required this.invoiceId,
    required this.previousInvoiceId,
    required this.outSum,
    required this.description,
    this.culture = 'ru',
    this.email,
    this.receipt,
    this.shpParams = const {},
  });

  void validate() {
    if (description.isEmpty) {
      throw const RobokassaException('Description is required');
    }
    if (outSum <= 0) {
      throw const RobokassaException('OutSum must be greater than zero');
    }
    if (invoiceId <= 0) {
      throw const RobokassaException('invoiceId must be a positive merchant-generated id');
    }
    if (previousInvoiceId <= 0) {
      throw const RobokassaException('previousInvoiceId must be positive');
    }
  }
}
