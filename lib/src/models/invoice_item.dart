class InvoiceItem {
  final String name;
  final num quantity;
  final num cost;
  final String? tax;
  final String? paymentMethod;
  final String? paymentObject;

  const InvoiceItem({
    required this.name,
    required this.quantity,
    required this.cost,
    this.tax,
    this.paymentMethod,
    this.paymentObject,
  });

  Map<String, Object?> toJson() => {
        'Name': name,
        'Quantity': quantity,
        'Cost': cost,
        if (tax != null) 'Tax': tax,
        if (paymentMethod != null) 'PaymentMethod': paymentMethod,
        if (paymentObject != null) 'PaymentObject': paymentObject,
      };
}
