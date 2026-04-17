import 'dart:convert';

import 'package:robokassa_dart/src/config.dart';
import 'package:robokassa_dart/src/exceptions.dart';
import 'package:robokassa_dart/src/http/robokassa_http_client.dart';
import 'package:robokassa_dart/src/models/invoice_information_filters.dart';
import 'package:robokassa_dart/src/signature/signature_service.dart';

class StatusService {
  final RobokassaHttpClient _http;
  final SignatureService _signer;
  final RobokassaConfig _config;

  const StatusService({
    required RobokassaHttpClient http,
    required SignatureService signer,
    required RobokassaConfig config,
  })  : _http = http,
        _signer = signer,
        _config = config;

  Future<Map<String, Object?>> getInvoiceInformationList(
    InvoiceInformationFilters filters,
  ) async {
    final payload = <String, Object?>{
      'MerchantLogin': _config.login,
      ...filters.toJson(),
    };

    final parts = _signer.encodeJwtParts(
      {'alg': 'MD5', 'typ': 'JWT'},
      payload,
    );
    final signature = _signer.jwtSignMd5(
      parts.dataToSign,
      _config.login,
      _config.activePassword1,
    );
    final jwt = '${parts.dataToSign}.$signature';

    final response = await _http.post(
      _config.endpoints.invoiceInformationUrl,
      body: jsonEncode(jwt),
      headers: const {'Content-Type': 'application/json'},
    );

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) return decoded;
      throw RobokassaException('Unexpected response format: ${response.body}');
    } on FormatException catch (e) {
      throw RobokassaException('Invalid JSON in response: ${response.body}', e);
    }
  }
}
