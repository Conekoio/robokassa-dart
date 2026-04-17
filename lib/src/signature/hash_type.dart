enum HashType {
  md5('md5'),
  sha1('sha1'),
  sha256('sha256'),
  sha384('sha384'),
  sha512('sha512'),
  ripemd160('ripemd160');

  final String name;

  const HashType(this.name);

  static HashType fromString(String value) {
    final normalized = value.toLowerCase();
    for (final type in HashType.values) {
      if (type.name == normalized) return type;
    }
    throw ArgumentError('Unsupported hash type: $value');
  }
}
