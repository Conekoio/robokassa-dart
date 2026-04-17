import 'package:robokassa_dart/src/exceptions.dart';

import 'receipt.dart';

class CurlPaymentRequest {
  final num outSum;
  final int? invoiceId;
  final String description;
  final String culture;
  final String? email;
  final String? incCurrLabel;
  final Receipt? receipt;
  final Map<String, String> shpParams;

  const CurlPaymentRequest({
    required this.outSum,
    required this.description,
    this.invoiceId,
    this.culture = 'ru',
    this.email,
    this.incCurrLabel,
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
  }
}
