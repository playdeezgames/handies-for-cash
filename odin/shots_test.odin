#+build !js
package handies

import "core:fmt"
import "core:os"
import "core:testing"

// tools/make_shots.sh runs this with -define:DUMP_DIR=<dir>; it writes the real game's grid for a
// few screens as raw cells (cols, rows, then a glyph and an attribute byte per cell), which the
// tool turns into PNGs with the font sheet. Without DUMP_DIR it does nothing.
DUMP_DIR :: #config(DUMP_DIR, "")

@(private = "file")
dump :: proc(a: ^App, name: string) {
	grid := new(Grid)
	defer free(grid)
	app_draw(a, grid)
	buf := make([dynamic]u8, 0, 2 + MAX_ROWS * MAX_COLS * 2)
	defer delete(buf)
	append(&buf, u8(grid.cols), u8(grid.rows))
	for r in 0 ..< grid.rows {
		for c in 0 ..< grid.cols {
			append(&buf, grid.cells[r][c].ch, grid.cells[r][c].attr)
		}
	}
	path := fmt.tprintf("%s/%s.cells", DUMP_DIR, name)
	_ = os.write_entire_file(path, buf[:])
}

@(test)
dump_screens :: proc(t: ^testing.T) {
	when DUMP_DIR == "" {
		return
	}
	a: App
	app_init(&a, 2026, 0)
	dump(&a, "01-title")

	embark(&a.game, "Olen Kyrpa")
	ui_enter(&a, .Play)
	dump(&a, "02-house")

	perform(&a.game, .Enter, 1) // Door to Outside
	perform(&a.game, .Enter, 0) // Door to Dark Alley
	perform(&a.game, .Solicit)
	ui_enter(&a, .Play)
	dump(&a, "03-alley")

	perform(&a.game, .Give_Handy)
	a.ui.after = .Character
	ui_enter(&a, .Verb_Result)
	dump(&a, "04-handy")

	status(&a.game)
	ui_enter(&a, .Play)
	dump(&a, "05-status")

	ad_start(&a.game, 0)
	a.now_ms = 47_000
	ui_enter(&a, play_screen(&a.game))
	dump(&a, "06-ad")
}
