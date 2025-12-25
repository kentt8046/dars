/// @docImport 'src/result.dart';
///
/// A Dart-idiomatic Result type package with first-class developer experience.
///
/// This library provides a [Result] type for error handling that encourages
/// explicit handling of both success and failure cases.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:dars/dars.dart';
///
/// Result<int, String> divide(int a, int b) {
///   if (b == 0) return Err('Division by zero');
///   return Ok(a ~/ b);
/// }
///
/// void main() {
///   final result = divide(10, 2);
///
///   // Pattern matching
///   switch (result) {
///     case Ok(:final value): print('Result: $value');
///     case Err(:final error): print('Error: $error');
///   }
/// }
/// ```
///
/// ## Early Return with $ Syntax
///
/// ```dart
/// Result<int, String> process() => Result(($) {
///   final a = getValueA()[$];  // Returns early if Err
///   final b = getValueB()[$];  // Returns early if Err
///   return a + b;
/// });
/// ```
library;

export 'src/future_result.dart';
export 'src/nullable_extension.dart';
export 'src/result.dart';
export 'src/void_result.dart';
