import 'dart:async';

import 'package:dars/dars.dart';
import 'package:dars_test/mockito.dart';
import 'package:mockito/mockito.dart';

// because reachable from main check is not needed for examples.
// ignore_for_file: unreachable_from_main, avoid_print

/// Example interface for ApiService.
abstract class ApiService {
  /// Fetches data synchronously.
  Result<String, Exception> fetchData(String id);

  /// Fetches data asynchronously.
  Future<Result<String, Exception>> fetchDataAsync(String id);
}

/// Manual mock for ApiService.
class MockApiService extends Mock implements ApiService {
  @override
  Result<String, Exception> fetchData(String? id) =>
      // Mockito generates this code in real projects.
      // ignore: invalid_use_of_visible_for_testing_member
      super.noSuchMethod(
        Invocation.method(#fetchData, [id]),
        returnValue: const Err<String, Exception>(EarlyReturnException()),
      ) as Result<String, Exception>;

  @override
  Future<Result<String, Exception>> fetchDataAsync(String? id) =>
      // Mockito generates this code in real projects.
      // ignore: invalid_use_of_visible_for_testing_member
      super.noSuchMethod(
        Invocation.method(#fetchDataAsync, [id]),
        returnValue: Future.value(
          const Err<String, Exception>(EarlyReturnException()),
        ),
      ) as Future<Result<String, Exception>>;
}

/// A dummy exception for the example.
class EarlyReturnException implements Exception {
  /// Constructor.
  const EarlyReturnException();
}

void main() async {
  final mock = MockApiService();

  print('--- Synchronous stubbing with whenResult ---');
  // whenResult for synchronous methods.
  whenResult(
    () => mock.fetchData('123'),
    dummy: const Ok('dummy_value'),
  ).thenReturn(const Ok('Actual data'));

  final result = mock.fetchData('123');
  print('fetchData("123") -> $result');

  print('\n--- Asynchronous stubbing with whenFutureResult ---');
  // whenFutureResult for asynchronous methods.
  // This provides better type safety: thenAnswer MUST return a Future.
  whenFutureResult(
    () => mock.fetchDataAsync('456'),
    dummy: const Ok('dummy_value'),
  ).thenAnswer((_) async => const Ok('Actual async data'));

  final asyncResult = await mock.fetchDataAsync('456');
  print('fetchDataAsync("456") -> $asyncResult');
}
