import 'package:dars/dars.dart';
import 'package:dars_test/matcher.dart';
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

    test('matches Err with matcher', () {
      expect(const Err<int, String>('error'), isErr<dynamic>(contains('err')));
    });

    test('matches Err<E> with type', () {
      expect(const Err<int, String>('error'), isErr<String>());
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
  });
}
