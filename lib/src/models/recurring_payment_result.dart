class RecurringPaymentResult {
  final String rawBody;

  final bool isOperationCreated;

  final int? invoiceIdFromResponse;

  const RecurringPaymentResult({
    required this.rawBody,
    required this.isOperationCreated,
    this.invoiceIdFromResponse,
  });

  static RecurringPaymentResult parse(String body) {
    final trimmed = body.trim();
    if (trimmed.toUpperCase().startsWith('OK+')) {
      final rest = trimmed.substring(3).trim();
      final id = int.tryParse(rest);
      return RecurringPaymentResult(
        rawBody: body,
        isOperationCreated: true,
        invoiceIdFromResponse: id,
      );
    }
    return RecurringPaymentResult(rawBody: body, isOperationCreated: false);
  }
}
