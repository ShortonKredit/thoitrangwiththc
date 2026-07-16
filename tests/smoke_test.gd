extends SceneTree

const ItemCatalogScript = preload("res://scripts/core/item_catalog.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")
const DollViewScript = preload("res://scripts/rendering/doll_view.gd")
const MainScript = preload("res://scripts/main.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var catalog = ItemCatalogScript.new()
	_assert(catalog.load_catalog() == OK, "Catalog must load")
	_assert(catalog.get_category_ids().size() >= 9, "Catalog must retain at least the 9 baseline categories")
	_assert(catalog.has_item("top_tee") and catalog.has_item("bottom_pleated_skirt"), "Representative placeholder items must be retained")
	_assert(catalog.get_visible_category_ids().has("face"), "Face proof category must be visible")
	_assert(str(catalog.get_category("face").get("display_name", "")) == "Khuôn mặt", "Face category display name must use Vietnamese accents")
	_assert(str(catalog.get_category("hair").get("display_name", "")) == "Tóc", "Hair category display name must use Vietnamese accents")
	_assert(str(catalog.get_category("top").get("display_name", "")) == "Áo", "Top category display name must use Vietnamese accents")
	_assert(str(catalog.get_category("bottom").get("display_name", "")) == "Quần / Váy", "Bottom category display name must use Vietnamese accents")
	_assert(not catalog.get_visible_category_ids().has("shoes"), "Shoes must not be visible in the MVP proof UI")
	for category_id in catalog.get_visible_category_ids():
		var category: Dictionary = catalog.get_category(str(category_id))
		if bool(category.get("ui_container", false)):
			_assert(not catalog.get_visible_subcategory_ids(str(category_id)).is_empty(), "Visible category containers must have visible subcategories")
		else:
			_assert(not catalog.get_items_for_category(str(category_id)).is_empty(), "Visible categories must have visible items")
	var face_subcategories := catalog.get_visible_subcategory_ids("face")
	_assert(face_subcategories == ["skin", "eyes", "eyebrows", "mouth", "makeup"], "Face navigation must expose only non-empty Phase 2C subcategories")
	_assert(not face_subcategories.has("eyelashes"), "Missing source eyelashes must not create an empty subcategory")
	_assert(MainScript.ITEM_GRID_COLUMNS == 2, "Item grid must use two columns")
	_assert(not MainScript.ITEM_TILE_SHOWS_TEXT, "Item tiles must not render visible item names")
	_assert(MainScript.ITEM_TILE_MIN_SIZE.y >= 160.0, "Item tiles must be large enough for thumbnail-first selection")
	_assert(str(catalog.character.get("mode", "")) == "png", "Phase 2B proof must use PNG mode")
	_assert(_array_equals_ints(catalog.character.get("canvas_size", []), [948, 1920]), "Keri proof must use the 948x1920 canvas")
	_assert(catalog.character.get("layer_order", []).has("body_core"), "Layer order must include body_core")
	_assert(catalog.character.get("layer_order", []).has("fallback_top"), "Layer order must include fallback_top")
	_assert(catalog.character.get("layer_order", []).has("fallback_bottom"), "Layer order must include fallback_bottom")
	_assert(_layer_before(catalog, "body_core", "eyes"), "Skin/body must render before face features")
	_assert(_layer_before(catalog, "makeup", "hair_front"), "Combined hair must render after face features")
	_assert(_face_metadata_is_valid(catalog), "Face import metadata must stay inside the Keri canvas")
	_assert(_layer_paths_exist(catalog), "All catalog PNG layer paths must exist")
	_assert(catalog.get_none_item_id("skin").is_empty(), "Mandatory skin selector must not have none")
	for optional_category in ["hair", "eyes", "eyebrows", "mouth", "makeup"]:
		_assert(not catalog.get_none_item_id(optional_category).is_empty(), "%s must provide a none item" % optional_category)
	var thumbnail_fallback_item: Dictionary = catalog.get_item("top_tee")
	_assert(str(thumbnail_fallback_item.get("thumbnail_path", "")) == "", "thumbnail_path must remain optional")
	_assert(str(thumbnail_fallback_item.get("accessible_name", "")) == str(thumbnail_fallback_item.get("display_name", "")), "accessible_name must fall back to display_name")
	_assert(_invalid_thumbnail_catalog_is_rejected(), "Invalid thumbnail_path must be rejected")
	_assert_thumbnail_pipeline(catalog)

	var state = GameStateScript.new()
	state.initialize(catalog)
	_assert(DollViewScript.get_base_outfit_layer_order().has("fallback_top"), "Renderer must declare fallback top invariant")
	_assert(DollViewScript.get_base_outfit_layer_order().has("fallback_bottom"), "Renderer must declare fallback bottom invariant")
	_assert(not state.selected.has("base_outfit"), "Base outfit must not be saved in selected state")
	_assert_state_compatible(catalog, state, "Initial state must be compatible")
	_assert(state.selected["hair"] == "hair_style_01_color_01", "Default hair must use the Phase 2C combined-hair catalog")
	_assert(state.selected["skin"] == "skin_tone_01", "Default skin must be mandatory skin tone 01")
	_assert(state.selected["face"] == "face_none", "Legacy face composite must be disabled by default")
	_assert(state.selected["eyes"] == "eyes_style_01_color_01", "Default eyes must be a separate face layer")
	_assert(state.selected["top"] == "top_none", "Default top must use fallback top coverage")
	_assert(state.selected["bottom"] == "bottom_none", "Default bottom must use fallback bottom coverage")
	_assert(state.selected["dress"] == "dress_none", "Default dress must be none")
	_assert_png_layers(catalog, state, true, true, false, false, false, "Initial no-selection state must show both fallbacks")
	_assert(DollViewScript.get_png_layer_paths(catalog, state).has("eyes"), "Default separate eyes layer must render")

	state.select_item("skin_tone_05")
	_assert(str(DollViewScript.get_png_layer_paths(catalog, state).get("body_core", "")).ends_with("skin_tone_05.png"), "Skin selection must replace body_core without changing geometry")
	_assert_png_has_coverage(catalog, state, "Skin swap must preserve fallback coverage")
	state.select_item("hair_none")
	_assert(not DollViewScript.get_png_layer_paths(catalog, state).has("hair_front"), "Hair none must render no combined hair")
	state.undo()
	_assert(DollViewScript.get_png_layer_paths(catalog, state).has("hair_front"), "Undo must restore combined hair")
	state.redo()
	_assert(not DollViewScript.get_png_layer_paths(catalog, state).has("hair_front"), "Redo must restore hair none")
	state.select_item("hair_style_02_color_03")
	state.select_item("eyes_none")
	_assert(not DollViewScript.get_png_layer_paths(catalog, state).has("eyes"), "Eyes none must suppress only the eyes layer")
	_assert(DollViewScript.get_png_layer_paths(catalog, state).has("eyebrows"), "Eyes none must keep eyebrows")
	state.select_item("eyes_style_03_color_10")
	state.select_item("eyebrows_none")
	state.select_item("mouth_none")
	state.select_item("makeup_blush_02")
	var face_layers: Dictionary = DollViewScript.get_png_layer_paths(catalog, state)
	_assert(face_layers.has("eyes") and not face_layers.has("eyebrows") and not face_layers.has("mouth") and face_layers.has("makeup"), "Face feature slots must render independently")

	state.select_item("top_none")
	state.select_item("bottom_none")
	state.select_item("dress_none")
	_assert(state.selected["top"] == "top_none", "top_none must be valid")
	_assert(state.selected["bottom"] == "bottom_none", "bottom_none must be valid")
	_assert(state.selected["dress"] == "dress_none", "dress_none must be valid")
	_assert_state_compatible(catalog, state, "Empty top/bottom/dress state must stay compatible")
	_assert(not state.snapshot()["selected"].has("base_outfit"), "Snapshot must not include base outfit")
	_assert_png_layers(catalog, state, true, true, false, false, false, "No top/bottom selection must show fallback outfit")

	state.select_item("top_keri_casual_01")
	_assert_png_layers(catalog, state, false, true, true, false, false, "Selected top must hide fallback top only")

	state.select_item("bottom_keri_shorts_01")
	_assert_png_layers(catalog, state, false, false, true, true, false, "Selected top and bottom must hide both fallbacks")

	state.select_item("dress_casual")
	_assert(state.selected["dress"] == "dress_casual", "Dress must be selectable for compatibility migration")
	_assert(state.selected["top"] == "top_none", "Dress must clear top")
	_assert(state.selected["bottom"] == "bottom_none", "Dress must clear bottom")
	_assert_state_compatible(catalog, state, "Dress must not leave top/bottom conflicts")
	_assert_png_layers(catalog, state, false, false, false, false, false, "Selected dress must hide fallbacks and selected separates")

	state.select_item("top_keri_casual_02")
	_assert(state.selected["top"] == "top_keri_casual_02", "Keri proof top 02 must be selectable")
	_assert(state.selected["dress"] == "dress_none", "Top must clear dress")
	_assert_state_compatible(catalog, state, "Top must not leave dress conflicts")
	_assert_png_layers(catalog, state, false, true, true, false, false, "Clearing dress with top must restore bottom fallback")

	state.select_item("hair_soft_waves")
	state.select_item("headwear_cap")
	_assert(state.selected["hair"] != "hair_soft_waves", "Cap must clear conflicting voluminous hair")
	state.select_item("headwear_none")
	state.select_item("hair_style_01_color_01")
	state.set_lock("hair", true)
	state.randomize()
	_assert(state.selected["headwear"] != "headwear_cap", "Random must not pick hidden/conflicting cap")
	_assert_state_compatible(catalog, state, "Random with locks must not create conflicts")
	_assert_png_has_coverage(catalog, state, "Random with locks must keep coverage")

	var hair_before: String = state.selected["hair"]
	var shoes_before: String = state.selected["shoes"]
	state.randomize()
	_assert(state.selected["hair"] == hair_before, "Random must keep locked hair")
	_assert(state.selected["shoes"] == shoes_before, "Random must not change hidden shoes category")
	_assert_state_compatible(catalog, state, "Random must not create conflicts")
	_assert_png_has_coverage(catalog, state, "Random must keep coverage")

	var snapshot_before := state.snapshot()
	var next_shoes := "shoes_sneakers" if state.selected["shoes"] == "shoes_flats" else "shoes_flats"
	_assert(state.select_item(next_shoes), "Hidden legacy shoes must remain selectable for save migration/history")
	_assert(state.can_undo(), "Undo must be available after a change")
	state.undo()
	_assert(state.snapshot() == snapshot_before, "Undo must restore the full state")
	_assert_png_has_coverage(catalog, state, "Undo must keep coverage")
	state.redo()
	_assert(state.selected["shoes"] == next_shoes, "Redo must reapply the item")
	_assert_png_has_coverage(catalog, state, "Redo must keep coverage")

	state.reset_to_default(true)
	_assert(state.selected == catalog.get_default_state(), "Reset must restore default selected state")
	_assert_png_layers(catalog, state, true, true, false, false, false, "Reset must restore fallback outfit")
	_assert(bool(state.locks["hair"]), "Reset keep_locks must retain locks")
	state.undo()
	_assert(state.selected["shoes"] == next_shoes, "Undo after reset must restore previous outfit")
	_assert_png_has_coverage(catalog, state, "Undo after reset must keep coverage")

	var exported: Dictionary = state.export_save_data()
	_assert(int(exported.get("version", 0)) == 2, "Phase 2C save data must have version 2")
	exported["selected"]["top"] = "missing_item"
	exported["selected"]["background"] = "top_tee"
	exported["locks"]["hair"] = true
	var restored_state = GameStateScript.new()
	restored_state.initialize(catalog, exported)
	_assert(restored_state.selected["top"] == catalog.get_default_state()["top"], "Restore must sanitize missing item")
	_assert(restored_state.selected["background"] == catalog.get_default_state()["background"], "Restore must sanitize wrong-category item")
	_assert(bool(restored_state.locks["hair"]), "Restore must keep valid lock")
	_assert_png_has_coverage(catalog, restored_state, "Save/load restore must keep coverage")

	var legacy_state = GameStateScript.new()
	legacy_state.initialize(catalog, {"version": 1, "selected": {"hair": "hair_keri_long_brown_01", "face": "face_keri_default_01", "top": "top_none", "bottom": "bottom_none", "dress": "dress_none"}, "locks": {"hair": true}})
	_assert(legacy_state.selected["face"] == "face_none", "Legacy composite face must sanitize to separate Phase 2C defaults")
	_assert(legacy_state.selected["skin"] == "skin_tone_01", "Legacy save missing skin must fall back safely")
	_assert(legacy_state.selected["eyes"] == "eyes_style_01_color_01", "Legacy save missing eyes must fall back safely")
	_assert(bool(legacy_state.locks["hair"]), "Legacy save must retain valid locks")

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


func _invalid_thumbnail_catalog_is_rejected() -> bool:
	var path := "user://invalid_thumbnail_catalog.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({
		"schema_version": 1,
		"character": {
			"id": "test_character",
			"mode": "procedural",
			"canvas_size": [1024, 1536],
			"layer_order": ["body", "base_outfit"],
			"layers": {}
		},
		"categories": [
			{"id": "test", "display_name": "Test", "allow_none": false, "random_default": true, "order": 1}
		],
		"initial_state": {"test": "test_item"},
		"items": [
			{
				"id": "test_item",
				"category": "test",
				"display_name": "Test Item",
				"render_key": "none",
				"order": 1,
				"occupies": ["test"],
				"tags": [],
				"conflicts_with_tags": [],
				"thumbnail_path": "bad/path.png",
				"layers": {},
				"placeholder": {}
			}
		]
	}))
	file.close()

	var invalid_catalog = ItemCatalogScript.new()
	var result := invalid_catalog.load_catalog(path, false)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	return result == ERR_INVALID_DATA


func _assert_thumbnail_pipeline(catalog: RefCounted) -> void:
	_assert(MainScript.THUMBNAIL_SIZE == Vector2i(192, 192), "Thumbnail previews must use a stable square render target")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("top_none")) == "none", "None items must use the none preview mode")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("background_studio")) == "cover", "Backgrounds must use cover previews")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("face_keri_default_01")) == "face_preview", "Face items must use face previews")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("skin_tone_02")) == "skin_preview", "Skin items must use upper-body previews")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("eyes_style_01_color_01")) == "face_preview", "Face features must use head-reference previews")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("hair_style_01_color_01")) == "visible_bounds", "Hair must use visible-bounds previews")
	_assert_layer_has_cropped_bounds(catalog.get_item("hair_style_01_color_01"), "Hair thumbnail preview must crop transparent canvas")
	_assert_layer_has_cropped_bounds(catalog.get_item("top_keri_casual_01"), "Top thumbnail preview must crop transparent canvas")
	_assert_layer_has_cropped_bounds(catalog.get_item("bottom_keri_shorts_01"), "Bottom thumbnail preview must crop transparent canvas")

	var canvas_size: Array = catalog.character.get("canvas_size", [])
	var face_rect: Rect2i = MainScript.face_metadata_rect(catalog.character, "head_preview_rect")
	_assert(face_rect.position.x >= 0 and face_rect.position.y >= 0, "Face preview crop must start inside the Keri canvas")
	_assert(face_rect.position.x + face_rect.size.x <= int(canvas_size[0]), "Face preview crop width must stay inside the Keri canvas")
	_assert(face_rect.position.y + face_rect.size.y <= int(canvas_size[1]), "Face preview crop height must stay inside the Keri canvas")

	for background in catalog.get_items_for_category("background"):
		if str(background.get("render_key", "")) == "none":
			_assert(MainScript.thumbnail_preview_mode_for_item(background) == "none", "Background none must use the none tile")
		else:
			_assert(MainScript.thumbnail_preview_mode_for_item(background) == "cover", "Every background item must use cover preview mode")
			_assert(not Dictionary(background.get("placeholder", {})).is_empty(), "Background preview needs placeholder color metadata")


func _layer_before(catalog: RefCounted, first: String, second: String) -> bool:
	var order: Array = catalog.character.get("layer_order", [])
	return order.find(first) >= 0 and order.find(second) > order.find(first)


func _face_metadata_is_valid(catalog: RefCounted) -> bool:
	var canvas: Array = catalog.character.get("canvas_size", [])
	if canvas.size() != 2:
		return false
	for key in ["face_rect", "safe_clipping_bounds", "face_mask_bounds", "head_preview_rect", "skin_preview_rect"]:
		var rect := MainScript.face_metadata_rect(catalog.character, key)
		if rect.size.x <= 0 or rect.size.y <= 0 or rect.position.x < 0 or rect.position.y < 0:
			return false
		if rect.end.x > int(canvas[0]) or rect.end.y > int(canvas[1]):
			return false
	return true


func _assert_layer_has_cropped_bounds(item: Dictionary, message: String) -> void:
	var path := _first_layer_path(item)
	var used_rect := MainScript.thumbnail_used_rect_for_path(path)
	_assert(used_rect.size.x > 0 and used_rect.size.y > 0, "%s: visible alpha bounds must be detected" % message)
	_assert(used_rect.size.x < 948 or used_rect.size.y < 1920, "%s: bounds must be smaller than the production canvas" % message)


func _first_layer_path(item: Dictionary) -> String:
	var layers: Dictionary = item.get("layers", {})
	for path in layers.values():
		return str(path)
	return ""


func _layer_paths_exist(catalog: RefCounted) -> bool:
	var character_layers: Dictionary = catalog.character.get("layers", {})
	for path in character_layers.values():
		if not ResourceLoader.exists(str(path), "Texture2D"):
			return false
	for item in catalog.items:
		var layers: Dictionary = item.get("layers", {})
		for path in layers.values():
			if not ResourceLoader.exists(str(path), "Texture2D"):
				return false
	return true


func _array_equals_ints(left: Variant, right: Array) -> bool:
	if typeof(left) != TYPE_ARRAY or left.size() != right.size():
		return false
	for index in range(right.size()):
		if int(left[index]) != int(right[index]):
			return false
	return true


func _assert_png_layers(catalog: RefCounted, state: RefCounted, fallback_top: bool, fallback_bottom: bool, selected_top: bool, selected_bottom: bool, selected_dress: bool, message: String) -> void:
	var layers: Dictionary = DollViewScript.get_png_layer_paths(catalog, state)
	_assert(layers.has("body_core"), "%s: body_core must be visible" % message)
	_assert(layers.has("fallback_top") == fallback_top, "%s: fallback_top visibility mismatch" % message)
	_assert(layers.has("fallback_bottom") == fallback_bottom, "%s: fallback_bottom visibility mismatch" % message)
	_assert(layers.has("top") == selected_top, "%s: selected top visibility mismatch" % message)
	_assert(layers.has("bottom") == selected_bottom, "%s: selected bottom visibility mismatch" % message)
	_assert((layers.has("dress_back") or layers.has("dress_main")) == selected_dress, "%s: selected dress visibility mismatch" % message)


func _assert_png_has_coverage(catalog: RefCounted, state: RefCounted, message: String) -> void:
	var layers: Dictionary = DollViewScript.get_png_layer_paths(catalog, state)
	var has_dress := layers.has("dress_back") or layers.has("dress_main")
	var has_top := layers.has("top") or layers.has("fallback_top")
	var has_bottom := layers.has("bottom") or layers.has("fallback_bottom")
	_assert(layers.has("body_core"), "%s: missing body_core" % message)
	_assert(has_dress or (has_top and has_bottom), "%s: body_core must have valid coverage" % message)


func _assert_state_compatible(catalog: RefCounted, state: RefCounted, message: String) -> void:
	var selected_items: Array = []
	for category_id in catalog.get_category_ids():
		var item: Dictionary = state.get_selected_item(str(category_id))
		_assert(not item.is_empty(), "%s: missing item for category %s" % [message, category_id])
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
			_assert(not slot_conflict and not tag_conflict, "%s: %s conflicts with %s" % [message, left.get("id", ""), right.get("id", "")])


func _intersects(left: Variant, right: Variant) -> bool:
	if typeof(left) != TYPE_ARRAY or typeof(right) != TYPE_ARRAY:
		return false
	for value in left:
		if right.has(value):
			return true
	return false
