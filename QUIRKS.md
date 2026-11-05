# Quirks of the original, and what the port did with them

The original is the VB.NET game in `src/` (August 22 to 25, 2026). The user's rule for this port (November 5, 2026): **fix quirks as we go and log them here**, keep the message voice and the deliberate design. Each entry says what the original did and what the port does.

## Fixed

1. **Sleeping cost nothing.** `HandleSleep` filled stamina first and then ran biology on the stamina still missing, which by then was 0. A zero-cost biology tick counts as "covered", so a night on the mattress gave +1 satiety (or +1 health). The port measures the hours before topping stamina up: sleeping from 4 stamina costs 6 food, from the stomach first as everything else does.
2. **Messages reported the requested change, not the real one.** `ChangeStatistic` said "gains 10 stomach" at 45/50, or "loses 3 filth" with 1 filth left. The port reports what actually changed and says nothing when nothing changed (for example the +1 health of a covered action at full health).
3. **"has given 1 handies."** Now "1 handy"; 2 and up are still "handies".
4. **An empty name.** The original had a `DEFAULT_NAME` of "Olen Kyrpa" that nothing used, so an empty name gave an empty name. The port uses it.
5. **The DEBUG start** (5 health, 5 stomach) is gone; the port starts with the release values (100 health, 100 satiety, 0 stomach, 10 stamina).
6. **Item stacks listed every item.** The stack menu offered one entry per sammich after Take/Drop One, Half and All, so a pile of 30 gave 30 identical lines. The port lists the item once (it opens the same item menu). Stack names keep the original's `Half-eaten Sammich(x3)`.

## Added

- **Saving.** The original never saved (`World.Save` existed and nothing called it). The port saves to the browser's local storage after every choice and resumes straight into play.
- **A Credits screen** on the main menu (the font's CC BY credit, the sponsors, the port).
- **Phones:** a portrait layout (36 by 54) when the window is tall, and tapping a choice picks it.

## Removed

- **Quit** on the main menu (the browser version was never quittable in the original either: the Blazor build hid it).
- The Windows, macOS and Linux (Spectre console) builds are not part of the port. The VB source stays in `src/` for now.

## Kept on purpose

- No goal and no ending: you give handies for cash until you starve. Death leaves you on a short menu (Status, Look, Watch Ad, Gämë Mënü).
- Every action spends one point of food; an action the stomach fully covers lets you recover a point. Salvaging the bin needs stamina but does not spend it, and finds a sammich every time. Washing up costs 1 stamina and takes 3 filth.
- Soliciting fails with chance filth in (filth + 21), costing a stamina; the roll is the original's inclusive `RNG.FromRange(0, filth + 20) < filth`.
- One John at a time, and he waits in the Dark Alley if you leave.
- The pay toilet costs 1 cash to enter and nothing to leave; with no cash its door is listed but has no Enter.
- The 2-minute ad break that only counts down when you press OK, with the umlaut.fyi and Pen 15 sponsor links (one at random each refresh).
- The wordy messages: every stat change says what it gained and what it now has.
