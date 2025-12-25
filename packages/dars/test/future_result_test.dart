import 'package:dars/dars.dart';
import 'package:test/test.dart';

void main() {
  group('FutureResultExtension', () {
    test('isOk returns true for Ok', () async {
      expect(await Future.value(const Ok<int, String>(42)).isOk, isTrue);
    });

    test('isOk returns false for Err', () async {
      expect(await Future.value(const Err<int, String>('error')).isOk, isFalse);
    });

    test('isErr returns true for Err', () async {
      expect(await Future.value(const Err<int, String>('error')).isErr, isTrue);
    });

    test('isErr returns false for Ok', () async {
      expect(await Future.value(const Ok<int, String>(42)).isErr, isFalse);
    });

    test('isOkWhere returns true when predicate matches', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(await future.isOkWhere((v) => v > 40), isTrue);
    });

    test('isOkWhere returns false for Err', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(await future.isOkWhere((v) => true), isFalse);
    });

    test('isErrWhere returns true when predicate matches', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(await future.isErrWhere((e) => e.length > 3), isTrue);
    });

    test('isErrWhere returns false for Ok', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(await future.isErrWhere((e) => true), isFalse);
    });

    test('ok() returns value for Ok', () async {
      expect(await Future.value(const Ok<int, String>(42)).ok(), 42);
    });

    test('ok() returns null for Err', () async {
      expect(await Future.value(const Err<int, String>('error')).ok(), isNull);
    });

    test('err() returns error for Err', () async {
      expect(
        await Future.value(const Err<int, String>('error')).err(),
        'error',
      );
    });

    test('err() returns null for Ok', () async {
      expect(await Future.value(const Ok<int, String>(42)).err(), isNull);
    });

    test('get returns value for Ok', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(await future.get(orElse: (e) => 0), 42);
    });

    test('get returns orElse result for Err', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(await future.get(orElse: (e) => e.length), 5);
    });

    test('getOrThrow returns value for Ok', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(await future.getOrThrow(), 42);
    });

    test('getOrThrow throws for Err', () {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(future.getOrThrow, throwsStateError);
    });

    test('map transforms value', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(await future.map((v) => v * 2), const Ok<int, String>(84));
    });

    test('map returns unchanged Err', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(await future.map((v) => v * 2), const Err<int, String>('error'));
    });

    test('mapError transforms error', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(await future.mapError((e) => e.length), const Err<int, int>(5));
    });

    test('mapError returns unchanged Ok', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(await future.mapError((e) => e.length), const Ok<int, int>(42));
    });

    test('fold transforms Ok value', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      final result = await future.fold(
        (v) => 'ok: $v',
        orElse: (e) => 'error: $e',
      );
      expect(result, 'ok: 42');
    });

    test('fold returns orElse for Err', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      final result = await future.fold(
        (v) => 'ok: $v',
        orElse: (e) => 'error: $e',
      );
      expect(result, 'error: error');
    });

    test('flatMap transforms value', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(
        await future.flatMap((v) => Ok<String, String>(v.toString())),
        const Ok<String, String>('42'),
      );
    });

    test('flatMap returns unchanged Err', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(
        await future.flatMap((v) => Ok<String, String>(v.toString())),
        const Err<String, String>('error'),
      );
    });

    test('recover transforms error', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(
        await future.recover((e) => Ok<int, Never>(e.length)),
        const Ok<int, Never>(5),
      );
    });

    test('recover returns unchanged Ok', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(
        await future.recover((e) => const Ok<int, Never>(0)),
        const Ok<int, Never>(42),
      );
    });

    test('tap executes action for Ok', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      var tapped = 0;
      await future.tap((v) => tapped = v);
      expect(tapped, 42);
    });

    test('tap does not execute action for Err', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      var tapped = false;
      await future.tap((v) => tapped = true);
      expect(tapped, isFalse);
    });

    test('tapError executes action for Err', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      var tapped = '';
      await future.tapError((e) => tapped = e);
      expect(tapped, 'error');
    });

    test('tapError does not execute action for Ok', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      var tapped = false;
      await future.tapError((e) => tapped = true);
      expect(tapped, isFalse);
    });

    test('castOk casts value', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(await future.castOk<num>(), const Ok<num, String>(42));
    });

    test('castErr casts error', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(await future.castErr<Object>(), const Err<int, Object>('error'));
    });

    test('cast casts both value and error types for Ok', () async {
      final future = Future<Ok<int, String>>.value(const Ok<int, String>(42));
      expect(await future.cast<num, Object>(), const Ok<num, Object>(42));
    });

    test('cast casts both value and error types for Err', () async {
      final future = Future<Err<int, String>>.value(const Err<int, String>('error'));
      expect(await future.cast<num, Object>(), const Err<num, Object>('error'));
    });
  });

  group('ResultToAsyncExtension', () {
    test('async converts Ok to FutureResult', () async {
      const result = Ok<int, String>(42);
      final futureResult = result.async;
      expect(await futureResult, const Ok<int, String>(42));
    });

    test('async converts Err to FutureResult', () async {
      const result = Err<int, String>('error');
      final futureResult = result.async;
      expect(await futureResult, const Err<int, String>('error'));
    });
  });
}
