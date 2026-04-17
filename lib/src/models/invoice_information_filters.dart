enum InvoiceStatus {
  paid('Paid'),
  expired('Expired'),
  notPaid('Notpaid');

  final String wireValue;

  const InvoiceStatus(this.wireValue);
}

enum InvoiceTypeFilter {
  oneTime('OneTime'),
  reusable('Reusable');

  final String wireValue;

  const InvoiceTypeFilter(this.wireValue);
}

class InvoiceInformationFilters {
  final int currentPage;
  final int pageSize;
  final List<InvoiceStatus> invoiceStatuses;
  final DateTime dateFrom;
  final DateTime dateTo;
  final List<InvoiceTypeFilter> invoiceTypes;
  final bool? isAscending;
  final List<String> paymentAliases;
  final num? sumFrom;
  final num? sumTo;

  const InvoiceInformationFilters({
    required this.currentPage,
    required this.pageSize,
    required this.invoiceStatuses,
    required this.dateFrom,
    required this.dateTo,
    required this.invoiceTypes,
    this.isAscending,
    this.paymentAliases = const [],
    this.sumFrom,
    this.sumTo,
  });

  Map<String, Object?> toJson() {
    final df = dateFrom.toUtc();
    final dt = dateTo.toUtc();
    String fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    return {
      'CurrentPage': currentPage,
      'PageSize': pageSize,
      'InvoiceStatuses': invoiceStatuses.map((e) => e.wireValue).toList(),
      'DateFrom': fmt(df),
      'DateTo': fmt(dt),
      'InvoiceTypes': invoiceTypes.map((e) => e.wireValue).toList(),
      if (isAscending != null) 'IsAscending': isAscending,
      if (paymentAliases.isNotEmpty) 'PaymentAliases': paymentAliases,
      if (sumFrom != null) 'SumFrom': sumFrom,
      if (sumTo != null) 'SumTo': sumTo,
    };
  }
}
