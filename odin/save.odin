package handies

import "core:encoding/json"
import "core:fmt"
import "core:mem"
import "core:strconv"

// Saving (new in the port; the original never saved): a versioned JSON document. Enums are
// stored as integers and every field is range-checked on load; a failed load leaves the
// game untouched.

SAVE_VERSION :: 1
SAVE_MESSAGES :: 24

Save_Message :: struct {
	text: string,
	link: int,
}

Save_Data :: struct {
	version:      int,
	rng:          string, // hex, JSON numbers lose the top bits of a u64
	embarked:     bool,
	name:         string,
	counters:     [len(Counter)]int,
	location:     int,
	inventory:    [len(Item_Kind)]int,
	ground:       [len(Location)][len(Item_Kind)]int,
	john:         bool,
	ad_finish_ms: f64,
	messages:     []Save_Message,
}

// Scratch space for encode and decode (never both at once).
@(private = "file")
scratch: [1 << 17]u8

@(private = "file")
scratch_allocator :: proc() -> mem.Allocator {
	@(static) arena: mem.Arena
	mem.arena_init(&arena, scratch[:])
	return mem.arena_allocator(&arena)
}

// The result lives in a package buffer until the next save_encode or save_decode.
save_encode :: proc(g: ^Game) -> (text: string, ok: bool) {
	alloc := scratch_allocator()
	d: Save_Data
	d.version = SAVE_VERSION
	d.rng = fmt.aprintf("%x", g.rng.state, allocator = alloc)
	d.embarked = g.embarked
	d.name = name_of(g)
	for c in Counter {
		d.counters[int(c)] = g.counters[c].value
	}
	d.location = int(g.location)
	for k in Item_Kind {
		d.inventory[int(k)] = g.inventory[k]
		for l in Location {
			d.ground[int(l)][int(k)] = g.ground[l][k]
		}
	}
	d.john = g.john
	d.ad_finish_ms = g.ad_finish_ms
	keep := min(g.message_count, SAVE_MESSAGES)
	first := g.message_count - keep
	messages := make([]Save_Message, keep, alloc)
	for i in 0 ..< keep {
		m := &g.messages[first + i]
		messages[i] = Save_Message{message_text(m), int(m.link)}
	}
	d.messages = messages

	data, err := json.marshal(d, {}, alloc)
	if err != nil {
		return "", false
	}
	return string(data), true
}

// Replaces g only if the whole document is valid.
save_decode :: proc(g: ^Game, text: string) -> bool {
	alloc := scratch_allocator()
	d: Save_Data
	if json.unmarshal(transmute([]u8)text, &d, allocator = alloc) != nil {
		return false
	}
	if d.version != SAVE_VERSION {
		return false
	}
	out: Game
	state, state_ok := strconv.parse_u64_of_base(d.rng, 16)
	if !state_ok {
		return false
	}
	out.rng.state = state
	out.embarked = d.embarked
	if len(d.name) == 0 || len(d.name) > NAME_CAP {
		return false
	}
	out.name_len = copy(out.name[:], d.name)
	for c in Counter {
		def := counter_defaults[c]
		v := d.counters[int(c)]
		if v < def[1] || v > def[2] {
			return false
		}
		out.counters[c] = Counter_State{v, def[1], def[2]}
	}
	if d.location < 0 || d.location >= len(Location) {
		return false
	}
	out.location = Location(d.location)
	for k in Item_Kind {
		n := d.inventory[int(k)]
		if n < 0 || n > INF {
			return false
		}
		out.inventory[k] = n
		for l in Location {
			m := d.ground[int(l)][int(k)]
			if m < 0 || m > INF {
				return false
			}
			out.ground[l][k] = m
		}
	}
	out.john = d.john
	if d.ad_finish_ms < 0 {
		return false
	}
	out.ad_finish_ms = d.ad_finish_ms
	if len(d.messages) > MAX_MESSAGES {
		return false
	}
	for s in d.messages {
		if s.link < 0 || s.link >= len(Link) {
			return false
		}
		m := &out.messages[out.message_count]
		out.message_count += 1
		m.len = copy(m.text[:], s.text)
		m.link = Link(s.link)
	}
	g^ = out
	return true
}
