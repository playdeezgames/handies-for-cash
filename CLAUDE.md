# CLAUDE.md

"Handies for Cash!" by TheGrumpyGameDev: a turn-based, menu-driven text metaphor (VB.NET, August 2026), ported to Odin and `js_wasm32` on November 5, 2026. The vault at `/home/yermom/git/bok-of-splorr/splorr/` documents it (`Games/Handies for Cash.md`) and holds the standing rules; read its `Home.md` first.

## Layout

- `odin/`: package `handies`. `rules.odin` is the pure game (no platform imports; the RNG and clock are passed in), `screens.odin` the menu state machine and drawing onto a 53 by 30 (or 36 by 54 portrait) DINOBYTE text grid, `save.odin` the JSON save, `web.odin` the wasm entry points (`#+build js`). Tests are `*_test.odin` (`#+build !js`); `shots_test.odin` dumps screens for `tools/make_shots.sh`.
- `web/index.html`: the page (canvas text renderer, keys, taps, localStorage, footer with credits and back links).
- `tools/`: `build.sh`, `test.sh`, `ship.sh` (itch.io, pushes only with `--push`), `pages.sh` (GitHub Pages into `docs/`), `make_shots.sh`, `render_cells.py`, `make_cover.py`. `shippit.sh` is the one-line wrapper for `tools/ship.sh`.
- `src/`: the VB.NET original, the specification. `QUIRKS.md` lists every deliberate difference.
- Release material per the vault's Release standard: `ITCH_DESCRIPTION.md`, `assets/cover.png`, `assets/screenshots/`, `devlog/YYYYMMDD/`.

## Rules

- Never `git push`, `tools/ship.sh --push`, `shippit.sh --push` or `butler push` unless the user says so ("push" means git, "ship" means itch.io). One itch.io release a day, booked in Coxswain.
- Keep the message voice and the deliberate design (no goal, the ad break, the sponsors); fixes go in `QUIRKS.md`.
