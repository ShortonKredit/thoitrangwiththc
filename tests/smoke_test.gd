extends SceneTree

const ItemCatalogScript = preload("res://scripts/core/item_catalog.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")
const SaveServiceScript = preload("res://scripts/core/save_service.gd")
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
	_assert(face_subcategories == ["skin", "eyes", "eyebrows", "mouth", "makeup", "face_effect"], "Face navigation must expose every non-empty appearance subcategory")
	_assert(not face_subcategories.has("eyelashes"), "Missing source eyelashes must not create an empty subcategory")
	var bottom_groups: Array = catalog.get_visible_item_groups("bottom")
	_assert(bottom_groups.map(func(group: Dictionary) -> String: return str(group.get("id", ""))) == ["shorts", "trousers", "skirt"], "Bottom navigation must expose three data-driven item groups")
	for group_id in ["shorts", "trousers", "skirt"]:
		var group_items: Array = catalog.get_items_for_category_group("bottom", group_id)
		_assert(group_items.any(func(item: Dictionary) -> bool: return str(item.get("id", "")) == "bottom_none"), "Every bottom group must expose bottom_none")
		_assert(group_items.any(func(item: Dictionary) -> bool: return str(item.get("render_key", "")) != "none"), "Every visible bottom group must contain real content")
	_assert(MainScript.ITEM_GRID_COLUMNS == 2, "Item grid must use two columns")
	_assert(not MainScript.ITEM_TILE_SHOWS_TEXT, "Item tiles must not render visible item names")
	_assert(MainScript.ITEM_TILE_MIN_SIZE.y >= 160.0, "Item tiles must be large enough for thumbnail-first selection")
	_assert_action_bar()
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
	for optional_category in ["hair", "eyes", "eyebrows", "mouth", "makeup", "face_effect"]:
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
	_assert(state.selected["hair"] == "hair_none", "Default hair must be none")
	_assert(state.selected["skin"] == "skin_tone_01", "Default skin must be mandatory skin tone 01")
	_assert(state.selected["face"] == "face_none", "Legacy face composite must be disabled by default")
	_assert(state.selected["eyes"] == "eyes_none", "Default eyes must be none")
	_assert(state.selected["eyebrows"] == "eyebrows_none", "Default eyebrows must be none")
	_assert(state.selected["mouth"] == "mouth_none", "Default mouth must be none")
	_assert(state.selected["makeup"] == "makeup_none", "Default makeup must be none")
	_assert(state.selected["face_effect"] == "effect_none", "Default face effect must be none")
	_assert(state.selected["top"] == "top_none", "Default top must use fallback top coverage")
	_assert(state.selected["bottom"] == "bottom_none", "Default bottom must use fallback bottom coverage")
	_assert(state.selected["dress"] == "dress_none", "Default dress must be none")
	_assert(state.selected["background"] == "background_none", "Default background must use the catalog none/default item")
	_assert_png_layers(catalog, state, true, true, false, false, false, "Initial no-selection state must show both fallbacks")
	var default_layers: Dictionary = DollViewScript.get_png_layer_paths(catalog, state)
	for optional_layer in ["hair_front", "hair_back", "eyes", "eyebrows", "mouth", "makeup", "face_effect", "face"]:
		_assert(not default_layers.has(optional_layer), "Default appearance must not render optional layer %s" % optional_layer)

	state.select_item("skin_tone_05")
	_assert(str(DollViewScript.get_png_layer_paths(catalog, state).get("body_core", "")).ends_with("skin_tone_05.png"), "Skin selection must replace body_core without changing geometry")
	_assert_png_has_coverage(catalog, state, "Skin swap must preserve fallback coverage")
	state.select_item("hair_style_02_color_03")
	_assert(DollViewScript.get_png_layer_paths(catalog, state).has("hair_front"), "Selecting combined hair must render hair_front")
	state.select_item("hair_none")
	_assert(not DollViewScript.get_png_layer_paths(catalog, state).has("hair_front"), "Hair none must render no combined hair")
	state.undo()
	_assert(DollViewScript.get_png_layer_paths(catalog, state).has("hair_front"), "Undo must restore combined hair")
	state.redo()
	_assert(not DollViewScript.get_png_layer_paths(catalog, state).has("hair_front"), "Redo must restore hair none")
	state.select_item("eyebrows_tone_01")
	state.select_item("eyes_style_03_color_10")
	state.select_item("eyes_none")
	_assert(not DollViewScript.get_png_layer_paths(catalog, state).has("eyes"), "Eyes none must suppress only the eyes layer")
	_assert(DollViewScript.get_png_layer_paths(catalog, state).has("eyebrows"), "Eyes none must keep eyebrows")
	state.select_item("eyes_style_03_color_10")
	state.select_item("eyebrows_none")
	state.select_item("mouth_none")
	state.select_item("makeup_blush_02")
	var face_layers: Dictionary = DollViewScript.get_png_layer_paths(catalog, state)
	_assert(face_layers.has("eyes") and not face_layers.has("eyebrows") and not face_layers.has("mouth") and face_layers.has("makeup"), "Face feature slots must render independently")
	state.select_item("face_effect_sweat_01")
	_assert(DollViewScript.get_png_layer_paths(catalog, state).has("face_effect"), "Selecting a face effect must render its independent layer")
	state.select_item("effect_none")
	_assert(not DollViewScript.get_png_layer_paths(catalog, state).has("face_effect"), "Effect none must suppress only the face effect layer")
	state.undo()
	_assert(state.selected["face_effect"] == "face_effect_sweat_01", "Undo must restore the prior face effect")
	state.redo()
	_assert(state.selected["face_effect"] == "effect_none", "Redo must restore effect none")

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
	state.select_item("bottom_keri_trousers_color_01")
	_assert(str(DollViewScript.get_png_layer_paths(catalog, state).get("bottom", "")).ends_with("trousers_style_01_color_01.png"), "Long trousers must use the shared bottom slot")
	state.select_item("bottom_keri_skirt_color_06")
	_assert(str(DollViewScript.get_png_layer_paths(catalog, state).get("bottom", "")).ends_with("skirt_style_01_color_06.png"), "Skirts must replace trousers in the shared bottom slot")
	state.undo()
	_assert(state.selected["bottom"] == "bottom_keri_trousers_color_01", "Undo must restore trousers after a skirt selection")
	state.redo()
	_assert(state.selected["bottom"] == "bottom_keri_skirt_color_06", "Redo must restore the skirt in the shared bottom slot")

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
	for optional_category in ["hair", "eyes", "eyebrows", "mouth", "makeup", "face_effect"]:
		_assert(str(state.selected[optional_category]).ends_with("_none"), "Reset must restore %s none" % optional_category)
	_assert(state.selected["skin"] == "skin_tone_01", "Reset must restore base01 skin")
	_assert_png_layers(catalog, state, true, true, false, false, false, "Reset must restore fallback outfit")
	_assert(bool(state.locks["hair"]), "Reset keep_locks must retain locks")
	state.undo()
	_assert(state.selected["shoes"] == next_shoes, "Undo after reset must restore previous outfit")
	_assert_png_has_coverage(catalog, state, "Undo after reset must keep coverage")
	state.redo()
	_assert(state.selected == catalog.get_default_state(), "Redo after undoing reset must apply defaults again")
	state.undo()
	var branch_skin := "skin_tone_02" if state.selected["skin"] != "skin_tone_02" else "skin_tone_03"
	_assert(state.select_item(branch_skin), "A new selection after undoing reset must succeed")
	_assert(not state.can_redo(), "A new selection after undo must clear the redo stack")

	_assert_reset_persists_to_local_save(catalog)

	state.select_item("face_effect_tears_style_02_variant_05")
	var exported: Dictionary = state.export_save_data()
	_assert(int(exported.get("version", 0)) == 3, "Phase 3A content save data must have version 3")
	exported["selected"]["top"] = "missing_item"
	exported["selected"]["background"] = "top_tee"
	exported["locks"]["hair"] = true
	var restored_state = GameStateScript.new()
	restored_state.initialize(catalog, exported)
	_assert(restored_state.selected["top"] == catalog.get_default_state()["top"], "Restore must sanitize missing item")
	_assert(restored_state.selected["background"] == catalog.get_default_state()["background"], "Restore must sanitize wrong-category item")
	_assert(bool(restored_state.locks["hair"]), "Restore must keep valid lock")
	_assert(restored_state.selected["face_effect"] == "face_effect_tears_style_02_variant_05", "Save/load must preserve a selected face effect")
	_assert_png_has_coverage(catalog, restored_state, "Save/load restore must keep coverage")

	var default_save := GameStateScript.new()
	default_save.initialize(catalog)
	var default_restored := GameStateScript.new()
	default_restored.initialize(catalog, default_save.export_save_data())
	_assert(default_restored.selected == catalog.get_default_state(), "Save/load must preserve the new all-none appearance default")

	var legacy_state = GameStateScript.new()
	legacy_state.initialize(catalog, {"version": 1, "selected": {"hair": "hair_keri_long_brown_01", "face": "face_keri_default_01", "top": "top_none", "bottom": "bottom_none", "dress": "dress_none"}, "locks": {"hair": true}})
	_assert(legacy_state.selected["face"] == "face_none", "Legacy composite face must sanitize to separate Phase 2C defaults")
	_assert(legacy_state.selected["skin"] == "skin_tone_01", "Legacy save missing skin must fall back safely")
	_assert(legacy_state.selected["eyes"] == "eyes_none", "Legacy save missing eyes must fall back to the new safe default")
	_assert(legacy_state.selected["face_effect"] == "effect_none", "Legacy save missing face effect must fall back safely")
	_assert(bool(legacy_state.locks["hair"]), "Legacy save must retain valid locks")
	var version_2_state = GameStateScript.new()
	version_2_state.initialize(catalog, {"version": 2, "selected": {"skin": "skin_tone_03", "top": "top_none", "bottom": "bottom_none"}, "locks": {}})
	_assert(version_2_state.selected["skin"] == "skin_tone_03", "Version-2 saves must retain valid existing selections")
	_assert(version_2_state.selected["face_effect"] == "effect_none", "Version-2 saves missing face effect must use effect_none")

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


func _assert_action_bar() -> void:
	var main = MainScript.new()
	var action_bar: Control = main._build_action_grid()
	var buttons := action_bar.get_children()
	_assert(buttons.size() == 3, "Phase 3A action bar must expose exactly Undo, Redo, and Reset")
	var expected_names: Array = MainScript.ACTION_BUTTON_NAMES
	var expected_icon_paths: Array = MainScript.ACTION_ICON_PATHS
	var expected_tooltips := ["Hoàn tác", "Làm lại", "Reset"]
	for index in range(buttons.size()):
		var button := buttons[index] as Button
		_assert(button != null, "Every public action must be a Button")
		if button == null:
			continue
		_assert(str(button.name) == str(expected_names[index]), "Action buttons must retain stable public names")
		_assert(button.text.is_empty(), "Action buttons must not depend on Unicode or emoji text glyphs")
		_assert(button.icon != null, "Action buttons must use local icon textures")
		if button.icon != null:
			_assert(button.icon.resource_path == str(expected_icon_paths[index]), "Action button must use its stable local SVG path")
			_assert(button.icon.get_size() == Vector2(24, 24), "Action SVG textures must retain their square 24x24 size")
		_assert(not button.expand_icon and button.get_theme_constant("icon_max_width") == 24, "Action icons must remain centered without stretch distortion")
		_assert(button.tooltip_text == expected_tooltips[index], "Action button tooltip must match the Vietnamese product copy")
		_assert(button.accessibility_name == expected_tooltips[index], "Action button accessible name must match its tooltip")
		_assert(button.focus_mode == Control.FOCUS_ALL, "Action buttons must remain keyboard-focusable")
		_assert(button.get_theme_stylebox("hover") != null, "Action buttons need a hover style")
		_assert(button.get_theme_stylebox("pressed") != null, "Action buttons need a pressed style")
		_assert(button.get_theme_stylebox("disabled") != null, "Action buttons need a disabled style")
		_assert(button.get_theme_stylebox("focus") != null, "Action buttons need a focus style")
		_assert(button.get_theme_color("icon_disabled_color").a < button.get_theme_color("icon_normal_color").a, "Disabled action icons must remain visible with reduced emphasis")
	_assert_action_svg_sources(expected_icon_paths)
	main._on_history_changed(false, false)
	_assert(main.undo_button.disabled and main.redo_button.disabled, "Undo and Redo must start disabled when history is unavailable")
	_assert(not main.reset_button.disabled, "Reset must remain enabled")
	main._on_history_changed(true, false)
	_assert(not main.undo_button.disabled and main.redo_button.disabled, "Undo/Redo disabled states must follow history")
	action_bar.free()
	main.free()


func _assert_action_svg_sources(icon_paths: Array) -> void:
	for path_value in icon_paths:
		var path := str(path_value)
		_assert(FileAccess.file_exists(path), "Action SVG source must exist: %s" % path)
		if not FileAccess.file_exists(path):
			continue
		var source := FileAccess.get_file_as_string(path)
		_assert(source.contains("<svg") and source.contains("viewBox=\"0 0 24 24\""), "Action icon must be a valid square SVG: %s" % path)
		_assert(source.contains("<path") and source.contains("stroke=\"#493b43\""), "Action SVG must use explicit monochrome path strokes: %s" % path)
		_assert(not source.contains("<text") and not source.contains("currentColor") and not source.contains("href="), "Action SVG must not use text, font, currentColor, or external references: %s" % path)


func _assert_reset_persists_to_local_save(catalog: RefCounted) -> void:
	var path := "user://phase_3a_reset_smoke.json"
	var service = SaveServiceScript.new(path)
	service.clear_data()
	var state = GameStateScript.new()
	state.initialize(catalog)
	state.changed.connect(func(_reason: String) -> void:
		service.save_data(state.export_save_data())
	)
	state.select_item("top_keri_style_05_color_06")
	state.select_item("bottom_keri_shorts_color_06")
	state.select_item("background_city")
	state.reset_to_default(true)
	var persisted: Dictionary = service.load_data()
	_assert(catalog.sanitize_selection(persisted.get("selected", {})) == catalog.get_default_state(), "Reset must persist the full catalog default to local save")
	var restored = GameStateScript.new()
	restored.initialize(catalog, persisted)
	_assert(restored.selected == catalog.get_default_state(), "A reset state must not be replaced by the pre-reset outfit after relaunch")
	service.clear_data()


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
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("skin_tone_02")) == "skin_swatch", "Skin items must use color-swatch previews")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("eyes_style_01_color_01")) == "feature_crop", "Face features must use focused crop previews")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("hair_style_01_color_01")) == "hair_preview", "Hair must use hair-focused previews")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("top_keri_style_05_color_06")) == "top_crop", "Product tops must use focused top crops")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("bottom_keri_shorts_color_06")) == "bottom_crop", "Product shorts must use focused bottom crops")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("bottom_keri_trousers_color_01")) == "bottom_crop", "Product trousers must use focused bottom crops")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("bottom_keri_skirt_color_01")) == "bottom_crop", "Product skirts must use focused bottom crops")
	_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item("face_effect_sweat_01")) == "effect_crop", "Face effects must use focused effect crops")
	var swatch_colors: Dictionary = {}
	for skin_item in catalog.get_items_for_category("skin"):
		var swatch := MainScript.skin_swatch_color_for_item(skin_item)
		_assert(swatch.a == 1.0, "Skin swatches must be opaque")
		swatch_colors[swatch.to_html(false)] = true
	_assert(swatch_colors.size() == catalog.get_items_for_category("skin").size(), "Every skin variant must have a distinct swatch color")
	var swatch_preview: Image = MainScript._make_skin_swatch_preview(catalog.get_item("skin_tone_01"))
	var expected_swatch := MainScript.skin_swatch_color_for_item(catalog.get_item("skin_tone_01"))
	_assert(swatch_preview.get_size() == MainScript.THUMBNAIL_SIZE, "Skin swatch must fill the thumbnail render target")
	_assert(swatch_preview.get_pixel(0, 0) == expected_swatch and swatch_preview.get_pixel(96, 96) == expected_swatch and swatch_preview.get_pixel(191, 191) == expected_swatch, "Skin swatch must contain only the representative color")
	for feature_category in ["eyes", "eyebrows", "mouth", "makeup"]:
		for feature_item in catalog.get_items_for_category(feature_category):
			if str(feature_item.get("render_key", "")) == "none":
				_assert(MainScript.thumbnail_preview_mode_for_item(feature_item) == "none", "Feature none items must keep the X tile mode")
				continue
			_assert(MainScript.thumbnail_preview_mode_for_item(feature_item) == "feature_crop", "%s items must use feature crops" % feature_category)
			_assert(_item_preview_rect_is_valid(feature_item, catalog.character), "%s preview crop must stay inside the canvas" % feature_item.get("id", ""))
	for none_category in ["hair", "eyes", "eyebrows", "mouth", "makeup", "background"]:
		_assert(MainScript.thumbnail_preview_mode_for_item(catalog.get_item(catalog.get_none_item_id(none_category))) == "none", "%s none must keep the X tile" % none_category)
	_assert_layer_has_cropped_bounds(catalog.get_item("hair_style_01_color_01"), "Hair thumbnail preview must crop transparent canvas")
	_assert_layer_has_cropped_bounds(catalog.get_item("top_keri_casual_01"), "Top thumbnail preview must crop transparent canvas")
	_assert_layer_has_cropped_bounds(catalog.get_item("bottom_keri_shorts_01"), "Bottom thumbnail preview must crop transparent canvas")
	_assert(_item_preview_rect_is_valid(catalog.get_item("top_keri_style_05_color_06"), catalog.character), "Product top preview metadata must stay inside the canvas")
	_assert(_item_preview_rect_is_valid(catalog.get_item("bottom_keri_shorts_color_06"), catalog.character), "Product bottom preview metadata must stay inside the canvas")
	_assert(_item_preview_rect_is_valid(catalog.get_item("bottom_keri_trousers_color_01"), catalog.character), "Trouser preview metadata must stay inside the canvas")
	_assert(_item_preview_rect_is_valid(catalog.get_item("bottom_keri_skirt_color_01"), catalog.character), "Skirt preview metadata must stay inside the canvas")
	_assert(_item_preview_rect_is_valid(catalog.get_item("face_effect_sweat_01"), catalog.character), "Effect preview metadata must stay inside the canvas")

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


func _item_preview_rect_is_valid(item: Dictionary, character: Dictionary) -> bool:
	var rect := MainScript.thumbnail_preview_rect_for_item(item)
	var canvas: Array = character.get("canvas_size", [])
	return canvas.size() == 2 and rect.size.x > 0 and rect.size.y > 0 and rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= int(canvas[0]) and rect.end.y <= int(canvas[1])


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
