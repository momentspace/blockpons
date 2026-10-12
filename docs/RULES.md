# Blockpons MVP rules — provisional v0.1

This document records a deliberately original, testable game model.
It does **not** claim to reproduce private algorithms from Block Blast!.

## Board and inputs
- 8 × 8 cells. Empty at the start.
- Three randomly selected piece offers are visible at a time.
- A piece does not rotate, reflect, or fall automatically.
- The player places any available offer on empty cells; no overlap or off-board placement.
- Consuming one offer removes only that offer. After all three have been used, all three are replenished.
- Available pieces are sampled uniformly from `PieceCatalog`. There is no guaranteed playable offer; tuning is a future task.
- A game is over when none of the *remaining* offers can fit anywhere.

## Line clearing
- Every complete row and complete column is cleared immediately after each valid placement.
- Rows and columns clear simultaneously. At an intersection, a cell is only removed once.
- Unrelated board cells remain in place; there is no gravity.

## Scoring (original provisional formula)
- Placement: +1 point for every occupied cell in the newly placed piece.
- Line clear: +10 points for every *unique cell* removed.
- Multiple lines in one placement: +20 per additional line beyond the first.
- Consecutive clearing placements: combo increases by one each time.
- Combo bonus: +5 × (combo − 1) × number of lines cleared.
- A placement that does not clear a line resets combo to 0.

**Examples**
- One single cell placed with no line: +1.
- Single cell completes an 8-cell row: 1 + 80 = **81**.
- Single cell completes intersecting row and column: 1 + 150 + 20 = **171**.
- Following an immediately previous clear, completing one row with a single cell: 1 + 80 + 5 = **86**.

## Controls
- Drag an offer over the board for green (valid) / red (invalid) preview, then release to place.
- Alternatively tap an offer and tap the desired top-left anchor cell on the board.
- Retry resets board and score, not the stored best score.

## Open design questions
Piece distribution and difficulty balancing, sound and motion accessibility,
daily challenges, progressive modes and optional comeback mechanics
remain under their existing issues.
