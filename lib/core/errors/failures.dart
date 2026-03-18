abstract class Failure {
  final String message;
  const Failure(this.message);
}

// Internet na ho tab
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection!');
}

// Firebase mein kuch gadbad ho tab
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// SQLite mein kuch gadbad ho tab
class CacheFailure extends Failure {
  const CacheFailure() : super('Local data error!');
}

// Login na ho tab
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// File upload mein gadbad ho tab
class StorageFailure extends Failure {
  const StorageFailure() : super('File upload failed!');
}
