import 'result.dart';

/// Extension methods for nullable types to convert to [Result].
extension NullableToResult<T> on T? {
  /// Converts a nullable value to a [Result].
  ///
  /// Returns [Ok] if the value is non-null, otherwise [Err] with [orElse].
  ///
  /// Example:
  /// ```dart
  /// final String? name = getUserName();
  /// final Result<String, String> result = name.toResult(
  ///   orElse: () => 'Name not found',
  /// );
  /// ```
  Result<T, E> toResult<E extends Object>({required E Function() orElse}) {
    final value = this;
    if (value != null) {
      return Ok(value);
    }
    return Err(orElse());
  }
}
