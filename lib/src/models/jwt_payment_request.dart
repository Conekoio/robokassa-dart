import 'package:robokassa_dart/src/exceptions.dart';

import 'invoice_item.dart';
import 'url_data.dart';

enum InvoiceType {
  oneTime('OneTime'),
  reusable('Reusable');

  final String value;

  const InvoiceType(this.value);
}

class JwtPaymentRequest {
  final int invId;
  final num outSum;
  final String? description;
  final String? merchantComments;
  final InvoiceType invoiceType;
  final String culture;
  final List<InvoiceItem> invoiceItems;
  final Map<String, String> userFields;
  final UrlData? successUrl;
  final UrlData? failUrl;

  const JwtPaymentRequest({
    required this.invId,
    required this.outSum,
    this.description,
    this.merchantComments,
    this.invoiceType = InvoiceType.oneTime,
    this.culture = 'ru',
    this.invoiceItems = const [],
    this.userFields = const {},
    this.successUrl,
    this.failUrl,
  });

  Map<String, Object?> toJson(String merchantLogin) {
    if (outSum <= 0) {
      throw const RobokassaException('OutSum must be greater than zero');
    }
    return {
      'MerchantLogin': merchantLogin,
      'InvoiceType': invoiceType.value,
      'Culture': culture,
      'InvId': invId,
      'OutSum': outSum is int ? (outSum as int).toDouble() : outSum,
      if (description != null) 'Description': description,
      if (merchantComments != null) 'MerchantComments': merchantComments,
      if (invoiceItems.isNotEmpty) 'InvoiceItems': invoiceItems.map((e) => e.toJson()).toList(),
      if (userFields.isNotEmpty) 'UserFields': userFields,
      if (successUrl != null) 'SuccessUrl2Data': successUrl!.toJson(),
      if (failUrl != null) 'FailUrl2Data': failUrl!.toJson(),
    };
  }
}
