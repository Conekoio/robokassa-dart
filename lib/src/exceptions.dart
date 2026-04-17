class RobokassaException implements Exception {
  final String message;
  final Object? cause;

  const RobokassaException(this.message, [this.cause]);

  @override
  String toString() => cause == null ? 'RobokassaException: $message' : 'RobokassaException: $message (cause: $cause)';
}
