abstract class Resource<T> {}

class Initial extends Resource {}

class Loading extends Resource {}

class Success<T> extends Resource<T> {
  final T data;
  Success(this.data);
}
class ErrorData<T> extends Resource<T>{
  final String error;
  ErrorData(this.error);

  @override
  String toString() => 'Error: $error';
}