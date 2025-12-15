class AppException implements Exception {
  final String message;

  AppException([this.message = 'System error']);

  @override
  String toString() {
    return message;
  }
}
