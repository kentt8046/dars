import 'package:dars/dars.dart';
import 'package:test/test.dart';

void main() {
  group('NullableToResult', () {
    test('toResult returns Ok for non-null value', () {
      const value = 'hello';
      final result = value.toResult(orElse: () => 'error');
      expect(result, const Ok<String, String>('hello'));
    });

    test('toResult returns Err for null value', () {
      const String? value = null;
      final result = value.toResult(orElse: () => 'value was null');
      expect(result, const Err<String, String>('value was null'));
    });

    test('toResult works with different error types', () {
      const int? value = null;
      final result = value.toResult<int>(orElse: () => 404);
      expect(result, const Err<int, int>(404));
    });

    test('toResult orElse is lazy', () {
      var called = false;
      const value = 'present';
      value.toResult(
        orElse: () {
          called = true;
          return 'error';
        },
      );
      expect(called, isFalse);
    });

    test('toResult orElse is called for null', () {
      var called = false;
      const String? value = null;
      value.toResult(
        orElse: () {
          called = true;
          return 'error';
        },
      );
      expect(called, isTrue);
    });
  });
}
