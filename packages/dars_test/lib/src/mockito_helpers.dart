import 'dart:async';

import 'package:dars/dars.dart';
// Because this is an optional integration and users should provide their own mockito dependency.
// ignore: depend_on_referenced_packages
import 'package:mockito/mockito.dart';

/// A wrapper for Mockito's [when] that simplifies stubbing methods returning [Result].
///
/// Since Mockito requires a dummy value for non-nullable return types during stubbing, this utility allows providing a
/// [dummy] value which is then registered via [provideDummy] for [Result<T, E>].
///
/// Example:
/// ```dart
/// whenResult(() => mock.getUser(), dummy: Ok(dummyUser)).thenReturn(Ok(actualUser));
/// ```
PostExpectation<Result<T, E>> whenResult<T, E extends Object>(
  Result<T, E> Function() invocation, {
  Result<T, E>? dummy,
}) {
  if (dummy != null) {
    provideDummy<Result<T, E>>(dummy);
  }

  try {
    return when(invocation());
  } on MissingDummyValueError catch (e) {
    throw Exception(
      'whenResult: MissingDummyValueError occurred while stubbing a Result-returning method.\n'
      'This usually happens because the Result type needs a dummy value registered with Mockito.\n\n'
      'To fix this, provide a dummy value to whenResult:\n'
      "  whenResult(() => mock.method(), dummy: Ok('dummy_value'))\n\n"
      'Original error: $e',
    );
  }
}

/// A wrapper for Mockito's [when] that simplifies stubbing methods returning [Future<Result>].
///
/// Since Mockito requires a dummy value for non-nullable return types during stubbing, this utility allows providing a
/// [dummy] value which is then registered via [provideDummy] for both [Result<T, E>] and [Future<Result<T, E>>].
///
/// Example:
/// ```dart
/// whenFutureResult(() => mock.getUser(), dummy: Ok(dummyUser))
///   .thenAnswer((_) async => Ok(actualUser));
/// ```
PostExpectation<Future<Result<T, E>>> whenFutureResult<T, E extends Object>(
  Future<Result<T, E>> Function() invocation, {
  Result<T, E>? dummy,
}) {
  if (dummy != null) {
    provideDummy<Result<T, E>>(dummy);
    provideDummy<Future<Result<T, E>>>(Future.value(dummy));
  }

  try {
    return when(invocation());
  } on MissingDummyValueError catch (e) {
    throw Exception(
      'whenFutureResult: MissingDummyValueError occurred while stubbing a Future<Result>-returning method.\n'
      'This usually happens because the Result type needs dummy values registered with Mockito.\n\n'
      'To fix this, provide a dummy value to whenFutureResult:\n'
      "  whenFutureResult(() => mock.method(), dummy: Ok('dummy_value'))\n\n"
      'Original error: $e',
    );
  }
}
