# Handies for Cash!

A Production of TheGrumpyGameDev

A metaphor about giving handies in exchange for cash. In a dark alley. Text only.

- Play: https://playdeezgames.github.io/handies-for-cash/ (GitHub Pages, the latest build) or https://thegrumpygamedev.itch.io/handies-for-cash
- The original (August 2026) is VB.NET in `src/`, with a Spectre console client and a Blazor browser client.
- The browser version (November 2026) is Odin compiled to WebAssembly in `odin/`, ported by Claude Code (an AI agent) at the author's direction. What changed is in `QUIRKS.md`.

## Building the browser version

Needs Odin on the PATH (or `ODIN=/path/to/odin`), Python 3 with Pillow for the images, and `zip`.

```bash
tools/test.sh          # native tests
tools/build.sh         # build/web (serve it with any static server)
tools/ship.sh          # tests, size build, zip; pushes to itch.io only with --push
tools/pages.sh         # copies the size build into docs/ for GitHub Pages
tools/make_shots.sh    # assets/screenshots/ from the real game
tools/make_cover.py    # assets/cover.png
```

Font: DINOBYTE by mby, https://mby.itch.io/dinobyte, CC BY 4.0, unmodified (`assets/dinobyte/`).
