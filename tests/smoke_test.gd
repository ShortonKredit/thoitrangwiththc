extends SceneTree

const ItemCatalogScript = preload("res://scripts/core/item_catalog.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var catalog = ItemCatalogScript.new()
	_assert(catalog.load_catalog() == OK, "Catalog phải tải thành công")
	_assert(catalog.get_category_ids().size() == 9, "Catalog phải có 9 category")
	_assert(catalog.items.size() >= 35, "Catalog phải có ít nhất 35 item")

	var state = GameStateScript.new()
	state.initialize(catalog)
	_assert(state.selected["top"] == "top_blouse", "Top mặc định phải là blouse")
	_assert(state.selected["dress"] == "dress_none", "Dress mặc định phải là none")

	state.select_item("dress_casual")
	_assert(state.selected["dress"] == "dress_casual", "Phải chọn được dress")
	_assert(state.selected["top"] == "top_none", "Dress phải tháo top")
	_assert(state.selected["bottom"] == "bottom_none", "Dress phải tháo bottom")

	state.select_item("top_tee")
	_assert(state.selected["top"] == "top_tee", "Phải chọn được top")
	_assert(state.selected["dress"] == "dress_none", "Top phải tháo dress")

	state.set_lock("hair", true)
	var hair_before: String = state.selected["hair"]
	state.randomize()
	_assert(state.selected["hair"] == hair_before, "Random phải giữ category bị khóa")

	var snapshot_before := state.snapshot()
	state.select_item("shoes_flats")
	_assert(state.can_undo(), "Phải undo được sau thay đổi")
	state.undo()
	_assert(state.snapshot() == snapshot_before, "Undo phải khôi phục toàn state")
	state.redo()
	_assert(state.selected["shoes"] == "shoes_flats", "Redo phải áp dụng lại item")

	if failures.is_empty():
		print("SMOKE TEST PASSED")
		quit(0)
	else:
		for failure in failures:
			push_error("TEST FAILED: %s" % failure)
		quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
