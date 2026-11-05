package handies

import "core:fmt"

// Pure rules of Handies for Cash!, ported from the VB.NET game (August 2026).
// No platform imports: the clock is an argument, the RNG lives in the Game.
// Everything is plain data (no pointers, no allocations) so saving is a straight copy.
// Deliberate changes from the original are listed in docs/QUIRKS.md.

TITLE :: "Handies for Cash!"
DEFAULT_NAME :: "Olen Kyrpa"
NAME_CAP :: 32
INF :: 1 << 30
MAX_MESSAGES :: 48
MESSAGE_CAP :: 400
AD_DURATION_MS :: 2 * 60 * 1000
SOLICIT_BASE :: 20 // the filth roll is 0..filth+SOLICIT_BASE; below filth fails

Counter :: enum {
	Cash,
	Cash_Per_Handy,
	Filth,
	Handy_Count,
	Health,
	Satiety,
	Stamina,
	Stomach,
}

Counter_State :: struct {
	value, min, max: int,
}

// {start, min, max}. The original's DEBUG build started at 5 health and 5 stomach; this is
// the release build's start.
counter_defaults := [Counter][3]int {
	.Cash           = {0, 0, INF},
	.Cash_Per_Handy = {5, 5, INF},
	.Filth          = {0, 0, INF},
	.Handy_Count    = {0, 0, INF},
	.Health         = {100, 0, 100},
	.Satiety        = {100, 0, 100},
	.Stamina        = {10, 0, 10},
	.Stomach        = {0, 0, 50},
}

counter_names := [Counter]string {
	.Cash           = "cash",
	.Cash_Per_Handy = "cash per handy",
	.Filth          = "filth",
	.Handy_Count    = "handies",
	.Health         = "health",
	.Satiety        = "satiety",
	.Stamina        = "stamina",
	.Stomach        = "stomach",
}

Location :: enum {
	Abandoned_House,
	Outside,
	Dark_Alley,
	Pay_Toilet,
}

location_names := [Location]string {
	.Abandoned_House = "The Abandoned House",
	.Outside         = "Outside",
	.Dark_Alley      = "Dark Alley",
	.Pay_Toilet      = "Pay Toilet",
}

Feature_Kind :: enum {
	Door,
	Stained_Mattress,
	Sink,
	Bin,
}

// A feature is fixed for the whole game: the world never changes shape.
Feature :: struct {
	kind:    Feature_Kind,
	dest:    Location, // doors only
	cash:    int, // what a door costs to go through
	filth:   int, // what sleeping adds, or what washing takes away
	stamina: int, // what washing up costs
}

// Features of each place, in the order the original created them.
@(private = "file")
house_features := [?]Feature{{kind = .Stained_Mattress, filth = 5}, {kind = .Door, dest = .Outside}}
@(private = "file")
outside_features := [?]Feature {
	{kind = .Door, dest = .Dark_Alley},
	{kind = .Bin},
	{kind = .Door, dest = .Pay_Toilet, cash = 1},
	{kind = .Door, dest = .Abandoned_House},
}
@(private = "file")
alley_features := [?]Feature{{kind = .Door, dest = .Outside}}
@(private = "file")
toilet_features := [?]Feature{{kind = .Sink, filth = 3, stamina = 1}, {kind = .Door, dest = .Outside}}

features_at :: proc(l: Location) -> []Feature {
	switch l {
	case .Abandoned_House:
		return house_features[:]
	case .Outside:
		return outside_features[:]
	case .Dark_Alley:
		return alley_features[:]
	case .Pay_Toilet:
		return toilet_features[:]
	}
	return nil
}

// "Door to Outside", "Stained Mattress", ... written into buf.
feature_name :: proc(buf: []u8, f: Feature) -> string {
	switch f.kind {
	case .Door:
		return fmt.bprintf(buf, "Door to %s", location_names[f.dest])
	case .Stained_Mattress:
		return fmt.bprintf(buf, "Stained Mattress")
	case .Sink:
		return fmt.bprintf(buf, "Sink")
	case .Bin:
		return fmt.bprintf(buf, "Bin")
	}
	return ""
}

Item_Kind :: enum {
	Sammich,
}

item_names := [Item_Kind]string {
	.Sammich = "Half-eaten Sammich",
}

ITEM_STOMACH :: [Item_Kind]int {
	.Sammich = 10,
}

Items :: [Item_Kind]int

items_total :: proc(l: ^Items) -> int {
	n := 0
	for k in Item_Kind {
		n += l[k]
	}
	return n
}

Link :: enum {
	None,
	Umlaut,
	Pen15,
	Itch_Profile,
	Dinobyte,
}

link_urls := [Link]string {
	.None         = "",
	.Umlaut       = "https://umlaut.fyi/",
	.Pen15        = "https://pen15.site/",
	.Itch_Profile = "https://thegrumpygamedev.itch.io/",
	.Dinobyte     = "https://mby.itch.io/dinobyte",
}

Message :: struct {
	text: [MESSAGE_CAP]u8,
	len:  int,
	link: Link,
}

Game :: struct {
	rng:          Rng,
	embarked:     bool,
	name:         [NAME_CAP]u8,
	name_len:     int,
	counters:     [Counter]Counter_State,
	location:     Location,
	inventory:    Items,
	ground:       [Location]Items,
	john:         bool, // a John waiting in the Dark Alley
	ad_finish_ms: f64, // 0 means no ad break
	messages:     [MAX_MESSAGES]Message,
	message_count: int,
}

name_of :: proc(g: ^Game) -> string {
	return string(g.name[:g.name_len])
}

// ---------------------------------------------------------------- messages

message_text :: proc(m: ^Message) -> string {
	return string(m.text[:m.len])
}

clear_messages :: proc(g: ^Game) {
	g.message_count = 0
}

@(private = "file")
next_message :: proc(g: ^Game) -> ^Message {
	if g.message_count == MAX_MESSAGES {
		copy(g.messages[:], g.messages[1:])
		g.message_count -= 1
	}
	m := &g.messages[g.message_count]
	g.message_count += 1
	m.len = 0
	m.link = .None
	return m
}

say :: proc(g: ^Game, format: string, args: ..any) {
	m := next_message(g)
	s := fmt.bprintf(m.text[:], format, ..args)
	m.len = len(s)
}

say_link :: proc(g: ^Game, text: string, link: Link) {
	m := next_message(g)
	n := copy(m.text[:], text)
	m.len = n
	m.link = link
}

// ---------------------------------------------------------------- counters

counter :: proc(g: ^Game, c: Counter) -> int {
	return g.counters[c].value
}

counter_set :: proc(g: ^Game, c: Counter, v: int) {
	s := &g.counters[c]
	s.value = clamp(v, s.min, s.max)
}

counter_add :: proc(g: ^Game, c: Counter, delta: int) {
	counter_set(g, c, g.counters[c].value + delta)
}

counter_at_min :: proc(g: ^Game, c: Counter) -> bool {
	return g.counters[c].value <= g.counters[c].min
}

counter_at_max :: proc(g: ^Game, c: Counter) -> bool {
	return g.counters[c].value >= g.counters[c].max
}

counter_capacity :: proc(g: ^Game, c: Counter) -> int {
	return g.counters[c].max - g.counters[c].value
}

// "value/max" for bounded counters, the bare value for open-ended ones.
@(private = "file")
say_counter_now :: proc(g: ^Game, c: Counter) {
	s := g.counters[c]
	if s.max == INF {
		say(g, "%s now has %d %s.", name_of(g), s.value, counter_names[c])
	} else {
		say(g, "%s now has %d/%d %s.", name_of(g), s.value, s.max, counter_names[c])
	}
}

// The original's ChangeStatistic: changes a counter and says so. It reports the change that
// actually happened (the original reported the requested one, even when clamped).
change_stat :: proc(g: ^Game, c: Counter, delta: int) {
	before := counter(g, c)
	counter_add(g, c, delta)
	actual := counter(g, c) - before
	if actual == 0 {
		return
	}
	say(g, "%s %s %d %s.", name_of(g), actual > 0 ? "gains" : "loses", abs(actual), counter_names[c])
	say_counter_now(g, c)
}

is_dead :: proc(g: ^Game) -> bool {
	return counter_at_min(g, .Health)
}

in_ad :: proc(g: ^Game) -> bool {
	return g.ad_finish_ms != 0
}

// ---------------------------------------------------------------- biology

// Every action costs some food: stomach first, then satiety, then health. An action that the
// stomach fully covers lets the body recover one point (satiety, or health once sated).
do_biology :: proc(g: ^Game, amount: int) {
	if is_dead(g) {
		return
	}
	amount := amount
	stomach := min(amount, counter(g, .Stomach))
	change_stat(g, .Stomach, -stomach)
	amount -= stomach
	if amount > 0 {
		satiety := min(amount, counter(g, .Satiety))
		change_stat(g, .Satiety, -satiety)
		amount -= satiety
		if amount > 0 {
			health := min(amount, counter(g, .Health))
			change_stat(g, .Health, -health)
			if is_dead(g) {
				say(g, "%s dies.", name_of(g))
			}
		}
	} else {
		if counter_at_max(g, .Satiety) {
			change_stat(g, .Health, 1)
		} else {
			change_stat(g, .Satiety, 1)
		}
	}
}

// ---------------------------------------------------------------- the world

game_reset :: proc(g: ^Game) {
	rng := g.rng
	g^ = {}
	g.rng = rng
	for c in Counter {
		d := counter_defaults[c]
		g.counters[c] = Counter_State{d[0], d[1], d[2]}
	}
}

// Starts a new game. An empty name gets the original's unused default.
embark :: proc(g: ^Game, chosen_name: string) {
	game_reset(g)
	name := chosen_name
	if len(name) == 0 {
		name = DEFAULT_NAME
	}
	g.name_len = copy(g.name[:], name)
	g.embarked = true
	g.location = .Abandoned_House
	say(g, "Welcome to Handies for Cash!")
	look(g)
}

abandon :: proc(g: ^Game) {
	game_reset(g)
	g.embarked = false
}

look :: proc(g: ^Game) {
	if is_dead(g) {
		say(g, "%s is dead.", name_of(g))
		return
	}
	say(g, "%s is in %s.", name_of(g), location_names[g.location])
	say(g, "Features:")
	buf: [64]u8
	for f in features_at(g.location) {
		say(g, "- %s", feature_name(buf[:], f))
	}
}

look_action :: proc(g: ^Game) {
	clear_messages(g)
	look(g)
}

status :: proc(g: ^Game) {
	clear_messages(g)
	say(g, "Status:")
	say(g, "Cash: %d", counter(g, .Cash))
	say(g, "Handies: %d", counter(g, .Handy_Count))
	stat :: proc(g: ^Game, label: string, c: Counter) {
		say(g, "%s: %d/%d", label, counter(g, c), g.counters[c].max)
	}
	stat(g, "Stamina", .Stamina)
	stat(g, "Health", .Health)
	stat(g, "Satiety", .Satiety)
	stat(g, "Stomach", .Stomach)
	say(g, "Filth: %d", counter(g, .Filth))
}

john_here :: proc(g: ^Game) -> bool {
	return g.john && g.location == .Dark_Alley
}

describe_feature :: proc(g: ^Game, f: Feature) {
	clear_messages(g)
	buf: [64]u8
	say(g, "This is a %s.", feature_name(buf[:], f))
	switch f.kind {
	case .Door:
		if f.cash != 0 {
			say(g, "This costs %d cash to go through.", f.cash)
		}
	case .Stained_Mattress:
		say(g, "Sleeping here adds %d filth.", f.filth)
	case .Sink, .Bin:
	}
}

describe_item :: proc(g: ^Game, k: Item_Kind) {
	clear_messages(g)
	say(g, "It is a %s.", item_names[k])
}

// ---------------------------------------------------------------- verbs

Verb :: enum {
	Solicit, // Dark Alley
	Give_Handy, // John
	Enter, // a door
	Sleep, // the mattress
	Wash_Up, // the sink
	Salvage, // the bin
	Eat, // a sammich
}

verb_names := [Verb]string {
	.Solicit    = "Solicit",
	.Give_Handy = "Give Handy",
	.Enter      = "Enter",
	.Sleep      = "Sleep",
	.Wash_Up    = "Wash Up",
	.Salvage    = "Salvage",
	.Eat        = "Eat",
}

feature_verb :: proc(k: Feature_Kind) -> Verb {
	switch k {
	case .Door:
		return .Enter
	case .Stained_Mattress:
		return .Sleep
	case .Sink:
		return .Wash_Up
	case .Bin:
		return .Salvage
	}
	return .Enter
}

// For feature verbs, target is the feature's index at the current location.
verb_enabled :: proc(g: ^Game, v: Verb, target: int = 0) -> bool {
	has_stamina := !counter_at_min(g, .Stamina)
	switch v {
	case .Solicit:
		return g.location == .Dark_Alley && !g.john && has_stamina
	case .Give_Handy:
		return john_here(g) && has_stamina
	case .Enter, .Sleep, .Wash_Up, .Salvage:
		fs := features_at(g.location)
		if target < 0 || target >= len(fs) || feature_verb(fs[target].kind) != v {
			return false
		}
		f := fs[target]
		#partial switch v {
		case .Enter:
			return f.cash <= counter(g, .Cash)
		case .Wash_Up:
			return counter(g, .Stamina) >= f.stamina
		case .Salvage:
			return has_stamina
		}
		return true
	case .Eat:
		return g.inventory[.Sammich] > 0
	}
	return false
}

// Does nothing when the verb is not enabled. Messages are cleared first, as in the original.
perform :: proc(g: ^Game, v: Verb, target: int = 0) {
	if !verb_enabled(g, v, target) {
		return
	}
	clear_messages(g)
	who := name_of(g)
	switch v {
	case .Solicit:
		filth := counter(g, .Filth)
		if rng_range(&g.rng, 0, filth + SOLICIT_BASE) < filth {
			say(g, "%s's filth interferes with solicitation!", who)
			change_stat(g, .Stamina, -1)
		} else {
			g.john = true
			say(g, "%s manages to solicit John.", who)
		}
		do_biology(g, 1)
		look(g)

	case .Give_Handy:
		change_stat(g, .Stamina, -1)
		change_stat(g, .Filth, 1)
		say(g, "%s gives John a handy.", who)
		counter_add(g, .Handy_Count, 1)
		n := counter(g, .Handy_Count)
		say(g, "%s has given %d %s.", who, n, n == 1 ? "handy" : "handies")
		change_stat(g, .Cash, counter(g, .Cash_Per_Handy))
		g.john = false
		do_biology(g, 1)

	case .Enter:
		f := features_at(g.location)[target]
		buf: [64]u8
		change_stat(g, .Cash, -f.cash)
		say(g, "%s enters %s through %s.", who, location_names[f.dest], feature_name(buf[:], f))
		g.location = f.dest
		look(g)

	case .Sleep:
		f := features_at(g.location)[target]
		buf: [64]u8
		say(g, "%s sleeps on %s.", who, feature_name(buf[:], f))
		// The original measured the hours after topping stamina up, so sleep cost nothing.
		hours := counter_capacity(g, .Stamina)
		change_stat(g, .Stamina, hours)
		change_stat(g, .Filth, f.filth)
		do_biology(g, hours)

	case .Wash_Up:
		f := features_at(g.location)[target]
		change_stat(g, .Stamina, -f.stamina)
		change_stat(g, .Filth, -f.filth)
		do_biology(g, 1)

	case .Salvage:
		buf: [64]u8
		say(g, "%s salvages in %s.", who, feature_name(buf[:], features_at(g.location)[target]))
		g.inventory[.Sammich] += 1
		say(g, "%s finds %s.", who, item_names[.Sammich])
		do_biology(g, 1)

	case .Eat:
		say(g, "%s eats %s.", who, item_names[.Sammich])
		change_stat(g, .Stomach, ITEM_STOMACH[.Sammich])
		g.inventory[.Sammich] -= 1
	}
}

// ---------------------------------------------------------------- items

take_items :: proc(g: ^Game, k: Item_Kind, count: int) {
	n := min(count, g.ground[g.location][k])
	if n <= 0 {
		return
	}
	clear_messages(g)
	if count == 1 {
		say(g, "%s takes %s.", name_of(g), item_names[k])
	} else {
		say(g, "%s takes %d %s.", name_of(g), n, item_names[k])
	}
	g.ground[g.location][k] -= n
	g.inventory[k] += n
}

drop_items :: proc(g: ^Game, k: Item_Kind, count: int) {
	n := min(count, g.inventory[k])
	if n <= 0 {
		return
	}
	clear_messages(g)
	if count == 1 {
		say(g, "%s drops %s.", name_of(g), item_names[k])
	} else {
		say(g, "%s drops %d %s.", name_of(g), n, item_names[k])
	}
	g.inventory[k] -= n
	g.ground[g.location][k] += n
}

// ---------------------------------------------------------------- ad break

ad_start :: proc(g: ^Game, now_ms: f64) {
	g.ad_finish_ms = now_ms + AD_DURATION_MS
}

ad_show :: proc(g: ^Game, now_ms: f64) {
	clear_messages(g)
	if g.ad_finish_ms > now_ms {
		left := int((g.ad_finish_ms - now_ms) / 1000)
		say(g, "Time left in ad break: %02d:%02d", left / 60, left % 60)
		say(g, "(This is a turn based game. As such, this counter will not automatically change. You have to click the OK button to refresh.)")
		if rng_range(&g.rng, 0, 1) == 0 {
			say_link(g, "For all yer umlauting needs! umlaut.fyi", .Umlaut)
		} else {
			say_link(g, "Everybody loves Pen 15!", .Pen15)
		}
	} else {
		say(g, "Ad break is complete! You may return to yer metaphor!")
		g.ad_finish_ms = 0
	}
}
