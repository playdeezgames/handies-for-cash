#+build !js
package handies

import "core:testing"

choose_label :: proc(t: ^testing.T, a: ^App, label: string) -> bool {
	for i in 0 ..< a.ui.choice_count {
		if choice_label(&a.ui.choices[i]) == label {
			ui_choose(a, i)
			return true
		}
	}
	testing.expectf(t, false, "no choice %q on %v", label, a.ui.screen)
	return false
}

has_choice :: proc(a: ^App, label: string) -> bool {
	for i in 0 ..< a.ui.choice_count {
		if choice_label(&a.ui.choices[i]) == label {
			return true
		}
	}
	return false
}

type_text :: proc(a: ^App, s: string) {
	for c in transmute([]u8)s {
		app_key(a, i32(c))
	}
	app_key(a, i32(Key.Enter))
}

started_app :: proc() -> App {
	a: App
	app_init(&a, 7, 0)
	return a
}

@(test)
title_to_play :: proc(t: ^testing.T) {
	a := started_app()
	testing.expect_value(t, a.ui.screen, Screen.Title)
	choose_label(t, &a, "OK")
	testing.expect_value(t, a.ui.screen, Screen.Main_Menu)
	choose_label(t, &a, "Embark!")
	testing.expect(t, a.ui.typing)
	type_text(&a, "Tess")
	testing.expect_value(t, a.ui.screen, Screen.Play)
	testing.expect_value(t, name_of(&a.game), "Tess")
	testing.expect(t, has_choice(&a, "Stained Mattress..."))
	testing.expect(t, has_choice(&a, "Door to Outside..."))
	testing.expect(t, has_choice(&a, "Gämë Mënü"))
	testing.expect(t, !has_choice(&a, "Inventory..."))
}

@(test)
a_day_in_the_alley_through_the_menus :: proc(t: ^testing.T) {
	a := started_app()
	choose_label(t, &a, "OK")
	choose_label(t, &a, "Embark!")
	type_text(&a, "")
	testing.expect_value(t, name_of(&a.game), DEFAULT_NAME)
	choose_label(t, &a, "Door to Outside...")
	testing.expect_value(t, a.ui.screen, Screen.Feature)
	choose_label(t, &a, "Enter")
	testing.expect_value(t, a.ui.screen, Screen.Play)
	// Broke: the pay toilet door is listed but cannot be entered.
	choose_label(t, &a, "Door to Pay Toilet...")
	testing.expect(t, !has_choice(&a, "Enter"))
	choose_label(t, &a, "Never Mind")
	choose_label(t, &a, "Door to Dark Alley...")
	choose_label(t, &a, "Enter")
	choose_label(t, &a, "Solicit")
	testing.expect(t, has_choice(&a, "John..."))
	testing.expect(t, !has_choice(&a, "Solicit"))
	choose_label(t, &a, "John...")
	testing.expect_value(t, a.ui.screen, Screen.Character)
	choose_label(t, &a, "Give Handy")
	testing.expect_value(t, a.ui.screen, Screen.Verb_Result)
	choose_label(t, &a, "Ok")
	testing.expect_value(t, a.ui.screen, Screen.Play)
	testing.expect_value(t, counter(&a.game, .Cash), 5)
	testing.expect(t, has_choice(&a, "Solicit"))
}

@(test)
inventory_menus_eat_and_drop :: proc(t: ^testing.T) {
	a := started_app()
	embark(&a.game, "Tess")
	a.game.inventory[.Sammich] = 5
	ui_enter(&a, .Play)
	choose_label(t, &a, "Inventory...")
	choose_label(t, &a, "Half-eaten Sammich(x5)")
	testing.expect_value(t, a.ui.screen, Screen.Item_Stack)
	choose_label(t, &a, "Drop Half(2)")
	testing.expect_value(t, a.game.inventory[.Sammich], 3)
	choose_label(t, &a, "Half-eaten Sammich")
	testing.expect_value(t, a.ui.screen, Screen.Item_Menu)
	choose_label(t, &a, "Eat")
	choose_label(t, &a, "Ok")
	testing.expect_value(t, a.game.inventory[.Sammich], 2)
	testing.expect_value(t, counter(&a.game, .Stomach), 10)
	choose_label(t, &a, "Ground...")
	choose_label(t, &a, "Half-eaten Sammich(x2)")
	choose_label(t, &a, "Take All")
	testing.expect_value(t, a.game.inventory[.Sammich], 4)
	// The stack is gone, so the screen falls back to play.
	testing.expect_value(t, a.ui.screen, Screen.Play)
}

@(test)
the_dead_get_a_short_menu :: proc(t: ^testing.T) {
	a := started_app()
	embark(&a.game, "Tess")
	counter_set(&a.game, .Health, 0)
	ui_enter(&a, play_screen(&a.game))
	testing.expect_value(t, a.ui.screen, Screen.Dead)
	testing.expect_value(t, a.ui.choice_count, 4)
	choose_label(t, &a, "Look")
	testing.expect(t, has_message(&a.game, "Tess is dead."))
}

@(test)
watching_an_ad_offers_the_sponsor_link :: proc(t: ^testing.T) {
	a := started_app()
	embark(&a.game, "Tess")
	ui_enter(&a, .Play)
	choose_label(t, &a, "Watch Ad...")
	testing.expect_value(t, a.ui.screen, Screen.Ad)
	link := false
	for i in 0 ..< a.ui.choice_count {
		link ||= a.ui.choices[i].kind == .Open_Link
	}
	testing.expect(t, link)
	a.now_ms = AD_DURATION_MS + 1
	choose_label(t, &a, "Ok")
	testing.expect_value(t, a.ui.screen, Screen.Ad)
	testing.expect(t, has_message(&a.game, "Ad break is complete!"))
	choose_label(t, &a, "Ok")
	testing.expect_value(t, a.ui.screen, Screen.Play)
}

@(test)
abandon_returns_to_the_main_menu :: proc(t: ^testing.T) {
	a := started_app()
	embark(&a.game, "Tess")
	ui_enter(&a, .Play)
	choose_label(t, &a, "Gämë Mënü")
	choose_label(t, &a, "Abandon")
	choose_label(t, &a, "Yes")
	testing.expect_value(t, a.ui.screen, Screen.Main_Menu)
	testing.expect(t, !a.game.embarked)
}

@(test)
resume_lands_in_play :: proc(t: ^testing.T) {
	a := started_app()
	embark(&a.game, "Tess")
	a.game.location = .Outside
	text, _ := save_encode(&a.game)
	saved := make([]u8, len(text))
	defer delete(saved)
	copy(saved, text)
	b := started_app()
	testing.expect(t, app_resume(&b, string(saved)))
	testing.expect_value(t, b.ui.screen, Screen.Play)
	testing.expect(t, has_choice(&b, "Bin..."))
}

@(test)
every_screen_draws_in_both_layouts :: proc(t: ^testing.T) {
	a := started_app()
	embark(&a.game, "Tess")
	grid := new(Grid)
	defer free(grid)
	for portrait in ([]bool{false, true}) {
		app_set_layout(&a, portrait)
		for s in Screen {
			ui_enter(&a, s)
			app_draw(&a, grid)
		}
	}
}
