import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:robokassa_dart/src/exceptions.dart';

import 'hash_type.dart';

class JwtParts {
  final String encodedHeader;
  final String encodedPayload;
  final String dataToSign;

  const JwtParts({
    required this.encodedHeader,
    required this.encodedPayload,
    required this.dataToSign,
  });
}

class SignatureService {
  static const Set<HashType> _fiscalAllowed = {
    HashType.md5,
    HashType.sha256,
    HashType.sha512,
  };

  final HashType defaultAlgorithm;

  const SignatureService({this.defaultAlgorithm = HashType.md5});

  String base64UrlNoPad(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String base64UrlNoPadFromString(String value) {
    return base64UrlNoPad(utf8.encode(value));
  }

  String hashHex(List<int> bytes, HashType algorithm) {
    switch (algorithm) {
      case HashType.md5:
        return md5.convert(bytes).toString();
      case HashType.sha1:
        return sha1.convert(bytes).toString();
      case HashType.sha256:
        return sha256.convert(bytes).toString();
      case HashType.sha384:
        return sha384.convert(bytes).toString();
      case HashType.sha512:
        return sha512.convert(bytes).toString();
      case HashType.ripemd160:
        throw const RobokassaException(
          'RIPEMD-160 is not supported by the built-in crypto package',
        );
    }
  }

  String signFiscal(String base64Payload, String secret, [HashType? algorithm]) {
    var algo = algorithm ?? defaultAlgorithm;
    if (!_fiscalAllowed.contains(algo)) {
      algo = HashType.md5;
    }
    final hex = hashHex(utf8.encode(base64Payload + secret), algo);
    return base64UrlNoPadFromString(hex);
  }

  String jwtSignMd5(String dataToSign, String merchantLogin, String password1) {
    final hmac = Hmac(md5, utf8.encode('$merchantLogin:$password1'));
    final digest = hmac.convert(utf8.encode(dataToSign));
    return base64UrlNoPad(digest.bytes);
  }

  JwtParts encodeJwtParts(Map<String, Object?> header, Map<String, Object?> payload) {
    final encHeader = base64UrlNoPadFromString(jsonEncode(header));
    final encPayload = base64UrlNoPadFromString(jsonEncode(payload));
    return JwtParts(
      encodedHeader: encHeader,
      encodedPayload: encPayload,
      dataToSign: '$encHeader.$encPayload',
    );
  }

  String createPaymentSignature({
    required String login,
    required String password1,
    required String outSum,
    required String invoiceId,
    String? receipt,
    Map<String, String> shpParams = const {},
    HashType? algorithm,
  }) {
    final parts = <String>[login, outSum, invoiceId];
    if (receipt != null && receipt.isNotEmpty) {
      parts.add(receipt);
    }
    parts.add(password1);

    final shpPairs = shpParams.entries.map((e) => '${e.key}=${e.value}').toList()..sort();

    var hashString = parts.join(':');
    if (shpPairs.isNotEmpty) {
      hashString += ':${shpPairs.join(':')}';
    }

    final algo = algorithm ?? defaultAlgorithm;
    return hashHex(utf8.encode(hashString), algo);
  }

  String signOpState({
    required String login,
    required String invoiceId,
    required String password2,
    HashType? algorithm,
  }) {
    final algo = algorithm ?? defaultAlgorithm;
    return hashHex(utf8.encode('$login:$invoiceId:$password2'), algo);
  }
}
