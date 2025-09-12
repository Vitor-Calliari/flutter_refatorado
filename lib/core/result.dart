
//tratamento de sucesso/erro
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  
  const Failure(this.message, [this.exception]);
}

// Extensions
extension ResultExtensions<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  
  T? get data => isSuccess ? (this as Success<T>).data : null;
  String? get error => isFailure ? (this as Failure<T>).message : null;
  Exception? get exception => isFailure ? (this as Failure<T>).exception : null;
  
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, Exception? exception) onFailure,
  }) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Failure(message: final message, exception: final exception) => onFailure(message, exception),
    };
  }
}
