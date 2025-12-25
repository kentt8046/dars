# dars デザインドキュメント

| 項目 | 内容 |
|------|------|
| **Author** | @kentt8046 |
| **Status** | Draft |
| **Created** | 2025-12-21 |
| **Last Updated** | 2025-12-21 |

---

## 1. Overview

### 1.1 Purpose

DartにRustのResult型のような最上級の使い心地を持つ、よりDartらしいResult型パッケージを提供する。エコシステム（テストmatcher、lintルール等）も整備する。

### 1.2 Scope

- **対象**: `dars` パッケージのコア機能
- **対象外**: `dars_test`、`dars_lint` は別パッケージ（1.0.0までに提供予定）

---

## 2. Context and Scope

### 2.1 背景

Dartの標準try-catchの問題：エラーハンドリング漏れ、ネスト、エラーの可視性が低い。

### 2.2 対象ユーザー

Flutter / サーバーサイド / CLI 開発のDartエンジニア

### 2.3 Dart SDK・依存

- **Dart 3.6.0以上**（pub workspace要件）
- **依存パッケージ: 0**（コアパッケージ）
- **pub workspace形式**で各パッケージを実装

### 2.4 ディレクトリ構成

```
dars/
├── README.md              # パッケージ説明（英語）
├── CHANGELOG.md           # バージョン履歴
├── pubspec.yaml           # workspace root
├── packages/
│   ├── dars/          # コアパッケージ
│   │   ├── lib/
│   │   ├── test/
│   │   ├── example/
│   │   ├── docs/
│   │   │   └── best_practices.md  # ベストプラクティス
│   │   └── pubspec.yaml
│   ├── dars_test/     # テストmatcher（1.0.0）
│   │   └── pubspec.yaml
│   └── dars_lint/     # lintルール（1.0.0）
│       └── pubspec.yaml
└── docs/
    ├── design_doc.md      # 設計ドキュメント
    └── README_ja.md       # パッケージ説明（日本語）
```

---

## 3. Goals and Non-Goals

### 3.1 Goals

Dartらしい直感的API / 型安全 / 関数型知識不要 / パターンマッチ活用

### 3.2 Non-Goals

| 項目 | 理由 |
|------|------|
| 完全な関数型ライブラリ | Monad等は学習コストが高く目的外 |
| シリアライズ機能 | Resultを永続化するケースは稀 |
| Flutter固有機能 | Riverpod連携等はFlutter依存 |
| `Result.all()` | `$`構文で同等処理可能 |
| 並列実行ヘルパー | `Future.wait`と`$`構文で対応可能 |

---

## 4. Alternatives Considered

| パッケージ | 問題点 |
|-----------|--------|
| dartz / fpdart / oxidized | 関数型前提 |
| result_type | 手続き的に書けない |
| rust | Result以外も含む |

---

## 5. System Design

### 5.1 基本構造

```dart
sealed class Result<T, E extends Object> { }
class Ok<T, E extends Object> extends Result<T, E> { final T value; }
class Err<T, E extends Object> extends Result<T, E> { final E error; }
```

### 5.2 $構文（早期リターン）

[rust](https://pub.dev/packages/rust)参考。**try-catchも兼ねる**。

```dart
// 同期版
Result<Data, Error> process() => Result(
  ($) {
    final user = getUser()[$];  // Errなら早期リターン
    return processData(user);    // 例外もErrに変換
  },
  onCatch: (e, s) => Err(Error.from(e)),
);

// 非同期版
Future<Result<Data, Error>> processAsync() => Result.async(
  ($) async {
    final user = await getUser()[$];
    return processData(user);
  },
  onCatch: (e, s) async => Err(Error.from(e)),
);
```

#### 5.2.1 内部実装

```dart
class EarlyReturnSymbol<E> {
  const EarlyReturnSymbol._();
}

sealed class Result<T, E extends Object> {
  T operator [](EarlyReturnSymbol<E> $);
}

// Future拡張
extension on Future<Result<T, E extends Object>> {
  Future<T> operator [](EarlyReturnSymbol<E> $);
}
```

### 5.3 メソッド（Rust Resultとの対応表）

| 説明 | Rust | dars | 戻り値 |
|------|------|----------|--------|
| **判定** |
| 成功判定 | `is_ok()` | `isOk` | `bool` / `Future<bool>` |
| エラー判定 | `is_err()` | `isErr` | `bool` / `Future<bool>` |
| 成功かつ条件判定 | `is_ok_and(fn)` | `isOkWhere(fn)` | `bool` / `Future<bool>` |
| エラーかつ条件判定 | `is_err_and(fn)` | `isErrWhere(fn)` | `bool` / `Future<bool>` |
| **Optional変換** |
| 成功値をnullable取得 | `ok()` | `ok()` | `T?` / `Future<T?>` |
| エラー値をnullable取得 | `err()` | `err()` | `E?` / `Future<E?>` |
| **値取得** |
| 強制取得 | `unwrap()` | `getOrThrow()` | `T` / `Future<T>` |
| デフォルト付き取得 | `unwrap_or(x)` | ※`get`で代替 | - |
| 遅延デフォルト取得 | `unwrap_or_else(fn)` | `get(orElse: (E) => T)` | `T` / `Future<T>` |
| メッセージ付き強制取得 | `expect(msg)` | `getOrThrow(msg)` | `T` / `Future<T>` |
| **変換** |
| 成功値変換 | `map(fn)` | `map(fn)` | `Result<U, E>` / `FutureResult<U, E>` |
| 成功値変換+デフォルト | `map_or(x, fn)` | ※`fold`で代替 | - |
| 成功値変換+遅延デフォルト | `map_or_else(d, fn)` | `fold(fn, orElse: (E) => U)` | `U` / `Future<U>` |
| エラー値変換 | `map_err(fn)` | `mapError(fn)` | `Result<T, F>` / `FutureResult<T, F>` |
| **チェーン** |
| 成功時に別Result | `and(res)` | ※`flatMap`で代替 | - |
| 成功時に関数実行 | `and_then(fn)` | `flatMap(fn)` | `Result<U, E>` / `FutureResult<U, E>` |
| エラー時に別Result | `or(res)` | ※`recover`で代替 | - |
| エラー回復 | `or_else(fn)` | `recover(fn)` | `Result<T, F>` / `FutureResult<T, F>` |
| **デバッグ** |
| 成功値を覗く | `inspect(fn)` | `tap(fn)` | `Result<T, E>` / `FutureResult<T, E>` |
| エラー値を覗く | `inspect_err(fn)` | `tapError(fn)` | `Result<T, E>` / `FutureResult<T, E>` |
| **型変換** |
| 成功値の型変換 | N/A | `castOk<U>()` | `Result<U, E>` / `FutureResult<U, E>` |
| エラー値の型変換 | N/A | `castErr<F>()` | `Result<T, F>` / `FutureResult<T, F>` |
| 両方の型変換 | N/A | `cast<U, F>()` | `Result<U, F>` / `FutureResult<U, F>` |

### 5.4 Nullable拡張（Rust Optionとの対応）

| 説明 | Rust Option | dars | 戻り値 |
|------|-------------|----------|--------|
| エラー付きResult変換 | `ok_or(e)` | ※`toResult`で代替 | - |
| 遅延エラーResult変換 | `ok_or_else(fn)` | `toResult(orElse: fn)` | `Result<T, E>` |

### 5.5 Future拡張

`Future<Result<T, E>>`に対して全メソッドを直接呼べる。

### 5.6 型エイリアス

```dart
typedef FutureResult<T, E> = Future<Result<T, E>>;
typedef VoidResult<E> = Result<void, E>;
```

---

## 6. Testing Strategy

- **CI**: Dart 3.6.0, stable最新, beta最新
- **カバレッジ100%**

### 6.1 検証コマンド

```bash
dart test
dart analyze
dart run coverage:test_with_coverage
```

---

## 7. Milestones

| バージョン | 内容 |
|-----------|------|
| **v0.1.0** | コア機能一式 |
| **v1.0.0** | API安定化、dars_test、dars_lint |

---

## 8. References

- [Rust Result](https://doc.rust-lang.org/std/result/)
- [rust (pub.dev)](https://pub.dev/packages/rust) - $構文の参考
- [dartz](https://pub.dev/packages/dartz)
- [fpdart](https://pub.dev/packages/fpdart)
- [oxidized](https://pub.dev/packages/oxidized)
- [result_type](https://pub.dev/packages/result_type)
