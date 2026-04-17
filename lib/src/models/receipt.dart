class ReceiptItem {
  final String name;
  final num quantity;
  final num sum;
  final String? paymentMethod;
  final String? paymentObject;
  final String? tax;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.sum,
    this.paymentMethod,
    this.paymentObject,
    this.tax,
  });

  Map<String, Object?> toJson() => {
        'name': name,
        'quantity': quantity,
        'sum': sum,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (paymentObject != null) 'payment_object': paymentObject,
        if (tax != null) 'tax': tax,
      };
}

class Receipt {
  final List<ReceiptItem> items;
  final String? sno;

  const Receipt({required this.items, this.sno});

  Map<String, Object?> toJson() => {
        if (sno != null) 'sno': sno,
        'items': items.map((e) => e.toJson()).toList(),
      };
}
