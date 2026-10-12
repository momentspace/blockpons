# Contributor / coding-agent instructions

- Read README.md, docs/PRODUCT.md, docs/SECURITY_AND_ASSETS.md, related Issues and docs/adr/ first.
- This repository is **public**. Never commit secrets, API tokens, credentials, signing keys, personal data, private infrastructure values, .env files or machine-local files. Check staged changes and generated files before commits.
- Prefer self-authored or generated visuals, icons, sound and music; **never reuse external game assets without explicit permission**. Keep provenance and licensing documentation for every asset.
- Keep work in small PRs aligned to acceptance criteria.
- Isolate board/scoring calculations from Flutter UI; make pure Dart logic deterministic and unit tested.
- Inject RNG for reproducible tests. Cover simultaneous row/column clears, no-placement state, retry, and invalid placement.
- Evaluate ADR before dependencies that may break Web/Android/iOS parity.
- Do not suppress CI failures; never report unperformed device tests as complete.
- Do not auto-merge, publish releases, configure payments, or commit credentials without explicit authorization.
