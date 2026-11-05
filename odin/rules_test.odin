#+build !js
package handies

import "core:strings"
import "core:testing"

new_test_game :: proc(seed: u64 = 1, name: string = "Tess") -> Game {
	g: Game
	rng_seed(&g.rng, seed)
	embark(&g, name)
	return g
}

has_message :: proc(g: ^Game, text: string) -> bool {
	for i in 0 ..< g.message_count {
		if strings.contains(message_text(&g.messages[i]), text) {
			return true
		}
	}
	return false
}

// Index of the first feature of a kind (and destination, for doors) at the current location.
feature_index :: proc(g: ^Game, kind: Feature_Kind, dest: Location = .Outside) -> int {
	for f, i in features_at(g.location) {
		if f.kind == kind && (kind != .Door || f.dest == dest) {
			return i
		}
	}
	return -1
}

go_to :: proc(g: ^Game, dest: Location) {
	perform(g, .Enter, feature_index(g, .Door, dest))
}

@(test)
embark_starts_in_the_house_with_release_stats :: proc(t: ^testing.T) {
	g := new_test_game()
	testing.expect(t, g.embarked)
	testing.expect_value(t, g.location, Location.Abandoned_House)
	testing.expect_value(t, counter(&g, .Health), 100)
	testing.expect_value(t, counter(&g, .Satiety), 100)
	testing.expect_value(t, counter(&g, .Stomach), 0)
	testing.expect_value(t, counter(&g, .Stamina), 10)
	testing.expect_value(t, counter(&g, .Cash), 0)
	testing.expect_value(t, counter(&g, .Cash_Per_Handy), 5)
	testing.expect(t, has_message(&g, "Welcome to Handies for Cash!"))
	testing.expect(t, has_message(&g, "Tess is in The Abandoned House."))
	testing.expect(t, has_message(&g, "- Stained Mattress"))
	testing.expect(t, has_message(&g, "- Door to Outside"))
}

@(test)
empty_name_gets_the_default :: proc(t: ^testing.T) {
	g := new_test_game(1, "")
	testing.expect_value(t, name_of(&g), DEFAULT_NAME)
}

@(test)
the_world_is_wired_both_ways :: proc(t: ^testing.T) {
	g := new_test_game()
	go_to(&g, .Outside)
	testing.expect_value(t, g.location, Location.Outside)
	testing.expect(t, has_message(&g, "Tess enters Outside through Door to Outside."))
	testing.expect(t, has_message(&g, "- Door to Dark Alley"))
	testing.expect(t, has_message(&g, "- Bin"))
	testing.expect(t, has_message(&g, "- Door to Pay Toilet"))
	testing.expect(t, has_message(&g, "- Door to The Abandoned House"))
	go_to(&g, .Dark_Alley)
	testing.expect_value(t, g.location, Location.Dark_Alley)
	go_to(&g, .Outside)
	go_to(&g, .Abandoned_House)
	testing.expect_value(t, g.location, Location.Abandoned_House)
}

@(test)
the_pay_toilet_costs_a_cash :: proc(t: ^testing.T) {
	g := new_test_game()
	go_to(&g, .Outside)
	door := feature_index(&g, .Door, .Pay_Toilet)
	testing.expect(t, !verb_enabled(&g, .Enter, door))
	perform(&g, .Enter, door)
	testing.expect_value(t, g.location, Location.Outside)
	counter_set(&g, .Cash, 3)
	testing.expect(t, verb_enabled(&g, .Enter, door))
	perform(&g, .Enter, door)
	testing.expect_value(t, g.location, Location.Pay_Toilet)
	testing.expect_value(t, counter(&g, .Cash), 2)
	testing.expect(t, has_message(&g, "Tess loses 1 cash."))
	// The way out is free.
	go_to(&g, .Outside)
	testing.expect_value(t, counter(&g, .Cash), 2)
}

@(test)
biology_eats_stomach_then_satiety_then_health :: proc(t: ^testing.T) {
	g := new_test_game()
	counter_set(&g, .Stomach, 3)
	counter_set(&g, .Satiety, 2)
	counter_set(&g, .Health, 10)
	do_biology(&g, 7)
	testing.expect_value(t, counter(&g, .Stomach), 0)
	testing.expect_value(t, counter(&g, .Satiety), 0)
	testing.expect_value(t, counter(&g, .Health), 8)
}

@(test)
a_covered_action_recovers_a_point :: proc(t: ^testing.T) {
	g := new_test_game()
	counter_set(&g, .Stomach, 5)
	counter_set(&g, .Satiety, 50)
	do_biology(&g, 1)
	testing.expect_value(t, counter(&g, .Stomach), 4)
	testing.expect_value(t, counter(&g, .Satiety), 51)
	counter_set(&g, .Satiety, 100)
	counter_set(&g, .Health, 90)
	do_biology(&g, 1)
	testing.expect_value(t, counter(&g, .Health), 91)
	// With an empty stomach nothing is covered: satiety pays.
	counter_set(&g, .Stomach, 0)
	do_biology(&g, 1)
	testing.expect_value(t, counter(&g, .Satiety), 99)
}

@(test)
starving_kills :: proc(t: ^testing.T) {
	g := new_test_game()
	counter_set(&g, .Satiety, 0)
	counter_set(&g, .Health, 2)
	do_biology(&g, 5)
	testing.expect(t, is_dead(&g))
	testing.expect(t, has_message(&g, "Tess dies."))
	// The dead do not get hungrier.
	do_biology(&g, 5)
	testing.expect_value(t, counter(&g, .Health), 0)
}

@(test)
messages_report_what_actually_changed :: proc(t: ^testing.T) {
	g := new_test_game()
	counter_set(&g, .Stomach, 45)
	g.inventory[.Sammich] = 1
	perform(&g, .Eat)
	testing.expect(t, has_message(&g, "Tess gains 5 stomach."))
	testing.expect(t, has_message(&g, "Tess now has 50/50 stomach."))
	testing.expect_value(t, g.inventory[.Sammich], 0)
}

@(test)
salvage_finds_a_sammich :: proc(t: ^testing.T) {
	g := new_test_game()
	go_to(&g, .Outside)
	bin := feature_index(&g, .Bin)
	perform(&g, .Salvage, bin)
	testing.expect_value(t, g.inventory[.Sammich], 1)
	testing.expect(t, has_message(&g, "Tess salvages in Bin."))
	testing.expect(t, has_message(&g, "Tess finds Half-eaten Sammich."))
	// Salvaging needs stamina but does not spend it.
	testing.expect_value(t, counter(&g, .Stamina), 10)
	counter_set(&g, .Stamina, 0)
	testing.expect(t, !verb_enabled(&g, .Salvage, bin))
}

@(test)
soliciting_a_john_and_giving_a_handy :: proc(t: ^testing.T) {
	g := new_test_game()
	go_to(&g, .Outside)
	go_to(&g, .Dark_Alley)
	testing.expect(t, verb_enabled(&g, .Solicit))
	perform(&g, .Solicit) // no filth yet, so it cannot fail
	testing.expect(t, john_here(&g))
	testing.expect(t, has_message(&g, "Tess manages to solicit John."))
	testing.expect(t, !verb_enabled(&g, .Solicit))
	testing.expect(t, verb_enabled(&g, .Give_Handy))
	perform(&g, .Give_Handy)
	testing.expect(t, !g.john)
	testing.expect_value(t, counter(&g, .Cash), 5)
	testing.expect_value(t, counter(&g, .Handy_Count), 1)
	testing.expect_value(t, counter(&g, .Filth), 1)
	testing.expect_value(t, counter(&g, .Stamina), 9)
	testing.expect(t, has_message(&g, "Tess gives John a handy."))
	testing.expect(t, has_message(&g, "Tess has given 1 handy."))
	counter_set(&g, .Filth, 0) // so the second solicitation cannot fail
	perform(&g, .Solicit)
	perform(&g, .Give_Handy)
	testing.expect(t, has_message(&g, "Tess has given 2 handies."))
	testing.expect_value(t, counter(&g, .Cash), 10)
}

@(test)
john_waits_in_the_alley :: proc(t: ^testing.T) {
	g := new_test_game()
	go_to(&g, .Outside)
	go_to(&g, .Dark_Alley)
	perform(&g, .Solicit)
	go_to(&g, .Outside)
	testing.expect(t, !john_here(&g))
	testing.expect(t, !verb_enabled(&g, .Give_Handy))
	go_to(&g, .Dark_Alley)
	testing.expect(t, john_here(&g))
}

@(test)
filth_spoils_solicitation_sometimes :: proc(t: ^testing.T) {
	g := new_test_game(99)
	go_to(&g, .Outside)
	go_to(&g, .Dark_Alley)
	fails := 0
	for _ in 0 ..< 400 {
		counter_set(&g, .Filth, 20)
		counter_set(&g, .Stamina, 10)
		counter_set(&g, .Satiety, 100)
		g.john = false
		perform(&g, .Solicit)
		if !g.john {
			fails += 1
			testing.expect(t, has_message(&g, "Tess's filth interferes with solicitation!"))
		}
	}
	// 20 in 41.
	testing.expect(t, fails > 140 && fails < 260)
}

@(test)
no_stamina_no_business :: proc(t: ^testing.T) {
	g := new_test_game()
	go_to(&g, .Outside)
	go_to(&g, .Dark_Alley)
	counter_set(&g, .Stamina, 0)
	testing.expect(t, !verb_enabled(&g, .Solicit))
	g.john = true
	testing.expect(t, !verb_enabled(&g, .Give_Handy))
}

@(test)
sleep_restores_stamina_adds_filth_and_costs_food :: proc(t: ^testing.T) {
	g := new_test_game()
	counter_set(&g, .Stamina, 4)
	mattress := feature_index(&g, .Stained_Mattress)
	perform(&g, .Sleep, mattress)
	testing.expect_value(t, counter(&g, .Stamina), 10)
	testing.expect_value(t, counter(&g, .Filth), 5)
	testing.expect_value(t, counter(&g, .Satiety), 94)
	testing.expect(t, has_message(&g, "Tess sleeps on Stained Mattress."))
}

@(test)
washing_up_costs_stamina_and_takes_filth :: proc(t: ^testing.T) {
	g := new_test_game()
	counter_set(&g, .Cash, 1)
	counter_set(&g, .Filth, 5)
	go_to(&g, .Outside)
	go_to(&g, .Pay_Toilet)
	sink := feature_index(&g, .Sink)
	perform(&g, .Wash_Up, sink)
	testing.expect_value(t, counter(&g, .Filth), 2)
	testing.expect_value(t, counter(&g, .Stamina), 9)
	perform(&g, .Wash_Up, sink)
	testing.expect_value(t, counter(&g, .Filth), 0)
	testing.expect(t, has_message(&g, "Tess loses 2 filth."))
	counter_set(&g, .Stamina, 0)
	testing.expect(t, !verb_enabled(&g, .Wash_Up, sink))
}

@(test)
items_move_between_ground_and_inventory :: proc(t: ^testing.T) {
	g := new_test_game()
	g.inventory[.Sammich] = 5
	drop_items(&g, .Sammich, 2)
	testing.expect_value(t, g.inventory[.Sammich], 3)
	testing.expect_value(t, g.ground[.Abandoned_House][.Sammich], 2)
	testing.expect(t, has_message(&g, "Tess drops 2 Half-eaten Sammich."))
	go_to(&g, .Outside)
	testing.expect_value(t, g.ground[.Outside][.Sammich], 0)
	go_to(&g, .Abandoned_House)
	take_items(&g, .Sammich, 1)
	testing.expect_value(t, g.inventory[.Sammich], 4)
	testing.expect(t, has_message(&g, "Tess takes Half-eaten Sammich."))
	take_items(&g, .Sammich, 9)
	testing.expect_value(t, g.ground[.Abandoned_House][.Sammich], 0)
	testing.expect_value(t, g.inventory[.Sammich], 5)
}

@(test)
ad_break_counts_down_and_ends :: proc(t: ^testing.T) {
	g := new_test_game()
	ad_start(&g, 1000)
	testing.expect(t, in_ad(&g))
	ad_show(&g, 1000 + 30_000)
	testing.expect(t, has_message(&g, "Time left in ad break: 01:30"))
	testing.expect_value(t, g.messages[g.message_count - 1].link != .None, true)
	ad_show(&g, 1000 + AD_DURATION_MS)
	testing.expect(t, !in_ad(&g))
	testing.expect(t, has_message(&g, "Ad break is complete!"))
}

@(test)
disabled_verbs_do_nothing :: proc(t: ^testing.T) {
	g := new_test_game()
	before := g
	perform(&g, .Solicit)
	perform(&g, .Give_Handy)
	perform(&g, .Eat)
	perform(&g, .Wash_Up, 0)
	testing.expect_value(t, g.counters, before.counters)
	testing.expect_value(t, g.location, before.location)
}
