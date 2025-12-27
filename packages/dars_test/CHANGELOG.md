## 0.3.0

### New Features

- **Mockito integration utilities** for stubbing methods returning `Result` types
  - `whenResult()`: Wrapper for `when()` that simplifies stubbing methods returning `Result<T, E>`
  - `whenFutureResult()`: Wrapper for async methods returning `Future<Result<T, E>>`
  - Automatic dummy value registration via `provideDummy`
  - Detailed error messages for type mismatch debugging

## 0.2.0

- Initial release of `dars_test` package
- `isOk` and `isErr` matchers for Result type testing
  - Basic variant check: `isOk`, `isErr`
  - Value matching: `isOk(42)`, `isErr('error')`
  - Matcher support: `isOk(greaterThan(0))`, `isErr(contains('fail'))`
  - Type-safe checks: `isOk<int>()`, `isErr<String>()`
- Detailed mismatch descriptions for debugging
