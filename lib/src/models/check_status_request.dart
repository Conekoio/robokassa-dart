class CheckStatusRequest {
  final String merchantId;
  final String id;

  const CheckStatusRequest({required this.merchantId, required this.id});

  Map<String, Object?> toJson() => {
        'merchantId': merchantId,
        'id': id,
      };
}
