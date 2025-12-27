# **dars_test**

[![pub package](https://img.shields.io/pub/v/dars_test.svg)](https://pub.dev/packages/dars_test)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![codecov](https://codecov.io/gh/kentt8046/dars/branch/main/graph/badge.svg?flag=dars_test)](https://codecov.io/gh/kentt8046/dars)

Testing utilities and matchers for the `dars` package.

**English** | [日本語](doc/README_ja.md)

## Features

- **Smart Result Matchers** - `isOk` and `isErr` that automatically handle values, matchers, and predicates.
- **Type-safe Verification** - `isOk<T>()` and `isErr<E>()` for strict type checking.
- **Rich Error Messages** - Detailed mismatch descriptions including type information.
- **Mockito Integration** - `whenResult` and `whenFutureResult` helpers for stubbing `Result`-returning methods.

## Installation

```yaml
dev_dependencies:
  dars_test:
```

## Usage

```dart
import 'package:dars/dars.dart';
import 'package:dars_test/dars_test.dart';
import 'package:test/test.dart';

void main() {
  test('example', () {
    final Result<int, String> result = Ok(42);

    // Basic variant check
    expect(result, isOk);

    // Value check
    expect(result, isOk(42));

    // Matcher check
    expect(result, isOk(greaterThan(0)));

    // Predicate check
    expect(result, isOk((v) => v % 2 == 0));

    // Type-safe check
    expect(result, isOk<int>(42));
  });
}
```

## Example

See [example/example.dart](example/example.dart) for more detailed examples.

## Mockito Integration

`dars_test` provides utilities for stubbing methods that return `Result` types with Mockito.

### Installation

Add `mockito` to your dev dependencies:

```yaml
dev_dependencies:
  dars_test:
  mockito:
  build_runner:  # Required for @GenerateMocks
```

### Usage

```dart
import 'package:dars/dars.dart';
import 'package:dars_test/mockito.dart';
import 'package:mockito/mockito.dart';

// For synchronous Result-returning methods
whenResult(
  () => mock.fetchData('123'),
  dummy: Ok('dummy'),
).thenReturn(Ok('Actual data'));

// For async Future<Result>-returning methods
whenFutureResult(
  () => mock.fetchDataAsync('456'),
  dummy: Ok('dummy'),
).thenAnswer((_) async => Ok('Actual async data'));
```

See [example/mockito_example.dart](example/mockito_example.dart) for a complete example.

## Error Messages

When a test fails, `dars_test` provides detailed information:

- **Variant Mismatch**: `Expected: Ok but was: Err('timeout')`
- **Type Mismatch**: `Expected: Ok<int> but was: Ok<String>('42')`
- **Value Mismatch**: `Expected: Ok(42) but was: Ok(0)`

## License

BSD 3-Clause License
