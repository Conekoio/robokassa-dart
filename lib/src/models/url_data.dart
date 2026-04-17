class UrlData {
  final String url;
  final String method;

  const UrlData({required this.url, this.method = 'GET'});

  Map<String, Object?> toJson() => {
        'Url': url,
        'Method': method,
      };
}
