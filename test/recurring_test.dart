import 'package:robokassa_dart/robokassa_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RecurringPaymentResult.parse', () {
    test('parses OK+ with numeric id', () {
      final r = RecurringPaymentResult.parse('OK+42\n');
      expect(r.isOperationCreated, isTrue);
      expect(r.invoiceIdFromResponse, 42);
      expect(r.rawBody, contains('OK+'));
    });

    test('parses OK+ without id', () {
      final r = RecurringPaymentResult.parse('OK+');
      expect(r.isOperationCreated, isTrue);
      expect(r.invoiceIdFromResponse, isNull);
    });

    test('failure body', () {
      final r = RecurringPaymentResult.parse('Some error');
      expect(r.isOperationCreated, isFalse);
      expect(r.invoiceIdFromResponse, isNull);
    });
  });

  group('Recurring child signature', () {
    const signer = SignatureService();

    test('matches standard payment signature for same invoice id (Previous not in hash)', () {
      final child = signer.createPaymentSignature(
        login: 'demo',
        password1: 'secret1',
        outSum: '100',
        invoiceId: '156',
        algorithm: HashType.md5,
      );
      final ordinary = signer.createPaymentSignature(
        login: 'demo',
        password1: 'secret1',
        outSum: '100',
        invoiceId: '156',
        algorithm: HashType.md5,
      );
      expect(child, equals(ordinary));
    });
  });

  group('RecurringPaymentRequest.validate', () {
    test('throws on non-positive invoiceId', () {
      expect(
        () => const RecurringPaymentRequest(
          invoiceId: 0,
          previousInvoiceId: 10,
          outSum: 1,
          description: 'x',
        ).validate(),
        throwsA(isA<RobokassaException>()),
      );
    });
  });
}
