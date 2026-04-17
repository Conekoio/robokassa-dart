class FiscalClient {
  final String? email;
  final String? phone;
  final String? name;
  final String? inn;

  const FiscalClient({this.email, this.phone, this.name, this.inn});

  Map<String, Object?> toJson() => {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (name != null) 'name': name,
        if (inn != null) 'inn': inn,
      };
}

class FiscalItem {
  final String name;
  final num quantity;
  final num sum;
  final String? tax;
  final String? paymentMethod;
  final String? paymentObject;

  const FiscalItem({
    required this.name,
    required this.quantity,
    required this.sum,
    this.tax,
    this.paymentMethod,
    this.paymentObject,
  });

  Map<String, Object?> toJson() => {
        'name': name,
        'quantity': quantity,
        'sum': sum,
        if (tax != null) 'tax': tax,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (paymentObject != null) 'payment_object': paymentObject,
      };
}

class FiscalPayment {
  final int type;
  final num sum;

  const FiscalPayment({required this.type, required this.sum});

  Map<String, Object?> toJson() => {'type': type, 'sum': sum};
}

class FiscalVat {
  final String type;
  final num sum;

  const FiscalVat({required this.type, required this.sum});

  Map<String, Object?> toJson() => {'type': type, 'sum': sum};
}

class SecondCheckRequest {
  final String merchantId;
  final String id;
  final String originId;
  final String operation;
  final String? sno;
  final String? url;
  final num total;
  final List<FiscalItem> items;
  final FiscalClient client;
  final List<FiscalPayment> payments;
  final List<FiscalVat> vats;

  const SecondCheckRequest({
    required this.merchantId,
    required this.id,
    required this.originId,
    required this.operation,
    required this.total,
    required this.items,
    required this.client,
    required this.payments,
    required this.vats,
    this.sno,
    this.url,
  });

  Map<String, Object?> toJson() => {
        'merchantId': merchantId,
        'id': id,
        'originId': originId,
        'operation': operation,
        if (sno != null) 'sno': sno,
        if (url != null) 'url': url,
        'total': total,
        'items': items.map((e) => e.toJson()).toList(),
        'client': client.toJson(),
        'payments': payments.map((e) => e.toJson()).toList(),
        'vats': vats.map((e) => e.toJson()).toList(),
      };
}
