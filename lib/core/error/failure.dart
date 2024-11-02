class Failure {
  final String message;
  const Failure([this.message = 'An unexpected error occurred']);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

/*class TestingFailure extends Failure {
  TestingFailure({required String message})
      : super(message: message);
}*/
