# pixbitpoi/homebrew-tap

pixbitpoi が公開しているツールの Homebrew tap です。

## 使い方

```bash
brew tap pixbitpoi/tap
brew trust pixbitpoi/tap
brew install aws-login
brew install aws-survey
```

Homebrew 6 以降は非公式 tap の formula を読み込む前に `brew trust` が必要です。
信頼したあとは、通常の formula と同じように `brew install` / `brew upgrade` できます。
`brew install pixbitpoi/tap/aws-login` のようにフルネームで指定すれば `brew trust` なしでも入りますが、
その後の `brew upgrade aws-login` などの短い名前の操作には信頼が必要です。

## formula 一覧

| formula | 内容 | 本体リポジトリ |
| --- | --- | --- |
| `aws-login` | AWS CLI のログイン（IAM ユーザー + MFA、IAM Identity Center の SSO）をまとめて扱う Bash ラッパー | [pixbitpoi/aws-login](https://github.com/pixbitpoi/aws-login) |
| `aws-survey` | AWS アカウントの構成を、読み取り専用の隔離コンテナで Claude Code / Codex に調べさせる一式 | [pixbitpoi/aws-survey](https://github.com/pixbitpoi/aws-survey) |

どちらも AWS CLI v2 を必要としますが、formula の依存には含めていません。
Homebrew の `awscli` か公式インストーラーで別途インストールしてください。
`aws-survey` はさらに Docker を使います。cask のため依存には入れておらず、`aws-survey doctor` で有無を確認できます。

## 開発版を入れる

```bash
brew install --HEAD aws-login
brew install --HEAD aws-survey
```

本体リポジトリの `main` ブランチをそのまま入れます。

## formula の更新

本体リポジトリにタグを打ってから、`Formula/*.rb` の `url` と `sha256` を更新します。
手順の詳細は各本体リポジトリのドキュメントにあります
（どちらも `docs/release.md`）。

```bash
brew style Formula/<formula>.rb
brew audit --strict pixbitpoi/tap/<formula>
brew install pixbitpoi/tap/<formula>
brew test <formula>
```
