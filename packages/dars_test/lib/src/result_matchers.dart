import 'package:dars/dars.dart';
import 'package:matcher/matcher.dart';

/// A matcher that matches a [Result] that is [Ok].
///
/// Can be used as a constant:
/// ```dart
/// expect(result, isOk);
/// ```
///
/// Or with a value, matcher, or predicate:
/// ```dart
/// expect(result, isOk(42));
/// expect(result, isOk(greaterThan(0)));
/// expect(result, isOk((v) => v.isNotEmpty));
/// ```
///
/// Or with a type check:
/// ```dart
/// expect(result, isOk<int>(42));
/// ```
const isOk = _ResultRootMatcher(isOk: true);

/// A matcher that matches a [Result] that is [Err].
///
/// Can be used as a constant:
/// ```dart
/// expect(result, isErr);
/// ```
///
/// Or with a value, matcher, or predicate:
/// ```dart
/// expect(result, isErr('error'));
/// expect(result, isErr(contains('not found')));
/// expect(result, isErr((e) => e is MyException));
/// ```
///
/// Or with a type check:
/// ```dart
/// expect(result, isErr<String>('error'));
/// ```
const isErr = _ResultRootMatcher(isOk: false);

const _noExpect = Object();

class _ResultRootMatcher extends _ResultVariantMatcher<dynamic> {
  const _ResultRootMatcher({required super.isOk}) : super();

  /// Returns a matcher that matches the [Result] variant and its value/error.
  _ResultVariantMatcher<T> call<T>([Object? valueOrMatcher = _noExpect]) {
    return _ResultVariantMatcher<T>(
      isOk: _isOkVariant,
      expect: valueOrMatcher == _noExpect ? null : valueOrMatcher,
      hasExpect: valueOrMatcher != _noExpect,
    );
  }
}

class _ResultVariantMatcher<V> extends Matcher {
  const _ResultVariantMatcher({
    required bool isOk,
    Object? expect,
    bool hasExpect = false,
  })  : _isOkVariant = isOk,
        _expect = expect,
        _hasExpect = hasExpect;
  final bool _isOkVariant;
  final Object? _expect;
  final bool _hasExpect;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Result) return false;

    if (_isOkVariant) {
      if (!item.isOk) return false;
      if (!_hasExpect && V == dynamic) return true;
      final value = item.ok();
      return _matchesValue(value, matchState);
    } else {
      if (!item.isErr) return false;
      if (!_hasExpect && V == dynamic) return true;
      final error = item.err();
      return _matchesValue(error, matchState);
    }
  }

  bool _matchesValue(Object? actual, Map<dynamic, dynamic> matchState) {
    // Type check
    if (V != dynamic && actual is! V) {
      matchState['typeMismatch'] = true;
      matchState['actualType'] = actual.runtimeType;
      return false;
    }

    if (!_hasExpect) return true;

    final expected = _expect;
    if (expected is Matcher) {
      if (expected.matches(actual, matchState)) return true;
      return false;
    } else if (expected is Function) {
      try {
        // Dynamic call is necessary to support arbitrary predicate functions.
        // ignore: avoid_dynamic_calls
        if (expected(actual) == true) return true;
        matchState['predicateMismatch'] = true;
        return false;
      } catch (_) {
        return false;
      }
    } else {
      final matcher = equals(expected);
      return matcher.matches(actual, matchState);
    }
  }

  @override
  Description describe(Description description) {
    final variantName = _isOkVariant ? 'Ok' : 'Err';
    description.add(variantName);

    if (V != dynamic) {
      description.add('<$V>');
    }

    if (_hasExpect) {
      description.add('(');
      final expected = _expect;
      if (expected is Matcher) {
        expected.describe(description);
      } else if (expected is Function) {
        description.add('matches predicate');
      } else {
        description.addDescriptionOf(expected);
      }
      description.add(')');
    }
    return description;
  }

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is! Result) {
      return mismatchDescription.add('is not a Result');
    }

    final actualVariant = item.isOk ? 'Ok' : 'Err';
    final actualValue = item.isOk ? item.ok() : item.err();

    if (item.isOk != _isOkVariant) {
      mismatchDescription.add('was: ').add(actualVariant).add('(').addDescriptionOf(actualValue).add(')');
      return mismatchDescription;
    }

    // Same variant, but mismatch in value/type
    if (matchState['typeMismatch'] == true) {
      final actualType = matchState['actualType'];
      mismatchDescription
          .add('was: ')
          .add(actualVariant)
          .add('<$actualType>')
          .add('(')
          .addDescriptionOf(actualValue)
          .add(')');
      return mismatchDescription;
    }

    mismatchDescription.add('was: ').add(actualVariant).add('(').addDescriptionOf(actualValue).add(')');

    if (matchState['predicateMismatch'] == true) {
      mismatchDescription.add(' which does not match predicate');
    } else if (_hasExpect && _expect is Matcher) {
      final matcher = _expect;
      mismatchDescription.add(' which ');
      matcher.describeMismatch(actualValue, mismatchDescription, matchState, verbose);
    }

    return mismatchDescription;
  }
}
