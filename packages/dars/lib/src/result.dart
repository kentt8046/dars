// ignore_for_file: document_ignores, avoid_equals_and_hash_code_on_mutable_classes

import 'dart:async';

/// A type that represents either success ([Ok]) or failure ([Err]).
///
/// [Result] is commonly used for error handling where you want to explicitly
/// handle both success and failure cases without exceptions.
///
/// Example:
/// ```dart
/// Result<int, String> divide(int a, int b) {
///   if (b == 0) return Err('Division by zero');
///   return Ok(a ~/ b);
/// }
///
/// final result = divide(10, 2);
/// switch (result) {
///   case Ok(:final value): print('Result: $value');
///   case Err(:final error): print('Error: $error');
/// }
/// ```
sealed class Result<T, E extends Object> {
  /// Creates a [Result] by executing a function that may return early on [Err].
  ///
  /// The `$` symbol passed to the callback can be used with the `[]` operator
  /// to extract values from other [Result]s, returning early if they are [Err].
  ///
  /// Exceptions thrown in the callback are handled as follows:
  /// - [Error] exceptions are rethrown (programming errors should not be caught)
  /// - All other exceptions are passed to [onCatch] to be converted to [Err]
  ///
  /// Example:
  /// ```dart
  /// Result<int, String> process() => Result(
  ///   ($) {
  ///     final a = getValueA()[$];  // Returns early if Err
  ///     final b = getValueB()[$];  // Returns early if Err
  ///     return a + b;
  ///   },
  ///   onCatch: (e, s) => Err('Error: $e'),
  /// );
  /// ```
  factory Result(
    T Function(EarlyReturnSymbol<E> $) fn, {
    required Result<T, E> Function(Object error, StackTrace stackTrace) onCatch,
  }) {
    try {
      return Ok(fn(EarlyReturnSymbol<E>._()));
    } on _EarlyReturn<E> catch (e) {
      return Err(e.error);
    } on Error {
      rethrow;
    } catch (e, s) {
      return onCatch(e, s);
    }
  }
  const Result._();

  /// Creates a [Result] asynchronously, with early return support.
  ///
  /// Similar to the synchronous [Result.new] factory, but works with
  /// async functions and [Future]s.
  ///
  /// Example:
  /// ```dart
  /// Future<Result<Data, Error>> fetchData() => Result.async(
  ///   ($) async {
  ///     final user = await getUser()[$];
  ///     final data = await getData(user)[$];
  ///     return data;
  ///   },
  ///   onCatch: (e, s) => Err('Error: $e'),
  /// );
  /// ```
  static Future<Result<T, E>> async<T, E extends Object>(
    Future<T> Function(EarlyReturnSymbol<E> $) fn, {
    required FutureOr<Result<T, E>> Function(
      Object error,
      StackTrace stackTrace,
    ) onCatch,
  }) async {
    try {
      return Ok(await fn(EarlyReturnSymbol<E>._()));
    } on _EarlyReturn<E> catch (e) {
      return Err(e.error);
    } on Error {
      rethrow;
    } catch (e, s) {
      return onCatch(e, s);
    }
  }

  /// Returns `true` if this is an [Ok] value.
  bool get isOk;

  /// Returns `true` if this is an [Err] value.
  bool get isErr;

  /// Returns `true` if this is an [Ok] value and the value satisfies [predicate].
  bool isOkWhere(bool Function(T value) predicate);

  /// Returns `true` if this is an [Err] value and the error satisfies [predicate].
  bool isErrWhere(bool Function(E error) predicate);

  /// Returns the success value if [Ok], otherwise `null`.
  T? ok();

  /// Returns the error value if [Err], otherwise `null`.
  E? err();

  /// Returns the success value if [Ok], otherwise the result of [orElse].
  T get({required T Function(E error) orElse});

  /// Returns the success value if [Ok], otherwise throws.
  ///
  /// If [message] is provided, it will be included in the exception.
  T getOrThrow([String? message]);

  /// Transforms the success value using [transform].
  ///
  /// If this is [Err], returns [Err] unchanged.
  Result<U, E> map<U>(U Function(T value) transform);

  /// Transforms the error value using [transform].
  ///
  /// If this is [Ok], returns [Ok] unchanged.
  Result<T, F> mapError<F extends Object>(F Function(E error) transform);

  /// Transforms the success value and returns the result directly.
  ///
  /// If this is [Err], returns the result of [orElse].
  U fold<U>(
    U Function(T value) transform, {
    required U Function(E error) orElse,
  });

  /// Transforms the success value into another [Result].
  ///
  /// If this is [Err], returns [Err] unchanged.
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) transform);

  /// Recovers from an error by transforming it into a new [Result].
  ///
  /// If this is [Ok], returns [Ok] unchanged.
  Result<T, F> recover<F extends Object>(
    Result<T, F> Function(E error) transform,
  );

  /// Executes [action] with the success value for side effects.
  ///
  /// Returns this [Result] unchanged.
  Result<T, E> tap(void Function(T value) action);

  /// Executes [action] with the error value for side effects.
  ///
  /// Returns this [Result] unchanged.
  Result<T, E> tapError(void Function(E error) action);

  /// Casts the success value type to [U].
  ///
  /// Throws [TypeError] if the cast fails.
  Result<U, E> castOk<U>();

  /// Casts the error type to [F].
  ///
  /// Throws [TypeError] if the cast fails.
  Result<T, F> castErr<F extends Object>();

  /// Casts both success and error types.
  ///
  /// Throws [TypeError] if either cast fails.
  Result<U, F> cast<U, F extends Object>();

  /// Extracts the success value for early return in [Result] factories.
  ///
  /// If this is [Err], throws an internal exception to exit the factory.
  T operator [](EarlyReturnSymbol<E> $);
}

/// Represents a successful [Result] containing a [value].
final class Ok<T, E extends Object> extends Result<T, E> {
  /// Creates an [Ok] result with the given [value].
  const Ok(this.value) : super._();

  /// The success value.
  final T value;

  @override
  bool get isOk => true;

  @override
  bool get isErr => false;

  @override
  bool isOkWhere(bool Function(T value) predicate) => predicate(value);

  @override
  bool isErrWhere(bool Function(E error) predicate) => false;

  @override
  T? ok() => value;

  @override
  E? err() => null;

  @override
  T get({required T Function(E error) orElse}) => value;

  @override
  T getOrThrow([String? message]) => value;

  @override
  Result<U, E> map<U>(U Function(T value) transform) => Ok(transform(value));

  @override
  Result<T, F> mapError<F extends Object>(F Function(E error) transform) => Ok(value);

  @override
  U fold<U>(
    U Function(T value) transform, {
    required U Function(E error) orElse,
  }) =>
      transform(value);

  @override
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) transform) => transform(value);

  @override
  Result<T, F> recover<F extends Object>(
    Result<T, F> Function(E error) transform,
  ) =>
      Ok(value);

  @override
  Result<T, E> tap(void Function(T value) action) {
    action(value);
    return this;
  }

  @override
  Result<T, E> tapError(void Function(E error) action) => this;

  @override
  Result<U, E> castOk<U>() => Ok(value as U);

  @override
  Result<T, F> castErr<F extends Object>() => Ok(value);

  @override
  Result<U, F> cast<U, F extends Object>() => Ok(value as U);

  @override
  T operator [](EarlyReturnSymbol<E> $) => value;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Ok<T, E> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

/// Represents a failed [Result] containing an [error].
final class Err<T, E extends Object> extends Result<T, E> {
  /// Creates an [Err] result with the given [error].
  const Err(this.error) : super._();

  /// The error value.
  final E error;

  @override
  bool get isOk => false;

  @override
  bool get isErr => true;

  @override
  bool isOkWhere(bool Function(T value) predicate) => false;

  @override
  bool isErrWhere(bool Function(E error) predicate) => predicate(error);

  @override
  T? ok() => null;

  @override
  E? err() => error;

  @override
  T get({required T Function(E error) orElse}) => orElse(error);

  @override
  T getOrThrow([String? message]) {
    final errorMessage = message != null ? '$message: $error' : '$error';
    throw StateError(errorMessage);
  }

  @override
  Result<U, E> map<U>(U Function(T value) transform) => Err(error);

  @override
  Result<T, F> mapError<F extends Object>(F Function(E error) transform) => Err(transform(error));

  @override
  U fold<U>(
    U Function(T value) transform, {
    required U Function(E error) orElse,
  }) =>
      orElse(error);

  @override
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) transform) => Err(error);

  @override
  Result<T, F> recover<F extends Object>(
    Result<T, F> Function(E error) transform,
  ) =>
      transform(error);

  @override
  Result<T, E> tap(void Function(T value) action) => this;

  @override
  Result<T, E> tapError(void Function(E error) action) {
    action(error);
    return this;
  }

  @override
  Result<U, E> castOk<U>() => Err(error);

  @override
  Result<T, F> castErr<F extends Object>() => Err(error as F);

  @override
  Result<U, F> cast<U, F extends Object>() => Err(error as F);

  @override
  T operator [](EarlyReturnSymbol<E> $) => throw _EarlyReturn(error);

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Err<T, E> && other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Err($error)';
}

/// Symbol used for early return in Result context.
///
/// This symbol is passed to the callback in [Result.new] and [Result.async]
/// factories, enabling early return from Err values.
///
/// Example:
/// ```dart
/// Result<int, String> process() => Result(($) {
///   final value = mayFail()[$]; // Returns early if Err
///   return value * 2;
/// });
/// ```
class EarlyReturnSymbol<E extends Object> {
  const EarlyReturnSymbol._();
}

/// Internal exception used for early return control flow.
///
/// This exception is caught by [Result] factories to convert
/// early returns into [Err] values.
class _EarlyReturn<E extends Object> implements Exception {
  /// Creates an early return exception with the given error.
  const _EarlyReturn(this.error);

  /// The error value to be wrapped in [Err].
  final E error;
}
