Page: https://thegrumpygamedev.itch.io/handies-for-cash
Jam: probably none. The page's share text names Soulslike Game Jam #3, but the repo began as a copy of Clumsy Oaf of SPLORR!! (that jam's entry) with the soulslike ripped out on its first day; whether Handies was entered anywhere is unchecked. Original release August 2026 (VB.NET, Blazor in the browser plus Windows, macOS and Linux downloads). This is the November 2026 browser port, replacing the `html` channel.
Pasted in by hand; nothing here is published by the repo. Everything above "Notes (not for the page)" is for the page.

**Short description**

A metaphor about giving handies in exchange for cash. In a dark alley. Text only; now saves in your browser.

**Description**

**Latest version:** https://playdeezgames.github.io/handies-for-cash/

This is a metaphor about giving handies in exchange for cash.

In a dark alley.

This is a text based game, and has really no explicit content, but the content may disturb you none-the-less.

It was inspired by a recent rewatch of South Park: Bigger, Longer, and Uncut.

Yer welcome.

**Controls:**

Press the number or letter of a choice, or use the arrow keys and Enter. Escape is Never Mind. Page Up and Page Down scroll back through the messages. On a phone or tablet, tap a choice.

**New: rebuilt for the browser**

The metaphor has been rebuilt in Odin and WebAssembly. The places, the verbs and the numbers are the original's, with a few fixes:

- It saves as you play, in this browser, and picks up where you left off.
- Sleeping now costs food (it used to feed you).
- Messages say what actually changed.
- It has a layout for phones held upright.

The full list is in QUIRKS.md in the source.

**AI use**

This browser version was written with Claude Code (Anthropic's AI coding assistant) at my direction: the port, its tests, the cover and the page. The metaphor, its design and its text are the original's, and the August 2026 original was written without AI.

**Credits**

A production of TheGrumpyGameDev. Sponsored by UMLAUT.FYI! (https://umlaut.fyi/) and Pen 15! (https://pen15.site/). Source: https://github.com/playdeezgames/handies-for-cash

Font: DINOBYTE by mby, https://mby.itch.io/dinobyte, CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/), unmodified.

---

**Notes (not for the page)**

- The short description is 108 characters (itch.io allows 120).
- Ship day: `./shippit.sh --push` replaces the `html` channel. The page already embeds the browser build, so Kind of project stays HTML. **Open for the user:** the windows, linux and mac downloads (the 2026 Spectre console builds) are still on the page; Key Seeker and Wonting had theirs removed on ship day. The port does not replace them.
- Set the page's AI generation disclosure to Yes (Code), as for Wonting.
- The "Latest version" line only works once GitHub Pages is live for this repo (`tools/pages.sh`, commit `docs/`, push, enable Pages from `main` `/docs`). If Pages is not live by ship day, leave that line out.
- Upload `assets/cover.png` (new, drawn from the DINOBYTE sheet by `tools/make_cover.py`; the old cover was a screenshot of the Blazor title) and the screenshots in `assets/screenshots/` (rendered from the real game by `tools/make_shots.sh`).
- The share text (og:description) still says "An entry for https://itch.io/jam/soulslike-game-jam-3"; the user may want to fix it in the page settings.
