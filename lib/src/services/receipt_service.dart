import 'dart:convert';

import 'package:robokassa_dart/src/config.dart';
import 'package:robokassa_dart/src/exceptions.dart';
import 'package:robokassa_dart/src/http/robokassa_http_client.dart';
import 'package:robokassa_dart/src/models/check_status_request.dart';
import 'package:robokassa_dart/src/models/second_check_request.dart';
import 'package:robokassa_dart/src/signature/signature_service.dart';

class ReceiptService {
  final RobokassaHttpClient _http;
  final SignatureService _signer;
  final RobokassaConfig _config;

  const ReceiptService({
    required RobokassaHttpClient http,
    required SignatureService signer,
    required RobokassaConfig config,
  })  : _http = http,
        _signer = signer,
        _config = config;

  String buildSecondCheckBody(Map<String, Object?> payload) {
    final json = jsonEncode(payload);
    final base64Payload = _signer.base64UrlNoPadFromString(json);
    final signature = _signer.signFiscal(
      base64Payload,
      _config.activePassword1,
      _config.hashType,
    );
    return '$base64Payload.$signature';
  }

  Future<String> sendSecondCheck(SecondCheckRequest request) async {
    final body = buildSecondCheckBody(request.toJson());
    final response = await _http.post(
      _config.endpoints.secondCheckUrl,
      body: body,
      headers: const {'Content-Type': 'application/json'},
    );
    return response.body;
  }

  Future<Map<String, Object?>> getCheckStatus(CheckStatusRequest request) async {
    if (request.merchantId.isEmpty || request.id.isEmpty) {
      throw const RobokassaException(
        'merchantId and id are required for check status request',
      );
    }
    final body = buildSecondCheckBody(request.toJson());
    final response = await _http.post(
      _config.endpoints.checkStatusUrl,
      body: body,
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
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
