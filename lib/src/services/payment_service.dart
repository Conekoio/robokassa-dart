import 'dart:convert';

import 'package:robokassa_dart/src/config.dart';
import 'package:robokassa_dart/src/exceptions.dart';
import 'package:robokassa_dart/src/http/robokassa_http_client.dart';
import 'package:robokassa_dart/src/models/curl_payment_request.dart';
import 'package:robokassa_dart/src/models/curl_payment_target.dart';
import 'package:robokassa_dart/src/models/jwt_payment_request.dart';
import 'package:robokassa_dart/src/models/recurring_payment_request.dart';
import 'package:robokassa_dart/src/models/recurring_payment_result.dart';
import 'package:robokassa_dart/src/signature/signature_service.dart';

class PaymentService {
  final RobokassaHttpClient _http;
  final SignatureService _signer;
  final RobokassaConfig _config;

  const PaymentService({
    required RobokassaHttpClient http,
    required SignatureService signer,
    required RobokassaConfig config,
  })  : _http = http,
        _signer = signer,
        _config = config;

  Future<String> sendJwt(JwtPaymentRequest request) async {
    final payload = request.toJson(_config.login);
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
      _config.endpoints.jwtApiUrl,
      body: jsonEncode(jwt),
      headers: const {'Content-Type': 'application/json'},
    );

    final data = _tryDecode(response.body);
    if (data is Map && data['url'] is String) {
      return data['url'] as String;
    }
    throw RobokassaException('JWT request failed: ${response.body}');
  }

  Future<String> sendCurl(CurlPaymentRequest request) async {
    request.validate();

    String? receiptEncodedOnce;
    String? receiptForRequest;
    if (request.receipt != null) {
      final json = jsonEncode(request.receipt!.toJson());
      receiptEncodedOnce = Uri.encodeQueryComponent(json);
      receiptForRequest = Uri.encodeQueryComponent(receiptEncodedOnce);
    }

    final shpEncoded = <String, String>{
      for (final e in request.shpParams.entries) e.key: Uri.encodeQueryComponent(e.value),
    };

    final signature = _signer.createPaymentSignature(
      login: _config.login,
      password1: _config.activePassword1,
      outSum: request.outSum.toString(),
      invoiceId: request.invoiceId?.toString() ?? '',
      receipt: receiptEncodedOnce,
      shpParams: request.shpParams,
      algorithm: _config.hashType,
    );

    final form = <String, String>{
      'MerchantLogin': _config.login,
      'OutSum': request.outSum.toString(),
      if (request.invoiceId != null) 'InvoiceID': request.invoiceId!.toString(),
      'Description': request.description,
      'Culture': request.culture,
      if (request.email != null) 'Email': request.email!,
      if (request.incCurrLabel != null) 'IncCurrLabel': request.incCurrLabel!,
      if (receiptForRequest != null) 'Receipt': receiptForRequest,
      if (_config.isTest) 'IsTest': '1',
      if (request.recurring) 'Recurring': 'true',
      ...shpEncoded,
      'SignatureValue': signature,
    };

    final body = _formUrlEncode(form);
    final useClassic = request.target == CurlPaymentTarget.indexClassic;
    final endpoint = useClassic ? _config.endpoints.indexClassicUrl : _config.endpoints.paymentCurl;

    final response = await _http.post(
      endpoint,
      body: body,
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      followRedirects: !useClassic,
    );

    if (useClassic) {
      if (response.statusCode >= 300 && response.statusCode < 400) {
        final loc = response.headers['location'];
        if (loc != null && loc.isNotEmpty) {
          return loc;
        }
      }
      throw RobokassaException(
        'Classic Index: ожидался HTTP 3xx и заголовок Location (без следования редиректам). '
        'Получено: ${response.statusCode}. Тело: ${_shortBody(response.body)}',
      );
    }

    if (response.statusCode == 200) {
      final data = _tryDecode(response.body);
      if (data is Map && data['invoiceID'] != null) {
        return '${_config.endpoints.paymentUrl}${data['invoiceID']}';
      }
      throw const RobokassaException('Invoice ID not found in response');
    }
    throw RobokassaException(
      'Failed to send payment request. HTTP status: ${response.statusCode}',
    );
  }

  Future<RecurringPaymentResult> sendRecurringChild(RecurringPaymentRequest request) async {
    request.validate();

    String? receiptEncodedOnce;
    String? receiptForRequest;
    if (request.receipt != null) {
      final json = jsonEncode(request.receipt!.toJson());
      receiptEncodedOnce = Uri.encodeQueryComponent(json);
      receiptForRequest = Uri.encodeQueryComponent(receiptEncodedOnce);
    }

    final shpEncoded = <String, String>{
      for (final e in request.shpParams.entries) e.key: Uri.encodeQueryComponent(e.value),
    };

    final signature = _signer.createPaymentSignature(
      login: _config.login,
      password1: _config.activePassword1,
      outSum: request.outSum.toString(),
      invoiceId: request.invoiceId.toString(),
      receipt: receiptEncodedOnce,
      shpParams: request.shpParams,
      algorithm: _config.hashType,
    );

    final form = <String, String>{
      'MerchantLogin': _config.login,
      'InvoiceID': request.invoiceId.toString(),
      'PreviousInvoiceID': request.previousInvoiceId.toString(),
      'Description': request.description,
      'OutSum': request.outSum.toString(),
      'Culture': request.culture,
      if (request.email != null) 'Email': request.email!,
      if (receiptForRequest != null) 'Receipt': receiptForRequest,
      if (_config.isTest) 'IsTest': '1',
      ...shpEncoded,
      'SignatureValue': signature,
    };

    final body = _formUrlEncode(form);
    final response = await _http.post(
      _config.endpoints.recurringUrl,
      body: body,
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode != 200) {
      throw RobokassaException(
        'Recurring request failed. HTTP ${response.statusCode}: ${_shortBody(response.body)}',
      );
    }

    return RecurringPaymentResult.parse(response.body);
  }

  Object? _tryDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  String _formUrlEncode(Map<String, String> form) {
    return form.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
  }

  String _shortBody(String body, [int max = 400]) {
    final t = body.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }
}
