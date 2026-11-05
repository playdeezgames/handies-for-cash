#+build !js
package handies

import "core:testing"

@(test)
save_round_trips_everything :: proc(t: ^testing.T) {
	g := new_test_game(31, "Körmy")
	counter_set(&g, .Cash, 17)
	counter_set(&g, .Filth, 4)
	counter_set(&g, .Health, 63)
	g.inventory[.Sammich] = 3
	g.ground[.Outside][.Sammich] = 2
	g.location = .Dark_Alley
	g.john = true
	ad_start(&g, 5_000)
	say_link(&g, "Everybody loves Pen 15!", .Pen15)
	g.rng.state = 0xFEDC_BA98_7654_3210

	text, ok := save_encode(&g)
	testing.expect(t, ok)
	saved := make([]u8, len(text))
	defer delete(saved)
	copy(saved, text)

	out: Game
	testing.expect(t, save_decode(&out, string(saved)))
	testing.expect_value(t, out.rng.state, g.rng.state)
	testing.expect_value(t, name_of(&out), "Körmy")
	testing.expect_value(t, out.counters, g.counters)
	testing.expect_value(t, out.location, Location.Dark_Alley)
	testing.expect_value(t, out.inventory, g.inventory)
	testing.expect_value(t, out.ground, g.ground)
	testing.expect(t, out.john)
	testing.expect_value(t, out.ad_finish_ms, g.ad_finish_ms)
	testing.expect_value(t, out.message_count, min(g.message_count, SAVE_MESSAGES))
	last := &out.messages[out.message_count - 1]
	testing.expect_value(t, message_text(last), "Everybody loves Pen 15!")
	testing.expect_value(t, last.link, Link.Pen15)
}

@(test)
bad_saves_are_refused_and_leave_the_game_alone :: proc(t: ^testing.T) {
	g := new_test_game()
	counter_set(&g, .Cash, 42)
	bad := []string {
		"",
		"not json",
		`{"version":99}`,
		`{"version":1,"rng":"zz","name":"x"}`,
		`{"version":1,"rng":"1","name":"","embarked":true}`,
		`{"version":1,"rng":"1","name":"x","counters":[0,5,0,0,101,100,10,0]}`,
		`{"version":1,"rng":"1","name":"x","counters":[0,5,0,0,100,100,10,0],"location":9}`,
		`{"version":1,"rng":"1","name":"x","counters":[0,5,0,0,100,100,10,0],"inventory":[-1]}`,
	}
	for s in bad {
		testing.expectf(t, !save_decode(&g, s), "accepted: %s", s)
	}
	testing.expect_value(t, counter(&g, .Cash), 42)
}
