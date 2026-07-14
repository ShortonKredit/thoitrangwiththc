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
	_assert(catalog.items.size() == 45, "Catalog baseline phải có 45 item")

	var state = GameStateScript.new()
	state.initialize(catalog)
	_assert_state_compatible(catalog, state, "Initial state không được có xung đột")
	_assert(state.selected["top"] == "top_blouse", "Top mặc định phải là blouse")
	_assert(state.selected["dress"] == "dress_none", "Dress mặc định phải là none")

	state.select_item("dress_casual")
	_assert(state.selected["dress"] == "dress_casual", "Phải chọn được dress")
	_assert(state.selected["top"] == "top_none", "Dress phải tháo top")
	_assert(state.selected["bottom"] == "bottom_none", "Dress phải tháo bottom")
	_assert_state_compatible(catalog, state, "Dress không được để lại top/bottom xung đột")

	state.select_item("top_tee")
	_assert(state.selected["top"] == "top_tee", "Phải chọn được top")
	_assert(state.selected["dress"] == "dress_none", "Top phải tháo dress")
	_assert_state_compatible(catalog, state, "Top không được để lại dress xung đột")

	state.select_item("hair_soft_waves")
	state.select_item("headwear_cap")
	_assert(state.selected["hair"] != "hair_soft_waves", "Cap phải tháo tóc phồng qua conflict tag")
	state.select_item("headwear_none")
	state.select_item("hair_soft_waves")
	state.set_lock("hair", true)
	state.randomize()
	_assert(state.selected["headwear"] != "headwear_cap", "Random không được chọn mũ xung đột với tóc bị khóa")
	_assert_state_compatible(catalog, state, "Random với lock không được tạo xung đột tag")

	var hair_before: String = state.selected["hair"]
	state.randomize()
	_assert(state.selected["hair"] == hair_before, "Random phải giữ category bị khóa")
	_assert_state_compatible(catalog, state, "Random không được tạo state xung đột")

	var snapshot_before := state.snapshot()
	var next_shoes := "shoes_sneakers" if state.selected["shoes"] == "shoes_flats" else "shoes_flats"
	_assert(state.select_item(next_shoes), "Phải đổi được giày để kiểm tra undo/redo")
	_assert(state.can_undo(), "Phải undo được sau thay đổi")
	state.undo()
	_assert(state.snapshot() == snapshot_before, "Undo phải khôi phục toàn state")
	state.redo()
	_assert(state.selected["shoes"] == next_shoes, "Redo phải áp dụng lại item")

	state.reset_to_default(true)
	_assert(state.selected == catalog.get_default_state(), "Reset phải khôi phục selected mặc định")
	_assert(bool(state.locks["hair"]), "Reset keep_locks phải giữ khóa")
	state.undo()
	_assert(state.selected["shoes"] == next_shoes, "Undo sau reset phải khôi phục outfit trước đó")

	var exported: Dictionary = state.export_save_data()
	_assert(int(exported.get("version", 0)) == 1, "Save data phải có version 1")
	exported["selected"]["top"] = "missing_item"
	exported["selected"]["background"] = "top_tee"
	exported["locks"]["hair"] = true
	var restored_state = GameStateScript.new()
	restored_state.initialize(catalog, exported)
	_assert(restored_state.selected["top"] == catalog.get_default_state()["top"], "Restore phải sanitize item bị thiếu")
	_assert(restored_state.selected["background"] == catalog.get_default_state()["background"], "Restore phải sanitize item sai category")
	_assert(bool(restored_state.locks["hair"]), "Restore phải giữ lock hợp lệ")

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


func _assert_state_compatible(catalog: RefCounted, state: RefCounted, message: String) -> void:
	var selected_items: Array = []
	for category_id in catalog.get_category_ids():
		var item: Dictionary = state.get_selected_item(str(category_id))
		_assert(not item.is_empty(), "%s: thiếu item cho category %s" % [message, category_id])
		selected_items.append(item)

	for left_index in range(selected_items.size()):
		var left: Dictionary = selected_items[left_index]
		for right_index in range(left_index + 1, selected_items.size()):
			var right: Dictionary = selected_items[right_index]
			var slot_conflict := _intersects(left.get("occupies", []), right.get("occupies", []))
			var tag_conflict := (
				_intersects(left.get("conflicts_with_tags", []), right.get("tags", []))
				or _intersects(right.get("conflicts_with_tags", []), left.get("tags", []))
			)
			_assert(not slot_conflict and not tag_conflict, "%s: %s xung đột với %s" % [message, left.get("id", ""), right.get("id", "")])


func _intersects(left: Variant, right: Variant) -> bool:
	if typeof(left) != TYPE_ARRAY or typeof(right) != TYPE_ARRAY:
		return false
	for value in left:
		if right.has(value):
			return true
	return false
