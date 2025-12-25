import 'package:dars/dars.dart';
import 'package:test/test.dart';

Result<T, E> _handleError<T, E extends Object>(Object e, StackTrace s) => Err(e as E);

void main() {
  group('Early return integration', () {
    Result<int, String> divide(int a, int b) {
      if (b == 0) return const Err('division by zero');
      return Ok(a ~/ b);
    }

    test('chains successfully', () {
      final result = Result<int, String>(
        ($) {
          final a = divide(10, 2)[$];
          final b = divide(20, 4)[$];
          return a + b;
        },
        onCatch: _handleError,
      );
      expect(result, const Ok<int, String>(10)); // 5 + 5
    });

    test('stops at first Err', () {
      final result = Result<int, String>(
        ($) {
          final a = divide(10, 0)[$]; // This should early return
          final b = divide(20, 4)[$];
          return a + b;
        },
        onCatch: _handleError,
      );
      expect(result, const Err<int, String>('division by zero'));
    });

    test('works with multiple nested Results', () {
      Result<String, String> format(int value) {
        if (value < 0) return const Err('negative value');
        return Ok('Value: $value');
      }

      final result = Result<String, String>(
        ($) {
          final num1 = divide(100, 10)[$];
          final num2 = divide(50, 5)[$];
          final formatted = format(num1 + num2)[$];
          return formatted;
        },
        onCatch: _handleError,
      );
      expect(result, const Ok<String, String>('Value: 20'));
    });

    test('async early return works', () async {
      Future<Result<int, String>> asyncDivide(int a, int b) async {
        await Future<void>.delayed(Duration.zero);
        if (b == 0) return const Err('division by zero');
        return Ok(a ~/ b);
      }

      final result = await Result.async<int, String>(
        ($) async {
          final a = await asyncDivide(10, 2)[$];
          final b = await asyncDivide(20, 4)[$];
          return a + b;
        },
        onCatch: _handleError,
      );
      expect(result, const Ok<int, String>(10));
    });

    test('async early return stops at first Err', () async {
      Future<Result<int, String>> asyncDivide(int a, int b) async {
        await Future<void>.delayed(Duration.zero);
        if (b == 0) return const Err('division by zero');
        return Ok(a ~/ b);
      }

      final result = await Result.async<int, String>(
        ($) async {
          final a = await asyncDivide(10, 2)[$];
          final b = await asyncDivide(20, 0)[$];
          return a + b;
        },
        onCatch: _handleError,
      );
      expect(result, const Err<int, String>('division by zero'));
    });

    test('can mix sync and async Results', () async {
      final result = await Result.async<int, String>(
        ($) async {
          final a = divide(10, 2)[$]; // sync
          await Future<void>.delayed(Duration.zero);
          final b = divide(20, 4)[$]; // sync
          return a + b;
        },
        onCatch: _handleError,
      );
      expect(result, const Ok<int, String>(10));
    });
  });
}
