// Early return pattern `Err(...)[$]` is intentional and triggers statements lint.
// ignore_for_file: unnecessary_statements

import 'package:dars/dars.dart';
import 'package:test/test.dart';

void main() {
  group('Ok', () {
    test('isOk returns true', () {
      const result = Ok<int, String>(42);
      expect(result.isOk, isTrue);
    });

    test('isErr returns false', () {
      const result = Ok<int, String>(42);
      expect(result.isErr, isFalse);
    });

    test('isOkWhere returns true when predicate matches', () {
      const result = Ok<int, String>(42);
      expect(result.isOkWhere((v) => v > 40), isTrue);
    });

    test('isOkWhere returns false when predicate does not match', () {
      const result = Ok<int, String>(42);
      expect(result.isOkWhere((v) => v < 40), isFalse);
    });

    test('isErrWhere returns false', () {
      const result = Ok<int, String>(42);
      expect(result.isErrWhere((e) => true), isFalse);
    });

    test('ok() returns value', () {
      const result = Ok<int, String>(42);
      expect(result.ok(), 42);
    });

    test('err() returns null', () {
      const result = Ok<int, String>(42);
      expect(result.err(), isNull);
    });

    test('get returns value with orElse', () {
      const result = Ok<int, String>(42);
      expect(result.get(orElse: (e) => 0), 42);
    });

    test('getOrThrow returns value', () {
      const result = Ok<int, String>(42);
      expect(result.getOrThrow(), 42);
    });

    test('getOrThrow with message returns value', () {
      const result = Ok<int, String>(42);
      expect(result.getOrThrow('Custom message'), 42);
    });

    test('map transforms value', () {
      const result = Ok<int, String>(42);
      expect(result.map((v) => v * 2), const Ok<int, String>(84));
    });

    test('mapError returns unchanged Ok', () {
      const result = Ok<int, String>(42);
      expect(result.mapError((e) => e.length), const Ok<int, int>(42));
    });

    test('fold transforms value', () {
      const result = Ok<int, String>(42);
      expect(
        result.fold((v) => v.toString(), orElse: (e) => 'error'),
        '42',
      );
    });

    test('flatMap transforms value', () {
      const result = Ok<int, String>(42);
      expect(
        result.flatMap((v) => Ok<String, String>(v.toString())),
        const Ok<String, String>('42'),
      );
    });

    test('flatMap can return Err', () {
      const result = Ok<int, String>(42);
      expect(
        result.flatMap<String>((v) => const Err('failed')),
        const Err<String, String>('failed'),
      );
    });

    test('recover returns unchanged Ok', () {
      const result = Ok<int, String>(42);
      expect(
        result.recover((e) => const Ok<int, Never>(0)),
        const Ok<int, Never>(42),
      );
    });

    test('tap executes action', () {
      const result = Ok<int, String>(42);
      var tapped = 0;
      result.tap((v) => tapped = v);
      expect(tapped, 42);
    });

    test('tap returns same result', () {
      const result = Ok<int, String>(42);
      expect(result.tap((v) {}), result);
    });

    test('tapError does not execute action', () {
      const result = Ok<int, String>(42);
      var tapped = false;
      result.tapError((e) => tapped = true);
      expect(tapped, isFalse);
    });

    test('tapError returns same result', () {
      const result = Ok<int, String>(42);
      expect(result.tapError((e) {}), result);
    });

    test('castOk casts value', () {
      const result = Ok<int, String>(42);
      expect(result.castOk<num>(), const Ok<num, String>(42));
    });

    test('castErr returns unchanged Ok', () {
      const result = Ok<int, String>(42);
      expect(result.castErr<Object>(), const Ok<int, Object>(42));
    });

    test('cast casts value', () {
      const result = Ok<int, String>(42);
      expect(result.cast<num, Object>(), const Ok<num, Object>(42));
    });

    test('equality works', () {
      expect(const Ok<int, String>(42), const Ok<int, String>(42));
      expect(const Ok<int, String>(42), isNot(const Ok<int, String>(43)));
    });

    test('hashCode is based on value', () {
      expect(const Ok<int, String>(42).hashCode, 42.hashCode);
    });

    test('toString returns Ok(value)', () {
      expect(const Ok<int, String>(42).toString(), 'Ok(42)');
    });
  });

  group('Err', () {
    test('isOk returns false', () {
      const result = Err<int, String>('error');
      expect(result.isOk, isFalse);
    });

    test('isErr returns true', () {
      const result = Err<int, String>('error');
      expect(result.isErr, isTrue);
    });

    test('isOkWhere returns false', () {
      const result = Err<int, String>('error');
      expect(result.isOkWhere((v) => true), isFalse);
    });

    test('isErrWhere returns true when predicate matches', () {
      const result = Err<int, String>('error');
      expect(result.isErrWhere((e) => e.length > 3), isTrue);
    });

    test('isErrWhere returns false when predicate does not match', () {
      const result = Err<int, String>('err');
      expect(result.isErrWhere((e) => e.length > 5), isFalse);
    });

    test('ok() returns null', () {
      const result = Err<int, String>('error');
      expect(result.ok(), isNull);
    });

    test('err() returns error', () {
      const result = Err<int, String>('error');
      expect(result.err(), 'error');
    });

    test('get returns orElse result', () {
      const result = Err<int, String>('error');
      expect(result.get(orElse: (e) => e.length), 5);
    });

    test('getOrThrow throws', () {
      const result = Err<int, String>('error');
      expect(() => result.getOrThrow(), throwsStateError);
    });

    test('getOrThrow with message includes message', () {
      const result = Err<int, String>('error');
      expect(
        () => result.getOrThrow('Custom'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Custom'),
          ),
        ),
      );
    });

    test('map returns unchanged Err', () {
      const result = Err<int, String>('error');
      expect(result.map((v) => v * 2), const Err<int, String>('error'));
    });

    test('mapError transforms error', () {
      const result = Err<int, String>('error');
      expect(result.mapError((e) => e.length), const Err<int, int>(5));
    });

    test('fold returns orElse result', () {
      const result = Err<int, String>('error');
      expect(
        result.fold((v) => v.toString(), orElse: (e) => 'got: $e'),
        'got: error',
      );
    });

    test('flatMap returns unchanged Err', () {
      const result = Err<int, String>('error');
      expect(
        result.flatMap((v) => Ok<String, String>(v.toString())),
        const Err<String, String>('error'),
      );
    });

    test('recover transforms error', () {
      const result = Err<int, String>('error');
      expect(
        result.recover((e) => Ok<int, Never>(e.length)),
        const Ok<int, Never>(5),
      );
    });

    test('recover can return new Err', () {
      const result = Err<int, String>('error');
      expect(
        result.recover<int>((e) => Err(e.length)),
        const Err<int, int>(5),
      );
    });

    test('tap does not execute action', () {
      const result = Err<int, String>('error');
      var tapped = false;
      result.tap((v) => tapped = true);
      expect(tapped, isFalse);
    });

    test('tap returns same result', () {
      const result = Err<int, String>('error');
      expect(result.tap((v) {}), result);
    });

    test('tapError executes action', () {
      const result = Err<int, String>('error');
      var tapped = '';
      result.tapError((e) => tapped = e);
      expect(tapped, 'error');
    });

    test('tapError returns same result', () {
      const result = Err<int, String>('error');
      expect(result.tapError((e) {}), result);
    });

    test('castOk returns unchanged Err', () {
      const result = Err<int, String>('error');
      expect(result.castOk<num>(), const Err<num, String>('error'));
    });

    test('castErr casts error', () {
      const result = Err<int, String>('error');
      expect(result.castErr<Object>(), const Err<int, Object>('error'));
    });

    test('cast casts error', () {
      const result = Err<int, String>('error');
      expect(result.cast<num, Object>(), const Err<num, Object>('error'));
    });

    test('equality works', () {
      expect(const Err<int, String>('error'), const Err<int, String>('error'));
      expect(
        const Err<int, String>('error'),
        isNot(const Err<int, String>('other')),
      );
    });

    test('hashCode is based on error', () {
      expect(const Err<int, String>('error').hashCode, 'error'.hashCode);
    });

    test('toString returns Err(error)', () {
      expect(const Err<int, String>('error').toString(), 'Err(error)');
    });
  });

  Result<T, E> handleError<T, E extends Object>(Object e, StackTrace s) => Err(e as E);

  group('Result factory', () {
    test('returns Ok when function succeeds', () {
      final result = Result<int, String>(($) => 42, onCatch: handleError);
      expect(result, const Ok<int, String>(42));
    });

    test('returns Err on early return', () {
      final result = Result<int, String>(
        ($) {
          const Err<int, String>('error')[$];
          return 42;
        },
        onCatch: handleError,
      );
      expect(result, const Err<int, String>('error'));
    });

    test('chains multiple early returns', () {
      Result<int, String> getValue(int n) => n > 0 ? Ok(n) : const Err('negative');

      final result = Result<int, String>(
        ($) {
          final a = getValue(10)[$];
          final b = getValue(20)[$];
          return a + b;
        },
        onCatch: handleError,
      );
      expect(result, const Ok<int, String>(30));
    });

    test('early returns on first error', () {
      Result<int, String> getValue(int n) => n > 0 ? Ok(n) : Err('negative: $n');

      final result = Result<int, String>(
        ($) {
          final a = getValue(10)[$];
          final b = getValue(-5)[$];
          final c = getValue(20)[$];
          return a + b + c;
        },
        onCatch: handleError,
      );
      expect(result, const Err<int, String>('negative: -5'));
    });

    test('calls onCatch for exceptions', () {
      final result = Result<int, String>(
        ($) => throw Exception('test exception'),
        onCatch: (e, s) => Err('caught: $e'),
      );
      expect(result.isErr, isTrue);
      expect((result as Err).error, contains('caught:'));
    });

    test('rethrows Error', () {
      expect(
        () => Result<int, String>(
          ($) => throw StateError('programming error'),
          onCatch: (e, s) => const Err('should not reach'),
        ),
        throwsStateError,
      );
    });
  });

  group('Result.async', () {
    test('returns Ok when async function succeeds', () async {
      final result = await Result.async<int, String>(
        ($) async => 42,
        onCatch: handleError,
      );
      expect(result, const Ok<int, String>(42));
    });

    test('returns Err on early return', () async {
      final result = await Result.async<int, String>(
        ($) async {
          const Err<int, String>('error')[$];
          return 42;
        },
        onCatch: handleError,
      );
      expect(result, const Err<int, String>('error'));
    });

    test('works with await', () async {
      Future<Result<int, String>> asyncGetValue(int n) async => n > 0 ? Ok(n) : const Err('negative');

      final result = await Result.async<int, String>(
        ($) async {
          final a = await asyncGetValue(10)[$];
          final b = await asyncGetValue(20)[$];
          return a + b;
        },
        onCatch: handleError,
      );
      expect(result, const Ok<int, String>(30));
    });

    test('calls onCatch for exceptions', () async {
      final result = await Result.async<int, String>(
        ($) async => throw Exception('test exception'),
        onCatch: (e, s) => Err('caught: $e'),
      );
      expect(result.isErr, isTrue);
      expect((result as Err).error, contains('caught:'));
    });

    test('rethrows Error', () {
      expect(
        () => Result.async<int, String>(
          ($) async => throw StateError('programming error'),
          onCatch: (e, s) => const Err('should not reach'),
        ),
        throwsStateError,
      );
    });
  });

  group('VoidResult helpers', () {
    test('ok() returns Ok<void, E> with null value', () {
      final result = ok<String>();
      expect(result.isOk, isTrue);
      // result.ok() returns void, so we just check isOk is true
    });
  });
}
