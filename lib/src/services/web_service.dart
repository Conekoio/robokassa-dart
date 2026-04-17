import 'package:robokassa_dart/src/config.dart';
import 'package:robokassa_dart/src/exceptions.dart';
import 'package:robokassa_dart/src/http/robokassa_http_client.dart';
import 'package:robokassa_dart/src/signature/signature_service.dart';
import 'package:xml/xml.dart';

class WebService {
  final RobokassaHttpClient _http;
  final SignatureService _signer;
  final RobokassaConfig _config;

  const WebService({
    required RobokassaHttpClient http,
    required SignatureService signer,
    required RobokassaConfig config,
  })  : _http = http,
        _signer = signer,
        _config = config;

  Future<Map<String, Object?>> getPaymentMethods({String language = 'ru'}) async {
    if (language.isEmpty) {
      throw const RobokassaException('language must not be empty');
    }
    final query = _formUrlEncode({
      'MerchantLogin': _config.login,
      'Language': language,
    });
    final url = _buildUrl('GetPaymentMethods', query);
    final response = await _http.get(url);
    if (response.statusCode != 200) {
      throw RobokassaException('HTTP error: ${response.statusCode}');
    }
    return _xmlToMap(response.body);
  }

  Future<Map<String, Object?>> opState(int invoiceId) async {
    final signature = _signer.signOpState(
      login: _config.login,
      invoiceId: invoiceId.toString(),
      password2: _config.activePassword2,
      algorithm: _config.hashType,
    );
    final query = _formUrlEncode({
      'MerchantLogin': _config.login,
      'InvoiceID': invoiceId.toString(),
      'Signature': signature,
    });
    final url = _buildUrl('OpStateExt', query);
    final response = await _http.get(url);
    if (response.statusCode != 200) {
      throw RobokassaException('HTTP error: ${response.statusCode}');
    }
    return _xmlToMap(response.body);
  }

  String _buildUrl(String segment, String query) => '${_config.endpoints.webServiceUrl}/$segment?$query';

  String _formUrlEncode(Map<String, String> form) {
    return form.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
  }

  Map<String, Object?> _xmlToMap(String source) {
    try {
      final document = XmlDocument.parse(source);
      return _elementToMap(document.rootElement);
    } on XmlException catch (e) {
      throw RobokassaException('Failed to parse XML response: ${e.message}', e);
    }
  }

  Map<String, Object?> _elementToMap(XmlElement element) {
    final result = <String, Object?>{};
    for (final attr in element.attributes) {
      result['@${attr.name.local}'] = attr.value;
    }
    final grouped = <String, List<XmlElement>>{};
    for (final child in element.childElements) {
      grouped.putIfAbsent(child.name.local, () => []).add(child);
    }
    grouped.forEach((key, children) {
      if (children.length == 1) {
        result[key] = _nodeValue(children.first);
      } else {
        result[key] = children.map(_nodeValue).toList();
      }
    });
    if (grouped.isEmpty && element.attributes.isEmpty) {
      return {'value': element.innerText};
    }
    final text = element.innerText.trim();
    if (grouped.isEmpty && text.isNotEmpty) {
      result['value'] = text;
    }
    return result;
  }

  Object? _nodeValue(XmlElement element) {
    if (element.childElements.isEmpty && element.attributes.isEmpty) {
      final text = element.innerText;
      return text.isEmpty ? null : text;
    }
    return _elementToMap(element);
  }
}
