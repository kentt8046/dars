# dars_test デザインドキュメント

| 項目 | 内容 |
|------|------|
| **Author** | @kentt8046 |
| **Status** | Approved |
| **Created** | 2025-12-27 |
| **Last Updated** | 2025-12-27 |

---

## 1. Overview

### 1.1 Purpose

`dars`パッケージの`Result`型に特化したテストmatcherおよびユーティリティを提供する。Dartらしい自然な書き方でResultにフォーカスしたテストを可能にし、スタブ化（Stubbing）のボイラープレートを排除する。

### 1.2 Scope

- **対象**: `dars_test` パッケージ（v0.2.0）
- **機能**:
    - `Result` 専用 Matcher (`isOk`, `isErr`)
    - スマートな引数判別（値、Matcher、述語関数の自動判別）
    - 詳細なエラーメッセージ（型情報含む）
    - Mockito 連携ユーティリティ (`whenResult`)

---

## 2. Goals and Non-Goals

### 2.1 Goals

- **直感的な API**: `expect(result, isOk)` 形式の自然な構文。
- **スマートな検証**: 値の直接比較、Matcher 連携、クロージャによる検証を一つの API で提供。
- **詳細な失敗報告**: 型の不一致や値の差分を明確に視覚化。
- **ゼロコンフィグ・スタブ化**: `provideDummy` を意識させない Mockito 連携。

---

## 3. System Design

### 3.1 API設計 (Matchers)

#### 3.1.1 スマートな `isOk` / `isErr`
`isOk` および `isErr` は、引数の型に応じて自動的に検証ルールを切り替える。

| 使い方 | 検証内容 |
|-------|------|
| `isOk` | ResultがOkかどうか |
| `isOk(value)` | Okかつ値が `equals(value)` |
| `isOk(matcher)` | Okかつ値が `matcher` に適合 |
| `isOk((v) => ...)` | Okかつ値が述語関数（predicate）を満たす |
| `isOk<T>(...)` | 上記に加え、値の型が `T` であるかを厳密に検証 |

#### 3.1.2 使用例
```dart
expect(result, isOk);
expect(result, isOk(42));
expect(result, isOk(greaterThan(0)));
expect(result, isOk((v) => v.id != null));
expect(result, isOk<int>(42)); // 型指定がある場合はエラーメッセージに型を含める
```

### 3.2 エラーメッセージ設計

デバッグ効率を最大化するため、不一致時にリッチな情報を表示する。

#### 表示ルール
- **型不一致時**: 期待値と実際値の両方に型情報を付与。
- **型指定あり時**: `isOk<T>` のように明示的に指定された場合は、型情報を常に出力。
- **型一致・指定なし時**: シンプルに値の差分のみを表示し、ノイズを減らす。

| パターン | メッセージ例 |
| :--- | :--- |
| Variant 違い | `Expected: Ok but was: Err(NetworkError.timeout)` |
| 型違い | `Expected: Ok<int> but was: Ok<String>('42')` |
| 値違い | `Expected: Ok(42) but was: Ok(0)` |
| 述語不一致 | `Expected: Ok(matches predicate) but was: Ok(0) which does not match predicate` |

### 3.3 Mockito 連携 (`whenResult`)

`sealed class` 特有の `provideDummy` 手間を解消する。

#### `whenResult` / `whenFutureResult`
`dummy` 引数を渡すことで、内部で `provideDummy` を自動実行する。戻り値型から `Result<T, E>` を推論するため、型パラメータの明示は不要。

```dart
// Before (Mockito 標準)
provideDummy<Result<User, Error>>(Ok(dummyUser)); // これが必要だった
when(mock.getUser()).thenAnswer((_) => Ok(user));

// After (dars_test)
whenResult(() => mock.getUser(), dummy: Ok(dummyUser))
    .thenAnswer((_) => Ok(user));

// 非同期メソッドの場合
whenFutureResult(() => mock.getUserAsync(), dummy: Ok(dummyUser))
    .thenAnswer((_) async => Ok(user));
```

---

## 4. Implementation Details

### 4.1 Matcher 構成
Matcher を内部的に分割し、責任を明確化する。
- `_ResultVariantMatcher`: 基本的な Ok/Err 判定。
- `_ResultTypeMatcher<T>`: `isOk<T>` 用の型検証。内部で `isA<T>()` を利用。
- `_ResultValueMatcher`: 値、Matcher、述語関数の判別と、`describeMismatch` の詳細化を担当。

---

## 5. Milestones

[マイルストーン](../milestones.md) を参照してください。

## 6. References

- [dars Design Doc](./dars.md)
- [Dart Test Matchers](https://pub.dev/packages/test)
- [Mockito Reference](https://pub.dev/packages/mockito)
