import 'dart:async';

import 'package:dars/dars.dart';
import 'package:dars_test/dars_test.dart';
import 'package:dars_test/mockito.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// because reachable from main check is not needed for tests.
// ignore_for_file: unreachable_from_main

/// Test service for Mockito integration.
abstract class AuthService {
  /// Test method for synchronous Result.
  Result<String, String> login(String username);

  /// Test method for asynchronous Result.
  Future<Result<String, String>> loginAsync(String username);
}

/// Mock implementation of AuthService.
class MockAuthService extends Mock implements AuthService {
  @override
  Result<String, String> login(String? username) => super.noSuchMethod(
        Invocation.method(#login, [username]),
        returnValue: const Ok<String, String>('default'),
      ) as Result<String, String>;

  @override
  Future<Result<String, String>> loginAsync(String? username) => super.noSuchMethod(
        Invocation.method(#loginAsync, [username]),
        returnValue: Future.value(const Ok<String, String>('default')),
      ) as Future<Result<String, String>>;
}

/// A service used to trigger MissingDummyValueError naturally.
abstract class NoDummyService {
  /// A method that returns a Result but has no dummy registered.
  Result<int, String> getResult();

  /// A method that returns a `Future<Result>` but has no dummy registered.
  Future<Result<int, String>> getResultAsync();
}

/// Mock for the unprepared service.
class MockNoDummyService extends Mock implements NoDummyService {
  @override
  Result<int, String> getResult() =>
      // We call our own noSuchMethod override to trigger the simulated error.
      noSuchMethod(
        Invocation.method(#getResult, []),
      ) as Result<int, String>;

  @override
  Future<Result<int, String>> getResultAsync() =>
      // We call our own noSuchMethod override to trigger the simulated error.
      noSuchMethod(
        Invocation.method(#getResultAsync, []),
      ) as Future<Result<int, String>>;

  @override
  dynamic noSuchMethod(
    Invocation invocation, {
    Object? returnValue,
    Object? returnValueForMissingStub,
  }) {
    if (returnValue == null && (invocation.memberName == #getResult || invocation.memberName == #getResultAsync)) {
      // Because we want to simulate Mockito's natural MissingDummyValueError.
      // ignore: only_throw_errors
      throw MissingDummyValueError(Result<int, String>);
    }
    return super.noSuchMethod(
      invocation,
      returnValue: returnValue,
      returnValueForMissingStub: returnValueForMissingStub,
    );
  }
}

void main() {
  group('whenResult', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    test('should stub synchronous Result returning methods', () {
      const user = 'test_user';

      whenResult(
        () => mockAuthService.login('admin'),
        dummy: const Ok('dummy'),
      ).thenReturn(const Ok(user));

      final result = mockAuthService.login('admin');

      expect(result, isOk<String>(user));
    });

    test('should stub asynchronous Result returning methods with whenFutureResult', () async {
      const user = 'async_user';

      whenFutureResult(
        () => mockAuthService.loginAsync('admin'),
        dummy: const Ok('dummy'),
      ).thenAnswer((_) async => const Ok(user));

      final result = await mockAuthService.loginAsync('admin');

      expect(result, isOk<String>(user));
    });

    test('should work without dummy if already provided', () {
      whenResult(() => mockAuthService.login('admin')).thenReturn(const Ok('success'));

      expect(mockAuthService.login('admin'), isOk<String>('success'));
    });

    test('should throw detailed Exception when MissingDummyValueError occurs', () {
      final mockNoDummy = MockNoDummyService();

      expect(
        () => whenResult(mockNoDummy.getResult),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString()',
            contains('MissingDummyValueError occurred while stubbing a Result-returning method'),
          ),
        ),
      );
    });

    test('should throw detailed Exception when MissingDummyValueError occurs in whenFutureResult', () {
      final mockNoDummy = MockNoDummyService();

      expect(
        () => whenFutureResult(mockNoDummy.getResultAsync),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString()',
            contains(
              'MissingDummyValueError occurred while stubbing a Future<Result>-returning method',
            ),
          ),
        ),
      );
    });

    test('should throw detailed Exception when dummy type mismatch occurs', () {
      expect(
        () => whenResult(
          () => mockAuthService.login('admin'),
          dummy: const Ok(123), // login returns Result<String, String>, but we provide Result<int, Object>
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString()',
            contains('The provided dummy value types do not match the expected Result types'),
          ),
        ),
      );
    });
  });
}
