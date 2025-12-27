import 'dart:async';

import 'package:dars/dars.dart';
import 'package:dars_test/mockito.dart';
import 'package:mockito/annotations.dart';

/// Generate mocks using @GenerateNiceMocks.
/// Run `dart run build_runner build` to generate mockito_example.mocks.dart
@GenerateNiceMocks([MockSpec<ApiService>()])
import 'mockito_example.mocks.dart';

// because reachable from main check is not needed for examples.
// ignore_for_file: unreachable_from_main, avoid_print

/// Example interface for ApiService.
abstract class ApiService {
  /// Fetches data synchronously.
  Result<String, Exception> fetchData(String id);

  /// Fetches data asynchronously.
  Future<Result<String, Exception>> fetchDataAsync(String id);
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
