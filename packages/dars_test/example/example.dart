import 'package:dars/dars.dart';
import 'package:dars_test/dars_test.dart';
import 'package:test/test.dart';

void main() {
  group('Example usage of dars_test matchers', () {
    test('Basic variant matching', () {
      const Result<int, String> okResult = Ok(42);
      const Result<int, String> errResult = Err('failure');

      // Use isOk and isErr as simple constants
      expect(okResult, isOk);
      expect(errResult, isErr);
    });

    test('Value and Matcher matching', () {
      const Result<String, Exception> result = Ok('Hello, World!');

      // Match the exact value
      expect(result, isOk<String>('Hello, World!'));

      // Use standard matchers within isOk
      expect(result, isOk<String>(contains('World')));
      expect(result, isOk<String>(startsWith('Hello')));
    });

    test('Type-safe matching', () {
      const Result<dynamic, dynamic> result = Ok(100);

      // Verify both the variant and the type of the contained value
      expect(result, isOk<int>());
      expect(result, isOk<int>(100));
      expect(result, isOk<int>(greaterThan(50)));
    });

    test('Predicate matching', () {
      const Result<List<int>, String> result = Ok([1, 2, 3]);

      // Use a custom predicate function for complex validation
      expect(result, isOk<List<int>>((List<int> list) => list.length == 3));
      expect(result, isOk<List<int>>((List<int> list) => list.contains(2)));
    });

    test('Error matching', () {
      const Result<int, String> result = Err('Invalid input');

      // Match exact error value
      expect(result, isErr<String>('Invalid input'));

      // Match error with matchers
      expect(result, isErr<String>(startsWith('Invalid')));
    });
  });
}
