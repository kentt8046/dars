// This example uses print statements to demonstrate Result usage.
// The early return pattern with `[$]` is demonstrated.
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:dars/dars.dart';

/// Simple example demonstrating basic Result usage.
void main() {
  // Basic usage
  basicExample();

  // Pattern matching
  patternMatchingExample();

  // Early return with $ syntax
  earlyReturnExample();

  // Async example
  unawaited(asyncExample());

  // Method chaining
  methodChainingExample();
}

/// Demonstrates creating and using Ok and Err.
void basicExample() {
  print('=== Basic Example ===');

  const ok = Ok<int, String>(42);
  const err = Err<int, String>('Something went wrong');

  print('ok.isOk: ${ok.isOk}'); // true
  print('ok.value: ${ok.ok()}'); // 42
  print('err.isErr: ${err.isErr}'); // true
  print('err.error: ${err.err()}'); // Something went wrong

  // Safe value extraction
  print('ok.get: ${ok.get(orElse: (e) => 0)}'); // 42
  print('err.get: ${err.get(orElse: (e) => -1)}'); // -1

  print('');
}

/// Demonstrates pattern matching with Result.
void patternMatchingExample() {
  print('=== Pattern Matching Example ===');

  final result = divide(10, 2);

  // Using switch expression
  final message = switch (result) {
    Ok(:final value) => 'Result: $value',
    Err(:final error) => 'Error: $error',
  };
  print(message); // Result: 5

  // Pattern matching with error
  final errorResult = divide(10, 0);
  switch (errorResult) {
    case Ok(:final value):
      print('Got value: $value');
    case Err(:final error):
      print('Got error: $error'); // Got error: Division by zero
  }

  print('');
}

/// Demonstrates early return with $ syntax.
void earlyReturnExample() {
  print('=== Early Return Example ===');

  Result<int, String> calculate(int a, int b, int c) {
    return Result(
      ($) {
        final ab = divide(a, b)[$]; // Early return if error
        final cd = divide(c, 1)[$];
        return Ok(ab + cd);
      },
      onCatch: (e, s) => Err('Unexpected: $e'),
    );
  }

  // Success case
  final successResult = calculate(10, 2, 5);
  print('Success: ${successResult.ok()}'); // Success: 7 (10/2 + 5/1)

  // Error case - early return on first error
  final errorResult = calculate(10, 0, 5);
  print('Error: ${errorResult.err()}'); // Error: Division by zero

  print('');
}

/// Demonstrates async Result usage.
Future<void> asyncExample() async {
  print('=== Async Example ===');

  Future<Result<String, String>> fetchUserData(int id) {
    return Result.async(
      ($) async {
        if (id <= 0) return const Err('Invalid ID');

        final name = await fetchName(id)[$]; // Early return if fetchName returns Err
        return Ok('User: $name');
      },
      onCatch: (e, s) => Err('Unexpected: $e'),
    );
  }

  final result = await fetchUserData(123);
  switch (result) {
    case Ok(:final value):
      print('Got user: $value');
    case Err(:final error):
      print('Failed: $error');
  }

  print('');
}

/// Demonstrates method chaining.
void methodChainingExample() {
  print('=== Method Chaining Example ===');

  final result = divide(20, 4)
      .map((v) => v * 10) // Transform: 5 -> 50
      .flatMap((v) => divide(v, 5)) // Chain: 50 / 5 = 10
      .tap((v) => print('Intermediate value: $v')); // Side effect

  print('Final result: ${result.ok()}'); // 10

  // Error propagation through chain
  final errorChain = divide(10, 0).map((v) => v * 2).flatMap((v) => divide(v, 2));

  print('Error chain: ${errorChain.err()}'); // Division by zero

  // Recovery from error
  final recovered = divide(10, 0).recover((e) => const Ok<int, Never>(42));

  print('Recovered: ${recovered.ok()}'); // 42

  print('');
}

// Helper functions

Result<int, String> divide(int a, int b) {
  if (b == 0) return const Err('Division by zero');
  return Ok(a ~/ b);
}

Future<Result<String, String>> fetchName(int id) async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return Ok('User #$id');
}
