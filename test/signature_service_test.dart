import 'package:robokassa_dart/robokassa_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SignatureService', () {
    const signer = SignatureService();

    test('base64UrlNoPad strips padding', () {
      final value = signer.base64UrlNoPadFromString('abc');
      expect(value, isNot(contains('=')));
    });

    test('signOpState produces md5 hex of login:invoice:password2', () {
      final hash = signer.signOpState(
        login: 'shop',
        invoiceId: '42',
        password2: 'secret',
        algorithm: HashType.md5,
      );
      expect(hash, hasLength(32));
      expect(hash, matches(RegExp(r'^[0-9a-f]+$')));
    });

    test('createPaymentSignature without shp params', () {
      final hash = signer.createPaymentSignature(
        login: 'shop',
        password1: 'pass',
        outSum: '10.00',
        invoiceId: '1',
        algorithm: HashType.md5,
      );
      expect(hash, hasLength(32));
    });

    test('createPaymentSignature sorts shp params', () {
      final a = signer.createPaymentSignature(
        login: 'shop',
        password1: 'pass',
        outSum: '10.00',
        invoiceId: '1',
        shpParams: {'Shp_b': '2', 'Shp_a': '1'},
        algorithm: HashType.md5,
      );
      final b = signer.createPaymentSignature(
        login: 'shop',
        password1: 'pass',
        outSum: '10.00',
        invoiceId: '1',
        shpParams: {'Shp_a': '1', 'Shp_b': '2'},
        algorithm: HashType.md5,
      );
      expect(a, equals(b));
    });

    test('jwtSignMd5 produces base64url without padding', () {
      final value = signer.jwtSignMd5('data.to.sign', 'shop', 'pass');
      expect(value, isNot(contains('=')));
      expect(value, isNot(contains('+')));
      expect(value, isNot(contains('/')));
    });

    test('encodeJwtParts glues header and payload with dot', () {
      final parts = signer.encodeJwtParts({'alg': 'MD5'}, {'InvId': 1});
      expect(parts.dataToSign, '${parts.encodedHeader}.${parts.encodedPayload}');
    });
  });

  group('RobokassaConfig', () {
    test('activePassword uses test credentials when isTest', () {
      const config = RobokassaConfig(
        login: 'shop',
        password1: 'live1',
        password2: 'live2',
        testPassword1: 'test1',
        testPassword2: 'test2',
        isTest: true,
      );
      expect(config.activePassword1, 'test1');
      expect(config.activePassword2, 'test2');
    });

    test('validate throws when test passwords missing', () {
      const config = RobokassaConfig(
        login: 'shop',
        password1: 'live1',
        password2: 'live2',
        isTest: true,
      );
      expect(config.validate, throwsA(isA<RobokassaException>()));
    });
  });
}
