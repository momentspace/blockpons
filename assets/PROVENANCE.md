# Asset provenance

No third-party images, audio files, or fonts are included in the initial
playable prototype. The board, blocks, backgrounds, and UI decorations are
defined directly in the original Flutter source code.

| Asset | Source | Usage |
| --- | --- | --- |
| Colored block tiles | Code-drawn geometric squares in `game_screen.dart` | Original UI |
| Background gradient and card surfaces | Code-drawn Flutter widgets in `game_screen.dart` | Original UI |
| Icons | Built-in Flutter Material icon font | Flutter dependency |

Any future asset must record author/generator, creation date, model/tool,
prompt/process summary, usage rights, and reviewer before integration.
