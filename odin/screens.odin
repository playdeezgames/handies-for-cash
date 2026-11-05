package handies

import "core:fmt"

// The menu state machine. Every screen is: some messages, a prompt, and either a list of
// choices or a line of text to type. Entering a screen runs its side effects and rebuilds
// its choices, so a screen is always consistent with the game state.

Screen :: enum {
	Title,
	Main_Menu,
	Credits,
	Name_Prompt,
	Play,
	Dead,
	Ad,
	Game_Menu,
	Confirm_Abandon,
	Character,
	Feature,
	Item_List,
	Item_Stack,
	Item_Menu,
	Verb_Result,
}

Item_Source :: enum {
	Ground,
	Inventory,
}

Choice_Kind :: enum {
	Go, // a = Screen
	Location_Verb, // a = Verb
	Character_Verb, // a = Verb
	Feature_Verb, // a = Verb
	Item_Verb, // a = Verb
	Pick_Character,
	Pick_Feature, // a = feature index at the location
	Status,
	Look,
	Watch_Ad,
	Abandon_Yes,
	Open_Link, // a = Link
	Open_List, // a = Item_Source
	Pick_Stack, // a = Item_Kind
	Pick_Item, // opens the item menu for ui.sel_kind
	Move_Many, // a = count; takes or drops ui.sel_kind
	Move_One,
}

MAX_CHOICES :: 40

Choice :: struct {
	label: [64]u8,
	len:   int,
	kind:  Choice_Kind,
	a:     int,
}

Ui :: struct {
	screen:        Screen,
	after:         Screen, // where Verb_Result returns to
	src:           Item_Source,
	sel_feature:   int,
	sel_kind:      Item_Kind,
	choices:       [MAX_CHOICES]Choice,
	choice_count:  int,
	cursor:        int,
	prompt:        [96]u8,
	prompt_len:    int,
	typing:        bool,
	text:          [NAME_CAP]u8,
	text_len:      int,
	hide_messages: bool,
	scroll:        int, // wrapped lines scrolled back from the newest
}

// ---------------------------------------------------------------- building a screen

@(private = "file")
set_prompt :: proc(ui: ^Ui, format: string, args: ..any) {
	s := fmt.bprintf(ui.prompt[:], format, ..args)
	ui.prompt_len = len(s)
}

@(private = "file")
add_choice :: proc(ui: ^Ui, kind: Choice_Kind, a: int, format: string, args: ..any) {
	if ui.choice_count >= MAX_CHOICES {
		return
	}
	c := &ui.choices[ui.choice_count]
	ui.choice_count += 1
	s := fmt.bprintf(c.label[:], format, ..args)
	c.len = len(s)
	c.kind = kind
	c.a = a
}

choice_label :: proc(c: ^Choice) -> string {
	return string(c.label[:c.len])
}

@(private = "file")
go :: proc(ui: ^Ui, label: string, s: Screen) {
	add_choice(ui, .Go, int(s), "%s", label)
}

play_screen :: proc(g: ^Game) -> Screen {
	if in_ad(g) {
		return .Ad
	}
	if is_dead(g) {
		return .Dead
	}
	return .Play
}

@(private = "file")
list_for :: proc(a: ^App) -> ^Items {
	g := &a.game
	return a.ui.src == .Inventory ? &g.inventory : &g.ground[g.location]
}

ui_enter :: proc(a: ^App, screen: Screen) {
	g := &a.game
	ui := &a.ui
	ui.screen = screen
	ui.choice_count = 0
	ui.cursor = 0
	ui.scroll = 0
	ui.prompt_len = 0
	ui.typing = false
	ui.hide_messages = false

	switch screen {
	case .Title:
		clear_messages(g)
		say(g, "%s", TITLE)
		say(g, "A Production of TheGrumpyGameDev")
		say(g, "Sponsored by: UMLAUT.FYI!")
		say(g, "New Sponsor! Pen 15!")
		go(ui, "OK", .Main_Menu)
		add_choice(ui, .Open_Link, int(Link.Itch_Profile), "TheGrumpyGameDev")
		add_choice(ui, .Open_Link, int(Link.Umlaut), "UMLAUT.FYI!")
		add_choice(ui, .Open_Link, int(Link.Pen15), "Pen 15!")

	case .Main_Menu:
		ui.hide_messages = true
		set_prompt(ui, "Main Menu:")
		go(ui, "Embark!", .Name_Prompt)
		go(ui, "Credits", .Credits)

	case .Credits:
		clear_messages(g)
		say(g, "%s", TITLE)
		say(g, "Written by TheGrumpyGameDev in August 2026.")
		say(g, "Font: DINOBYTE by mby, CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). Used unmodified.")
		say(g, "Sponsored by UMLAUT.FYI! and Pen 15!")
		say(g, "Ported to Odin and WebAssembly with Claude, an AI agent, in November 2026.")
		go(ui, "Ok", .Main_Menu)
		add_choice(ui, .Open_Link, int(Link.Dinobyte), "DINOBYTE")
		add_choice(ui, .Open_Link, int(Link.Umlaut), "UMLAUT.FYI!")
		add_choice(ui, .Open_Link, int(Link.Pen15), "Pen 15!")

	case .Name_Prompt:
		ui.hide_messages = true
		ui.typing = true
		ui.text_len = 0
		set_prompt(ui, "What is your name?")

	case .Play:
		set_prompt(ui, "Now What?")
		if verb_enabled(g, .Solicit) {
			add_choice(ui, .Location_Verb, int(Verb.Solicit), "%s", verb_names[.Solicit])
		}
		add_choice(ui, .Status, 0, "Status...")
		if items_total(&g.ground[g.location]) > 0 {
			add_choice(ui, .Open_List, int(Item_Source.Ground), "Ground...")
		}
		if items_total(&g.inventory) > 0 {
			add_choice(ui, .Open_List, int(Item_Source.Inventory), "Inventory...")
		}
		if john_here(g) {
			add_choice(ui, .Pick_Character, 0, "John...")
		}
		buf: [64]u8
		for f, i in features_at(g.location) {
			add_choice(ui, .Pick_Feature, i, "%s...", feature_name(buf[:], f))
		}
		add_choice(ui, .Look, 0, "Look")
		add_choice(ui, .Watch_Ad, 0, "Watch Ad...")
		go(ui, "Gämë Mënü", .Game_Menu)

	case .Dead:
		set_prompt(ui, "Now What?")
		add_choice(ui, .Status, 0, "Status...")
		add_choice(ui, .Look, 0, "Look")
		add_choice(ui, .Watch_Ad, 0, "Watch Ad...")
		go(ui, "Gämë Mënü", .Game_Menu)

	case .Ad:
		ad_show(g, a.now_ms)
		go(ui, "Ok", .Play)

	case .Game_Menu:
		ui.hide_messages = true
		set_prompt(ui, "Game Menu:")
		go(ui, "Continue", .Play)
		go(ui, "Abandon", .Confirm_Abandon)

	case .Confirm_Abandon:
		ui.hide_messages = true
		set_prompt(ui, "Are you sure you want to abandon?")
		go(ui, "No", .Play)
		add_choice(ui, .Abandon_Yes, 0, "Yes")

	case .Character:
		if !john_here(g) {
			ui_enter(a, play_screen(g))
			return
		}
		clear_messages(g)
		set_prompt(ui, "Do what with John?")
		go(ui, "Never Mind", .Play)
		if verb_enabled(g, .Give_Handy) {
			add_choice(ui, .Character_Verb, int(Verb.Give_Handy), "%s", verb_names[.Give_Handy])
		}

	case .Feature:
		fs := features_at(g.location)
		if ui.sel_feature < 0 || ui.sel_feature >= len(fs) {
			ui_enter(a, play_screen(g))
			return
		}
		f := fs[ui.sel_feature]
		describe_feature(g, f)
		buf: [64]u8
		set_prompt(ui, "Do what with %s?", feature_name(buf[:], f))
		go(ui, "Never Mind", .Play)
		v := feature_verb(f.kind)
		if verb_enabled(g, v, ui.sel_feature) {
			add_choice(ui, .Feature_Verb, int(v), "%s", verb_names[v])
		}

	case .Item_List:
		l := list_for(a)
		if items_total(l) == 0 {
			ui_enter(a, play_screen(g))
			return
		}
		set_prompt(ui, ui.src == .Inventory ? "Inventory:" : "On the ground:")
		go(ui, "Never Mind", .Play)
		for k in Item_Kind {
			if l[k] > 0 {
				add_choice(ui, .Pick_Stack, int(k), "%s(x%d)", item_names[k], l[k])
			}
		}

	case .Item_Stack:
		l := list_for(a)
		count := l[ui.sel_kind]
		if count == 0 {
			ui_enter(a, .Item_List)
			return
		}
		if count == 1 {
			ui_enter(a, .Item_Menu)
			return
		}
		set_prompt(ui, "Items in stack:")
		go(ui, "Never Mind", .Item_List)
		verb := ui.src == .Inventory ? "Drop" : "Take"
		add_choice(ui, .Move_Many, 1, "%s One", verb)
		if count > 3 {
			add_choice(ui, .Move_Many, count / 2, "%s Half(%d)", verb, count / 2)
		}
		add_choice(ui, .Move_Many, count, "%s All", verb)
		add_choice(ui, .Pick_Item, 0, "%s", item_names[ui.sel_kind])

	case .Item_Menu:
		l := list_for(a)
		if l[ui.sel_kind] == 0 {
			ui_enter(a, .Item_List)
			return
		}
		set_prompt(ui, "Do what with %s?", item_names[ui.sel_kind])
		if ui.src == .Inventory {
			describe_item(g, ui.sel_kind)
			go(ui, "Never Mind", .Item_List)
			add_choice(ui, .Move_One, 0, "Drop")
			if verb_enabled(g, .Eat) {
				add_choice(ui, .Item_Verb, int(Verb.Eat), "%s", verb_names[.Eat])
			}
		} else {
			go(ui, "Never Mind", .Item_List)
			add_choice(ui, .Move_One, 0, "Take")
		}

	case .Verb_Result:
		go(ui, "Ok", ui.after)
	}

	// Links inside messages become choices too, so they work from the keyboard.
	if !ui.hide_messages && !ui.typing && screen != .Title && screen != .Credits {
		for i in 0 ..< g.message_count {
			m := &g.messages[i]
			if m.link != .None {
				add_choice(ui, .Open_Link, int(m.link), "Visit: %s", message_text(m))
			}
		}
	}
}

// ---------------------------------------------------------------- acting on a choice

ui_choose :: proc(a: ^App, index: int) {
	ui := &a.ui
	g := &a.game
	if index < 0 || index >= ui.choice_count {
		return
	}
	c := ui.choices[index]
	switch c.kind {
	case .Go:
		if Screen(c.a) == .Play {
			ui_enter(a, play_screen(g))
		} else {
			ui_enter(a, Screen(c.a))
		}
	case .Location_Verb, .Feature_Verb:
		perform(g, Verb(c.a), ui.sel_feature if c.kind == .Feature_Verb else 0)
		ui_enter(a, play_screen(g))
	case .Character_Verb:
		perform(g, Verb(c.a))
		ui.after = .Character
		ui_enter(a, .Verb_Result)
	case .Item_Verb:
		perform(g, Verb(c.a))
		ui.after = .Play
		ui_enter(a, .Verb_Result)
	case .Pick_Character:
		ui_enter(a, .Character)
	case .Pick_Feature:
		ui.sel_feature = c.a
		ui_enter(a, .Feature)
	case .Status:
		status(g)
		ui_enter(a, play_screen(g))
	case .Look:
		look_action(g)
		ui_enter(a, play_screen(g))
	case .Watch_Ad:
		ad_start(g, a.now_ms)
		ui_enter(a, play_screen(g))
	case .Abandon_Yes:
		abandon(g)
		ui_enter(a, .Main_Menu)
	case .Open_Link:
		a.open_link = Link(c.a)
	case .Open_List:
		ui.src = Item_Source(c.a)
		ui_enter(a, .Item_List)
	case .Pick_Stack:
		ui.sel_kind = Item_Kind(c.a)
		ui_enter(a, .Item_Stack)
	case .Pick_Item:
		ui_enter(a, .Item_Menu)
	case .Move_Many:
		move(a, c.a)
		ui_enter(a, .Item_Stack)
	case .Move_One:
		move(a, 1)
		ui_enter(a, .Item_List)
	}
}

@(private = "file")
move :: proc(a: ^App, count: int) {
	if a.ui.src == .Inventory {
		drop_items(&a.game, a.ui.sel_kind, count)
	} else {
		take_items(&a.game, a.ui.sel_kind, count)
	}
}

// ---------------------------------------------------------------- input

choice_hotkey :: proc(i: int) -> u8 {
	if i < 9 {
		return u8('1' + i)
	}
	return u8('a' + (i - 9))
}

app_key :: proc(a: ^App, key: i32) {
	ui := &a.ui
	if ui.typing {
		switch Key(key) {
		case .Enter:
			embark(&a.game, string(ui.text[:ui.text_len]))
			ui_enter(a, play_screen(&a.game))
		case .Backspace:
			if ui.text_len > 0 {
				ui.text_len -= 1
			}
		case .Escape:
			ui_enter(a, .Main_Menu)
		case .Up, .Down, .Left, .Right, .Page_Up, .Page_Down, .None:
		case:
			if key >= 32 && key < 127 && ui.text_len < len(ui.text) {
				ui.text[ui.text_len] = u8(key)
				ui.text_len += 1
			}
		}
		return
	}
	switch Key(key) {
	case .Up:
		if ui.choice_count > 0 {
			ui.cursor = (ui.cursor + ui.choice_count - 1) % ui.choice_count
		}
	case .Down:
		if ui.choice_count > 0 {
			ui.cursor = (ui.cursor + 1) % ui.choice_count
		}
	case .Enter:
		ui_choose(a, ui.cursor)
	case .Escape:
		if ui.choice_count > 0 {
			label := choice_label(&ui.choices[0])
			if label == "Never Mind" || label == "No" {
				ui_choose(a, 0)
			}
		}
	case .Page_Up:
		ui.scroll += 4
	case .Page_Down:
		ui.scroll = max(ui.scroll - 4, 0)
	case .Left, .Right, .Backspace, .None:
	case:
		k := key
		if k >= 'A' && k <= 'Z' {
			k += 32
		}
		for i in 0 ..< ui.choice_count {
			if i32(choice_hotkey(i)) == k {
				ui_choose(a, i)
				return
			}
		}
	}
}

// ---------------------------------------------------------------- drawing

MSG_LEFT :: 1

Wrapped :: struct {
	msg:        int,
	start, end: int,
}

// Where the choice list begins and how many rows it shows (set by app_draw, used by taps).
choice_layout :: proc(ui: ^Ui, grid_rows: int) -> (first_row, rows, first_index: int) {
	if ui.typing {
		return grid_rows - 2, 1, 0
	}
	rows = min(ui.choice_count, grid_rows - 8)
	first_row = grid_rows - 1 - rows
	if ui.choice_count > rows {
		first_index = clamp(ui.cursor - rows / 2, 0, ui.choice_count - rows)
	}
	return
}

app_draw :: proc(a: ^App, grid: ^Grid) {
	g := &a.game
	ui := &a.ui
	grid_clear(grid)

	grid.cols = a.cols
	grid.rows = a.rows
	msg_width := a.cols - 2
	first_row, rows, first_index := choice_layout(ui, a.rows)
	prompt_row := first_row - 1
	msg_bottom := prompt_row - 2 // blank row above the prompt

	// Messages: wrapped, newest at the bottom, PageUp scrolls back.
	if !ui.hide_messages {
		lines: [512]Wrapped
		n := 0
		text: [MESSAGE_CAP]u8
		for i in 0 ..< g.message_count {
			m := &g.messages[i]
			len_ := cp437_encode(text[:], message_text(m))
			start := 0
			for {
				end, next := wrap_line(text[:len_], start, msg_width)
				if n < len(lines) {
					lines[n] = Wrapped{i, start, end}
					n += 1
				}
				if next >= len_ {
					break
				}
				start = next
			}
		}
		avail := msg_bottom + 1
		max_scroll := max(n - avail, 0)
		ui.scroll = min(ui.scroll, max_scroll)
		last := n - 1 - ui.scroll
		row := msg_bottom
		for li := last; li >= 0 && row >= 0; li -= 1 {
			w := lines[li]
			m := &g.messages[w.msg]
			len_ := cp437_encode(text[:], message_text(m))
			ink := u8(Ink.Default)
			if m.link != .None {
				ink = u8(Ink.Cyan)
			} else if ui.screen == .Title && w.msg == 0 {
				ink = u8(Ink.Yellow)
			}
			grid_bytes(grid, MSG_LEFT, row, text[w.start:min(w.end, len_)], ink)
			row -= 1
		}
		if ui.scroll > 0 {
			grid_text(grid, a.cols - 14, 0, "(PgDn: newer)", u8(Ink.Gray))
		}
		if last - avail + 1 > 0 {
			grid_text(grid, a.cols - 14, 0, "(PgUp: older)", u8(Ink.Gray))
		}
	}

	// Prompt and choices.
	if ui.prompt_len > 0 {
		grid_text(grid, MSG_LEFT, prompt_row, string(ui.prompt[:ui.prompt_len]), u8(Ink.Yellow))
	}
	if ui.typing {
		row := first_row
		c := grid_text(grid, MSG_LEFT, row, "> ", u8(Ink.White))
		grid_bytes(grid, c, row, ui.text[:ui.text_len], u8(Ink.White))
		grid_put(grid, c + ui.text_len, row, '_', u8(Ink.Yellow))
		return
	}
	for r in 0 ..< rows {
		i := first_index + r
		ch := &ui.choices[i]
		ink := u8(Ink.Default)
		if ch.kind == .Open_Link {
			ink = u8(Ink.Cyan)
		}
		attr := ink
		if i == ui.cursor {
			attr |= ATTR_INVERSE
		}
		row := first_row + r
		// Fill the whole row so the selection reads as a bar.
		if i == ui.cursor {
			for c in MSG_LEFT ..< a.cols - 1 {
				grid_put(grid, c, row, ' ', attr)
			}
		}
		grid_put(grid, MSG_LEFT, row, choice_hotkey(i), attr)
		grid_put(grid, MSG_LEFT + 1, row, '.', attr)
		grid_text(grid, MSG_LEFT + 3, row, choice_label(ch), attr)
	}
	if ui.choice_count > rows {
		if first_index > 0 {
			grid_put(grid, a.cols - 2, first_row, 0x18, u8(Ink.Gray))
		}
		if first_index + rows < ui.choice_count {
			grid_put(grid, a.cols - 2, first_row + rows - 1, 0x19, u8(Ink.Gray))
		}
	}
}

// A tap or click on a grid cell: selects and activates the choice under it.
app_tap :: proc(a: ^App, col, row: int) {
	ui := &a.ui
	if ui.typing {
		return
	}
	first_row, rows, first_index := choice_layout(ui, a.rows)
	if row >= first_row && row < first_row + rows {
		ui_choose(a, first_index + (row - first_row))
	}
}

// True when the page should bring up a keyboard (touch devices).
app_wants_text :: proc(a: ^App) -> bool {
	return a.ui.typing
}
