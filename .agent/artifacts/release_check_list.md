// turbo-all

# リリース前チェックリスト

リリース前に以下の項目を確認してください。

## 1. コード品質

- [ ] 全てのテストがパスしている (`dart test`)
- [ ] 統合テストがパスしている（該当する場合）
- [ ] コードカバレッジが目標値を満たしている
  - `dart run coverage:test_with_coverage`でカバレッジを出力して確認する
- [ ] 静的解析でエラー・警告がない (`dart analyze`)
- [ ] コードフォーマットが適用されている (`dart format -o none --set-exit-if-changed .`)
- [ ] 不要なコメント・デバッグコードが削除されている
- [ ] TODO/FIXMEコメントが残っていない

## 2. ドキュメント

- [ ] README.mdが最新の内容になっている
  - [ ] `doc/README_ja.md`と内容が一致しているか
  - [ ] リリース済みのmainブランチと変更差分を確認して、READMEの内容が最新になっているか
- [ ] CHANGELOG.mdにリリース内容が記載されている
- [ ] APIドキュメントが適切に記述されている
- [ ] `dart doc` でドキュメント生成が成功する
- [ ] exampleコードに矛盾がないか
  - 実行はできないので、コードの内容を確認する
- [ ] 破壊的変更がある場合、移行ガイドが用意されている
  - [ ] リリース済みのmainブランチと変更差分を確認して、破壊的変更がないか
  - [ ] 移行ガイドが適切に記述されているか

## 3. バージョン・依存関係

- [ ] pubspec.yamlのバージョン番号が更新されている
- [ ] `dart pub get` が正常に完了する
- [ ] 依存パッケージが最新かつ互換性がある (`dart pub outdated`)

## 4. pubspec.yaml メタデータ

- [ ] `description` が適切（60〜180文字）
- [ ] `homepage` / `repository` が設定されている
- [ ] `topics` が設定されている
- [ ] Pub Pointのスコアが満点になっているかどうか
  - `dart pub global activate pana && pana .`で確認する

## 5. セキュリティ・公開準備

- [ ] ライセンスファイルが存在し正しい
- [ ] 機密情報が含まれていない
- [ ] 不要なファイルが除外されている（`.gitignore` / `.pubignore`）
- [ ] `dart pub publish --dry-run` が成功する
  - `The name of "lib/main.dart", "main", should match the name of the package, ...`は無視する。

## 6. git差分確認（READMEの正確性・破壊的変更の検出）

以下のコマンドで差分を確認し、READMEの正確性と破壊的変更を検証する。

### 確認コマンド

```bash
# ソースコードの差分
git diff origin/main -- lib/ bin/

# ドキュメントの差分
git diff origin/main -- README.md doc/README_ja.md

# 依存関係の差分
git diff origin/main -- pubspec.yaml
```

### 検証項目

- [ ] READMEの記載内容がソースコードの実装と一致しているか
- [ ] 破壊的変更（API変更、削除された機能など）がないか
- [ ] 破壊的変更がある場合、CHANGELOGや移行ガイドに記載されているか
