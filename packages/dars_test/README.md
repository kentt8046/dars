# **dars_test**

[![pub package](https://img.shields.io/pub/v/dars_test.svg)](https://pub.dev/packages/dars_test)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Testing utilities and matchers for the `dars` package.

**English** | [日本語](https://github.com/kentt8046/dars/blob/main/packages/dars_test/doc/README_ja.md)

## Features

- **Smart Result Matchers** - `isOk` and `isErr` that automatically handle values, matchers, and predicates.
- **Type-safe Verification** - `isOk<T>()` and `isErr<E>()` for strict type checking.
- **Rich Error Messages** - Detailed mismatch descriptions including type information.

## Installation

```yaml
dev_dependencies:
  dars_test:
```

## Usage

```dart
import 'package:dars/dars.dart';
import 'package:dars_test/matcher.dart';
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

See [example/example.dart](https://github.com/kentt8046/dars/blob/main/packages/dars_test/example/example.dart) for more detailed examples.

## Error Messages

When a test fails, `dars_test` provides detailed information:

- **Variant Mismatch**: `Expected: Ok but was: Err('timeout')`
- **Type Mismatch**: `Expected: Ok<int> but was: Ok<String>('42')`
- **Value Mismatch**: `Expected: Ok(42) but was: Ok(0)`

## License

BSD 3-Clause License
