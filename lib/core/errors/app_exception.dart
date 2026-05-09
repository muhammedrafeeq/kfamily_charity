class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message';
}

class AppAuthException extends AppException {
  const AppAuthException(super.message, {super.code});
}

class AppStorageException extends AppException {
  const AppStorageException(super.message, {super.code});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}
