## 0.3.0

### dars

#### Documentation

- Updated examples for direct early returns and async chaining

### dars_test

#### New Features

- **Mockito integration utilities** for stubbing methods returning `Result` types
  - `whenResult()`: Wrapper for `when()` that simplifies stubbing methods returning `Result<T, E>`
  - `whenFutureResult()`: Wrapper for async methods returning `Future<Result<T, E>>`
  - Automatic dummy value registration via `provideDummy`
  - Detailed error messages for type mismatch debugging

## 0.2.0

### dars

#### Breaking Changes

- **BREAKING**: `Result` factory and `Result.async` now require callback to return `Result<T, E>` instead of `T`
  - Before: `Result(($) { return value; }, ...)`
  - After: `Result(($) { return Ok(value); }, ...)`
  - This allows returning `Ok` or `Err` explicitly from within the callback

### dars_test

- Initial release of `dars_test` package
- `isOk` and `isErr` matchers for Result type testing
  - Basic variant check: `isOk`, `isErr`
  - Value matching: `isOk(42)`, `isErr('error')`
  - Matcher support: `isOk(greaterThan(0))`, `isErr(contains('fail'))`
  - Type-safe checks: `isOk<int>()`, `isErr<String>()`
- Detailed mismatch descriptions for debugging

## 0.1.0

### dars

- Initial release with core Result type functionality
- `Result<T, E>` sealed class (`Ok`, `Err`)
- Early return `$` syntax (sync and async)
- Nullable extension and Future extensions
