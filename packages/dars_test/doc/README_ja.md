# **dars_test**

[![pub package](https://img.shields.io/pub/v/dars_test.svg)](https://pub.dev/packages/dars_test)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

`dars` パッケージのためのテストユーティリティおよび Matcher です。

[English](https://github.com/kentt8046/dars/blob/main/packages/dars_test/README.md) | **日本語**

## 特徴

- **スマートな Result Matcher** - 値、Matcher、述語関数（predicate）を自動的に判別する `isOk` および `isErr`。
- **型安全な検証** - 厳格な型チェックを行うための `isOk<T>()` および `isErr<E>()`。
- **詳細なエラーメッセージ** - 型情報を含む分かりやすい不一致理由を出力。

## セットアップ

```yaml
dev_dependencies:
  dars_test:
```

## 使い方

```dart
import 'package:dars/dars.dart';
import 'package:dars_test/matcher.dart';
import 'package:test/test.dart';

void main() {
  test('example', () {
    final Result<int, String> result = Ok(42);

    // 基本的な Variant チェック
    expect(result, isOk);

    // 値のチェック
    expect(result, isOk(42));

    // Matcher を使ったチェック
    expect(result, isOk(greaterThan(0)));

    // 述語関数を使ったチェック
    expect(result, isOk((v) => v % 2 == 0));

    // 型指定付きのチェック
    expect(result, isOk<int>(42));
  });
}
```

## 例

詳細な使い方は [example/example.dart](https://github.com/kentt8046/dars/blob/main/packages/dars_test/example/example.dart) を参照してください。

## エラーメッセージ

テスト失敗時、`dars_test` はデバッグに役立つ詳細な情報を出力します。

- **Variant 違い**: `Expected: Ok but was: Err('timeout')`
- **型違い**: `Expected: Ok<int> but was: Ok<String>('42')`
- **値違い**: `Expected: Ok(42) but was: Ok(0)`

## ライセンス

BSD 3-Clause License
