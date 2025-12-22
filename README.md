# result_x

[![pub package](https://img.shields.io/pub/v/result_x.svg)](https://pub.dev/packages/result_x)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![codecov](https://codecov.io/gh/kentt8046/result_x/branch/main/graph/badge.svg)](https://codecov.io/gh/kentt8046/result_x)

**English** | [日本語](https://github.com/kentt8046/result_x/blob/main/docs/README_ja.md)

A Dart-idiomatic Result type package with first-class developer experience.

> ⚠️ **Currently under development.** Bugs and breaking changes may occur.

## Features

- **Dart-idiomatic Result type** - Intuitive API designed for Dart developers
- **Pattern matching support** - Leverage Dart 3's powerful pattern matching
- **Early return with $ syntax** - Inspired by [rust](https://pub.dev/packages/rust) package - thank you!
- **Full async support** - `FutureResult` with all methods available
- **Nullable-to-Result conversion** - Easy `T?.toResult()` extension
- **Type-safe API** - Compile-time safety for error handling

## Installation

```yaml
dependencies:
  result_x: ^0.1.0
```

Or run:

```bash
dart pub add result_x
```

## Quick Start

```dart
import 'package:result_x/result_x.dart';

Result<int, String> divide(int a, int b) {
  if (b == 0) return Err('Division by zero');
  return Ok(a ~/ b);
}

void main() {
  final result = divide(10, 2);

  // Pattern matching
  switch (result) {
    case Ok(:final value): print('Result: $value');
    case Err(:final error): print('Error: $error');
  }
}
```

## Core Concepts

### Result Type

`Result<T, E>` is a sealed class that represents either success (`Ok<T, E>`) or failure (`Err<T, E>`).

```dart
const ok = Ok<int, String>(42);
const err = Err<int, String>('Something went wrong');

print(ok.isOk);   // true
print(err.isErr); // true
```

### Pattern Matching

Use Dart 3's pattern matching for clean and exhaustive handling:

```dart
final message = switch (result) {
  Ok(:final value) => 'Got value: $value',
  Err(:final error) => 'Got error: $error',
};
```

### Early Return with $ Syntax

Simplify error handling with the `$` syntax for early returns:

```dart
Result<int, String> calculate(int a, int b, int c) {
  return Result(($) {
    final ab = divide(a, b)[$];  // Returns early if Err
    final cd = divide(c, 1)[$];
    return ab + cd;
  }, onError: (e, s) => Err('Unexpected: $e'));
}
```

### Async Support

Full async support with `Result.async` and `FutureResult`:

```dart
Future<Result<String, String>> fetchUser(int id) {
  return Result.async(($) async {
    if (id <= 0) {
      Err<String, String>('Invalid ID')[$];
    }
    await Future.delayed(Duration(milliseconds: 100));
    return 'User #$id';
  }, onError: (e, s) => Err('Unexpected: $e'));
}
```

## API Reference

### Method Comparison (Rust / Swift)

| Description | result_x | Rust | Swift |
|-------------|----------|------|-------|
| **Checking** |
| Is success | `isOk` | `is_ok()` | - |
| Is error | `isErr` | `is_err()` | - |
| Success with condition | `isOkWhere(fn)` | `is_ok_and(fn)` | - |
| Error with condition | `isErrWhere(fn)` | `is_err_and(fn)` | - |
| **Optional Conversion** |
| Get nullable success | `ok()` | `ok()` | - |
| Get nullable error | `err()` | `err()` | - |
| **Value Extraction** |
| Get with default | `get(orElse: fn)` | `unwrap_or_else(fn)` | - |
| Get or throw | `getOrThrow([msg])` | `unwrap()` / `expect()` | `get() throws` |
| **Transformation** |
| Map success | `map(fn)` | `map(fn)` | `map(_:)` |
| Map error | `mapError(fn)` | `map_err(fn)` | `mapError(_:)` |
| Fold with default | `fold(fn, orElse: fn)` | `map_or_else(d, fn)` | - |
| **Chaining** |
| Chain Result | `flatMap(fn)` | `and_then(fn)` | `flatMap(_:)` |
| Recover from error | `recover(fn)` | `or_else(fn)` | `flatMapError(_:)` |
| **Debugging** |
| Inspect success | `tap(fn)` | `inspect(fn)` | - |
| Inspect error | `tapError(fn)` | `inspect_err(fn)` | - |
| **Type Casting** |
| Cast success type | `castOk<U>()` | - | - |
| Cast error type | `castErr<F>()` | - | - |
| Cast both types | `cast<U, F>()` | - | - |

### Type Aliases

```dart
typedef FutureResult<T, E> = Future<Result<T, E>>;
typedef VoidResult<E> = Result<void, E>;
```

### Nullable Extension

```dart
final String? name = getUserName();
final result = name.toResult(orElse: () => 'Name not found');
```

## Complete Example

See [example/example.dart](packages/result_x/example/example.dart) for a comprehensive demonstration.

## Additional Information

- 📖 [日本語ドキュメント](docs/README_ja.md)
- 📋 [Design Document](docs/design_doc.md)
- 🐛 [Issue Tracker](https://github.com/kentt8046/result_x/issues)

## License

BSD 3-Clause License - see [LICENSE](LICENSE) for details.
