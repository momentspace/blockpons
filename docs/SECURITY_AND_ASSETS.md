# Security and original-assets policy

## Public repository: no secrets or sensitive information
- Never commit API keys, tokens, credentials, private keys, signing keys, keystore files, certificates with private keys, provisioning profiles, .env files, local configuration, personal data, crash logs containing identifiers, or private infrastructure information.
- Use GitHub Actions secrets/environments for credentials, never echo secrets to CI logs. Minimize GITHUB_TOKEN permissions and pin external actions by full SHA.
- Add appropriate .gitignore entries before generating Flutter, Android, or iOS projects. Treat generated release artifacts and signing material separately.
- Add secret scanning to CI; review diffs before committing. If a secret leaks, revoke/rotate it immediately and follow an incident procedure—deleting a commit alone is insufficient.
- Never include real user data in sample fixtures. Use synthetic test data only.

## Assets: independently created
- Images, logo, icon, animation, BGM and SFX should be authored/generated specifically for Blockpons, without copying other games' screenshots, UI artwork, branding, sound recordings or source code.
- Do not scrape or download third-party assets into this repo unless explicitly approved following verification of provenance, permission and license compatibility.
- Record asset name, author/generator, date, model/tool, inputs or process, and permitted uses in `assets/PROVENANCE.md` once assets exist. For AI-generated assets, review the service terms and check output for recognizable third-party IP.
- Verify name/trademark and platform store policies before public release.

## Review gate
Every PR must confirm no credentials or personal data were added, and any newly added asset has documented provenance.