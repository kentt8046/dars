/// @docImport 'package:dars/dars.dart';
/// @docImport 'src/mockito_helpers.dart';

/// Mockito integration utilities for testing [Result] types.
///
/// This library provides helpers for stubbing methods that return [Result]
/// or `Future<Result<T, E>>` with Mockito:
///
/// - [whenResult]: Wrapper for `when()` that handles [Result] return types
/// - [whenFutureResult]: Wrapper for `when()` that handles `Future<Result>` return types
///
/// These helpers automatically register dummy values via `provideDummy` and
/// provide detailed error messages for type mismatch debugging.
///
/// **Note**: This library requires `mockito` as a dependency in your project.
///
/// Example:
/// ```dart
/// import 'package:dars/dars.dart';
/// import 'package:dars_test/mockito.dart';
/// import 'package:mockito/mockito.dart';
///
/// // With @GenerateMocks
/// whenResult(() => mock.getUser(any), dummy: Ok(User.empty()))
///   .thenReturn(Ok(actualUser));
///
/// whenFutureResult(() => mock.fetchData(), dummy: Ok(''))
///   .thenAnswer((_) async => Ok('data'));
/// ```
library;

export 'src/mockito_helpers.dart';
