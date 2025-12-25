import 'dart:async';

import 'result.dart';

/// A [Future] that resolves to a [Result].
///
/// This is a convenience type alias for `Future<Result<T, E>>`.
typedef FutureResult<T, E extends Object> = Future<Result<T, E>>;

/// Extension methods for [FutureResult].
///
/// This extension allows calling [Result] methods directly on a [Future]
/// without needing to await first.
extension FutureResultExtension<T, E extends Object> on FutureResult<T, E> {
  /// Returns `true` if the awaited result is [Ok].
  Future<bool> get isOk async => (await this).isOk;

  /// Returns `true` if the awaited result is [Err].
  Future<bool> get isErr async => (await this).isErr;

  /// Returns `true` if the awaited result is [Ok] and satisfies [predicate].
  Future<bool> isOkWhere(bool Function(T value) predicate) async => (await this).isOkWhere(predicate);

  /// Returns `true` if the awaited result is [Err] and satisfies [predicate].
  Future<bool> isErrWhere(bool Function(E error) predicate) async => (await this).isErrWhere(predicate);

  /// Returns the success value if awaited result is [Ok], otherwise `null`.
  Future<T?> ok() async => (await this).ok();

  /// Returns the error value if awaited result is [Err], otherwise `null`.
  Future<E?> err() async => (await this).err();

  /// Returns the success value if awaited result is [Ok], otherwise [orElse].
  Future<T> get({required FutureOr<T> Function(E error) orElse}) async {
    final result = await this;
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => await orElse(error),
    };
  }

  /// Returns the success value if awaited result is [Ok], otherwise throws.
  Future<T> getOrThrow([String? message]) async => (await this).getOrThrow(message);

  /// Transforms the success value of the awaited result.
  FutureResult<U, E> map<U>(FutureOr<U> Function(T value) transform) async {
    final result = await this;
    return switch (result) {
      Ok(:final value) => Ok(await transform(value)),
      Err(:final error) => Err(error),
    };
  }

  /// Transforms the error value of the awaited result.
  FutureResult<T, F> mapError<F extends Object>(
    FutureOr<F> Function(E error) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Ok(:final value) => Ok(value),
      Err(:final error) => Err(await transform(error)),
    };
  }

  /// Transforms the awaited result value directly.
  Future<U> fold<U>(
    FutureOr<U> Function(T value) transform, {
    required FutureOr<U> Function(E error) orElse,
  }) async {
    final result = await this;
    return switch (result) {
      Ok(:final value) => await transform(value),
      Err(:final error) => await orElse(error),
    };
  }

  /// Transforms the success value into another [Result].
  FutureResult<U, E> flatMap<U>(
    FutureOr<Result<U, E>> Function(T value) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Ok(:final value) => await transform(value),
      Err(:final error) => Err(error),
    };
  }

  /// Recovers from an error by transforming it into a new [Result].
  FutureResult<T, F> recover<F extends Object>(
    FutureOr<Result<T, F>> Function(E error) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Ok(:final value) => Ok(value),
      Err(:final error) => await transform(error),
    };
  }

  /// Executes [action] with the success value for side effects.
  FutureResult<T, E> tap(void Function(T value) action) async => (await this).tap(action);

  /// Executes [action] with the error value for side effects.
  FutureResult<T, E> tapError(void Function(E error) action) async => (await this).tapError(action);

  /// Casts the success value type to [U].
  FutureResult<U, E> castOk<U>() async => (await this).castOk<U>();

  /// Casts the error type to [F].
  FutureResult<T, F> castErr<F extends Object>() async => (await this).castErr<F>();

  /// Casts both success and error types.
  FutureResult<U, F> cast<U, F extends Object>() async => (await this).cast<U, F>();

  /// Extracts the success value for early return in async [Result] factories.
  ///
  /// If the awaited result is [Err], throws an internal exception to exit the factory.
  Future<T> operator [](EarlyReturnSymbol<E> $) async => (await this)[$];
}

/// Extension to convert a [Result] to a [FutureResult].
extension ResultToAsyncExtension<T, E extends Object> on Result<T, E> {
  /// Converts this [Result] to a [FutureResult].
  ///
  /// This is useful when you need to pass a synchronous [Result]
  /// where a [FutureResult] is expected.
  FutureResult<T, E> get async => Future.value(this);
}
