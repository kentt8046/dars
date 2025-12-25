import 'result.dart';

/// A [Result] with `void` as the success type.
///
/// Useful for operations that can fail but don't return a value.
///
/// Example:
/// ```dart
/// VoidResult<String> saveToFile(String path, String content) {
///   try {
///     File(path).writeAsStringSync(content);
///     return Ok(null);
///   } catch (e) {
///     return Err('Failed to save: $e');
///   }
/// }
/// ```
typedef VoidResult<E extends Object> = Result<void, E>;

/// Creates an [Ok] result with `null` as the success value.
Ok<void, E> ok<E extends Object>() => const Ok(null);
