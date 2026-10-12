# ADR-0001: クロスプラットフォーム戦略

- Status: Proposed
- Date: 2026-10-12

## Context
Web、Android、iOS のゲームを単一リポジトリで作り、共通のゲームルールと一貫した操作感を維持したい。

## Proposal
Flutter + Dart を採用する。ドメイン層を Flutter UI から分離し、純粋な Dart で盤面の状態遷移を実装する。ゲーム画面は Flutter 標準描画を優先し、必要なら Flame 等の導入を比較する。

## Alternatives
- React + Capacitor: Web 中心では強いが、描画・タッチ体験の調整を要評価
- Godot: ゲーム向けだが、Web/モバイルのビルド環境と配布運用を要評価
- 3環境を個別実装: 保守とテスト負荷が高い

## Consequences
- 共通コード比率を高められる見込み
- iOS の最終ビルド・署名には macOS/Xcode と Apple 開発環境が必要
- Web とモバイルで入力・画面サイズ・パフォーマンス差を検証する必要がある

## Decision gate
開発基盤 Issue でサンプル描画・タッチ入力・CI ビルドを確認後、Accepted に更新する。
