/// @docImport 'package:dars/dars.dart';
/// @docImport 'src/result_matchers.dart';

/// Testing utilities and matchers for the [dars](https://pub.dev/packages/dars) package.
///
/// This library provides custom matchers for testing [Result] types:
///
/// - [isOk] / [isErr]: Basic variant checks
/// - `isOk(value)` / `isErr(value)`: Value matching
/// - `isOk(matcher)` / `isErr(matcher)`: Matcher support
/// - `isOk<T>()` / `isErr<E>()`: Type-safe checks
///
/// Example:
/// ```dart
/// import 'package:dars/dars.dart';
/// import 'package:dars_test/dars_test.dart';
/// import 'package:test/test.dart';
///
/// void main() {
///   test('Result matchers', () {
///     expect(Ok(42), isOk);
///     expect(Ok(42), isOk(42));
///     expect(Err('error'), isErr(contains('err')));
///   });
/// }
/// ```
library;

export 'src/result_matchers.dart';
