import 'package:dars/dars.dart';
import 'package:dars_test/dars_test.dart';
import 'package:test/test.dart';

void main() {
  group('isOk', () {
    test('matches Ok', () {
      expect(const Ok<int, String>(42), isOk);
    });

    test('does not match Err', () {
      expect(const Err<int, String>('error'), isNot(isOk));
    });

    test('matches Ok with value', () {
      expect(const Ok<int, String>(42), isOk<dynamic>(42));
    });

    test('does not match Ok with wrong value', () {
      expect(const Ok<int, String>(42), isNot(isOk<dynamic>(0)));
    });

    test('matches Ok with matcher', () {
      expect(const Ok<int, String>(42), isOk<dynamic>(greaterThan(0)));
    });

    test('matches Ok with predicate', () {
      expect(const Ok<int, String>(42), isOk<int>((int v) => v.isEven));
    });

    test('matches Ok<T> with type', () {
      expect(const Ok<int, String>(42), isOk<int>());
    });

    test('does not match Ok<T> with wrong type', () {
      expect(const Ok<Object, String>(42), isNot(isOk<String>()));
    });

    test('matches Ok<T> with type and value', () {
      expect(const Ok<int, String>(42), isOk<int>(42));
    });
  });

  group('isErr', () {
    test('matches Err', () {
      expect(const Err<int, String>('error'), isErr);
    });

    test('does not match Ok', () {
      expect(const Ok<int, String>(42), isNot(isErr));
    });

    test('matches Err with value', () {
      expect(const Err<int, String>('error'), isErr<dynamic>('error'));
    });

    test('does not match Err with wrong value', () {
      expect(const Err<int, String>('error'), isNot(isErr<dynamic>('other')));
    });

    test('matches Err with matcher', () {
      expect(const Err<int, String>('error'), isErr<dynamic>(contains('err')));
    });

    test('does not match Err with non-matching matcher', () {
      expect(const Err<int, String>('error'), isNot(isErr<dynamic>(contains('success'))));
    });

    test('matches Err<E> with type', () {
      expect(const Err<int, String>('error'), isErr<String>());
    });

    test('does not match Err<E> with wrong type', () {
      expect(const Err<int, Object>('error'), isNot(isErr<int>()));
    });

    test('matches Err with predicate', () {
      expect(const Err<int, String>('error'), isErr<String>((String e) => e.startsWith('err')));
    });

    test('does not match Err with failing predicate', () {
      expect(const Err<int, String>('error'), isNot(isErr<String>((String e) => e.isEmpty)));
    });
  });

  group('Error messages', () {
    test('variant mismatch', () {
      const result = Err<int, String>('error');
      const matcher = isOk;
      final description = StringDescription();
      matcher.describeMismatch(result, description, <dynamic, dynamic>{}, false);
      expect(description.toString(), contains("was: Err('error')"));
    });

    test('type mismatch', () {
      const result = Ok<dynamic, String>('42');
      final matcher = isOk<int>();
      final matchState = <dynamic, dynamic>{};
      matcher.matches(result, matchState);
      final description = StringDescription();
      matcher.describeMismatch(result, description, matchState, false);
      expect(description.toString(), contains("was: Ok<String>('42')"));
    });

    test('value mismatch', () {
      const result = Ok<int, String>(42);
      final matcher = isOk<dynamic>(0);
      final matchState = <dynamic, dynamic>{};
      matcher.matches(result, matchState);
      final description = StringDescription();
      matcher.describeMismatch(result, description, matchState, false);
      // Result of addDescriptionOf(42) might be <42> depending on environment/type
      expect(description.toString(), anyOf(contains('was: Ok(42)'), contains('was: Ok(<42>)')));
    });

    test('predicate mismatch', () {
      const result = Ok<int, String>(42);
      final matcher = isOk<int>((int v) => v == 0);
      final matchState = <dynamic, dynamic>{};
      matcher.matches(result, matchState);
      final description = StringDescription();
      matcher.describeMismatch(result, description, matchState, false);
      expect(description.toString(), contains('which does not match predicate'));
    });

    test('matcher mismatch', () {
      const result = Ok<int, String>(42);
      final matcher = isOk<dynamic>(greaterThan(100));
      final matchState = <dynamic, dynamic>{};
      matcher.matches(result, matchState);
      final description = StringDescription();
      matcher.describeMismatch(result, description, matchState, false);
      expect(description.toString(), contains('which'));
    });

    test('not a Result', () {
      const matcher = isOk;
      final description = StringDescription();
      matcher.describeMismatch('not a result', description, <dynamic, dynamic>{}, false);
      expect(description.toString(), equals('is not a Result'));
    });
  });

  group('Edge cases', () {
    test('predicate that throws exception returns false', () {
      const result = Ok<int, String>(42);
      final matcher = isOk<int>((int v) => throw Exception('test'));
      expect(result, isNot(matcher));
    });

    test('isErr predicate that throws exception returns false', () {
      const result = Err<int, String>('error');
      final matcher = isErr<String>((String e) => throw Exception('test'));
      expect(result, isNot(matcher));
    });
  });

  group('describe', () {
    test('describe Ok without type or expectation', () {
      final description = StringDescription();
      isOk.describe(description);
      expect(description.toString(), equals('Ok'));
    });

    test('describe Err without type or expectation', () {
      final description = StringDescription();
      isErr.describe(description);
      expect(description.toString(), equals('Err'));
    });

    test('describe Ok with type', () {
      final description = StringDescription();
      isOk<int>().describe(description);
      expect(description.toString(), equals('Ok<int>'));
    });

    test('describe Err with type', () {
      final description = StringDescription();
      isErr<String>().describe(description);
      expect(description.toString(), equals('Err<String>'));
    });

    test('describe Ok with value expectation', () {
      final description = StringDescription();
      isOk<dynamic>(42).describe(description);
      expect(description.toString(), contains('Ok('));
      expect(description.toString(), contains('42'));
    });

    test('describe Ok with matcher expectation', () {
      final description = StringDescription();
      isOk<dynamic>(greaterThan(0)).describe(description);
      expect(description.toString(), contains('Ok('));
      expect(description.toString(), contains('a value greater than'));
    });

    test('describe Ok with predicate expectation', () {
      final description = StringDescription();
      isOk<int>((int v) => v > 0).describe(description);
      expect(description.toString(), equals('Ok<int>(matches predicate)'));
    });

    test('describe Err with type and value', () {
      final description = StringDescription();
      isErr<String>('error').describe(description);
      expect(description.toString(), contains('Err<String>('));
      expect(description.toString(), contains('error'));
    });
  });
}
