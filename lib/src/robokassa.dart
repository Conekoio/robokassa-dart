import 'package:robokassa_dart/src/services/payment_service.dart';
import 'package:robokassa_dart/src/services/receipt_service.dart';
import 'package:robokassa_dart/src/services/status_service.dart';
import 'package:robokassa_dart/src/services/web_service.dart';
import 'package:robokassa_dart/src/signature/signature_service.dart';

import 'config.dart';
import 'http/robokassa_http_client.dart';

class Robokassa {
  final RobokassaConfig config;
  final RobokassaHttpClient httpClient;
  final SignatureService signatureService;

  late final PaymentService payment;
  late final ReceiptService receipt;
  late final WebService webService;
  late final StatusService status;

  Robokassa(
    this.config, {
    RobokassaHttpClient? httpClient,
    SignatureService? signatureService,
  })  : httpClient = httpClient ?? DioRobokassaHttpClient(),
        signatureService = signatureService ?? SignatureService(defaultAlgorithm: config.hashType) {
    config.validate();
    payment = PaymentService(
      http: this.httpClient,
      signer: this.signatureService,
      config: config,
    );
    receipt = ReceiptService(
      http: this.httpClient,
      signer: this.signatureService,
      config: config,
    );
    webService = WebService(
      http: this.httpClient,
      signer: this.signatureService,
      config: config,
    );
    status = StatusService(
      http: this.httpClient,
      signer: this.signatureService,
      config: config,
    );
  }
}
