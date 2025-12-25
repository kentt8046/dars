# **dars** (**da**rt **r**e**s**ult)

[![pub package](https://img.shields.io/pub/v/dars.svg)](https://pub.dev/packages/dars)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![codecov](https://codecov.io/gh/kentt8046/dars/branch/main/graph/badge.svg)](https://codecov.io/gh/kentt8046/dars)

[English](https://github.com/kentt8046/dars/blob/main/README.md) | **日本語**

Dartらしい使い心地を追求したResult型パッケージ。

> ⚠️ **現在開発中です。** 破壊的変更が発生する可能性があります。

## 特徴

- **Dartらしい直感的なAPI** - Dart開発者向けに設計された使いやすいAPI
- **パターンマッチング対応** - Dart 3の強力なパターンマッチングを活用
- **$構文による早期リターン** - [rust](https://pub.dev/packages/rust) パッケージにインスパイアされた機能（感謝！）
- **完全な非同期サポート** - `FutureResult` で全メソッドが利用可能
- **Nullable→Result変換** - `T?.toResult()` 拡張で簡単変換
- **型安全なAPI** - コンパイル時の安全性を保証

## インストール

```yaml
dependencies:
  dars: ^0.1.0
```

または:

```bash
dart pub add dars
```

## クイックスタート

```dart
import 'package:dars/dars.dart';

Result<int, String> divide(int a, int b) {
  if (b == 0) return Err('Division by zero');
  return Ok(a ~/ b);
}

void main() {
  final result = divide(10, 2);

  // パターンマッチング
  switch (result) {
    case Ok(:final value): print('結果: $value');
    case Err(:final error): print('エラー: $error');
  }
}
```

## コアコンセプト

### Result型

`Result<T, E>` は成功（`Ok<T, E>`）または失敗（`Err<T, E>`）を表すsealed classです。

```dart
const ok = Ok<int, String>(42);
const err = Err<int, String>('Something went wrong');

print(ok.isOk);   // true
print(err.isErr); // true
```

### パターンマッチング

Dart 3のパターンマッチングでクリーンかつ網羅的な処理が可能です：

```dart
final message = switch (result) {
  Ok(:final value) => '値を取得: $value',
  Err(:final error) => 'エラー発生: $error',
};
```

### $構文による早期リターン

`$`構文を使うと、エラーハンドリングがシンプルになります：

```dart
Result<int, String> calculate(int a, int b, int c) {
  return Result(($) {
    final ab = divide(a, b)[$];  // Errなら早期リターン
    final cd = divide(c, 1)[$];
    return ab + cd;
  }, onCatch: (e, s) => Err('予期しないエラー: $e'));
}
```

### 非同期サポート

`Result.async` と `FutureResult` で完全な非同期対応：

```dart
Future<Result<String, String>> fetchUser(int id) {
  return Result.async(($) async {
    if (id <= 0) {
      Err<String, String>('無効なID')[$];
    }
    await Future.delayed(Duration(milliseconds: 100));
    return 'User #$id';
  }, onCatch: (e, s) => Err('予期しないエラー: $e'));
}
```

## APIリファレンス

### メソッド対応表（Rust / Swift）

> **Note:** Swift の Result は `map`, `flatMap`, `mapError`, `flatMapError`, `get()` を提供。

| 説明 | dars | Rust | Swift |
|------|----------|------|-------|
| **判定** |
| 成功判定 | `isOk` | `is_ok()` | - (pattern match) |
| エラー判定 | `isErr` | `is_err()` | - (pattern match) |
| 成功かつ条件判定 | `isOkWhere(fn)` | `is_ok_and(fn)` | - |
| エラーかつ条件判定 | `isErrWhere(fn)` | `is_err_and(fn)` | - |
| **Optional変換** |
| 成功値をnullable取得 | `ok()` | `ok()` | - (pattern match) |
| エラー値をnullable取得 | `err()` | `err()` | - (pattern match) |
| **値取得** |
| デフォルト付き取得 | `get(orElse: fn)` | `unwrap_or_else(fn)` | - |
| 強制取得 | `getOrThrow([msg])` | `unwrap()` / `expect(msg)` | `get() throws` |
| **変換** |
| 成功値変換 | `map(fn)` | `map(fn)` | `map(_:)` |
| エラー値変換 | `mapError(fn)` | `map_err(fn)` | `mapError(_:)` |
| 成功値変換+デフォルト | `fold(fn, orElse: fn)` | `map_or_else(d, fn)` | - |
| **チェーン** |
| 成功時に別Result | `flatMap(fn)` | `and_then(fn)` | `flatMap(_:)` |
| エラー回復 | `recover(fn)` | `or_else(fn)` | `flatMapError(_:)` |
| **デバッグ** |
| 成功値を覗く | `tap(fn)` | `inspect(fn)` | - |
| エラー値を覗く | `tapError(fn)` | `inspect_err(fn)` | - |
| **型変換** |
| 成功値の型変換 | `castOk<U>()` | - | - |
| エラー値の型変換 | `castErr<F>()` | - | - |
| 両方の型変換 | `cast<U, F>()` | - | - |

### 型エイリアス

```dart
typedef FutureResult<T, E> = Future<Result<T, E>>;
typedef VoidResult<E> = Result<void, E>;
```

### Nullable拡張

```dart
final String? name = getUserName();
final result = name.toResult(orElse: () => 'Name not found');
```

## 完全な例

包括的なデモは [example/example.dart](packages/dars/example/example.dart) を参照してください。

## 追加情報

- 📋 [Design Document (日本語)](https://github.com/kentt8046/result_x/blob/main/docs/design_doc.md)

## ライセンス

BSD 3-Clause License - 詳細は [LICENSE](../LICENSE) を参照してください。
