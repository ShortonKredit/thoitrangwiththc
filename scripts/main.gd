extends Control

const ItemCatalogScript = preload("res://scripts/core/item_catalog.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")
const SaveServiceScript = preload("res://scripts/core/save_service.gd")
const DollViewScript = preload("res://scripts/rendering/doll_view.gd")

const COLOR_PAGE := Color("#f7f1f8")
const COLOR_PANEL := Color("#fffafd")
const COLOR_ACCENT := Color("#c65e88")
const COLOR_ACCENT_DARK := Color("#9f3d68")
const COLOR_ACCENT_SOFT := Color("#f3d5e1")
const COLOR_TEXT := Color("#493b43")
const COLOR_MUTED := Color("#806f78")
const COLOR_BUTTON := Color("#ffffff")
const COLOR_BUTTON_HOVER := Color("#f8edf3")
const COLOR_BUTTON_DISABLED := Color("#eee8ec")
const COLOR_DANGER := Color("#9d5a62")

const ITEM_GRID_COLUMNS := 2
const ITEM_TILE_MIN_SIZE := Vector2(0, 184)
const ITEM_TILE_SHOWS_TEXT := false
const THUMBNAIL_SIZE := Vector2i(192, 192)
const THUMBNAIL_ALPHA_THRESHOLD := 8
const THUMBNAIL_PADDING_RATIO := 0.12
const ACTION_ICON_PATHS := [
	"res://assets/ui/icons/undo.svg",
	"res://assets/ui/icons/redo.svg",
	"res://assets/ui/icons/reset.svg",
]
const ACTION_ICON_UNDO: Texture2D = preload("res://assets/ui/icons/undo.svg")
const ACTION_ICON_REDO: Texture2D = preload("res://assets/ui/icons/redo.svg")
const ACTION_ICON_RESET: Texture2D = preload("res://assets/ui/icons/reset.svg")
const ACTION_BUTTON_NAMES := ["UndoButton", "RedoButton", "ResetButton"]

class NoneTileButton:
	extends Button

	func _draw() -> void:
		var stroke := Color("#806f78")
		var pad := minf(size.x, size.y) * 0.34
		draw_line(Vector2(pad, pad), Vector2(size.x - pad, size.y - pad), stroke, 5.0, true)
		draw_line(Vector2(size.x - pad, pad), Vector2(pad, size.y - pad), stroke, 5.0, true)

var catalog: RefCounted
var game_state: RefCounted
var save_service: RefCounted
var doll_view: Control

var current_category_id: String = ""
var current_main_category_id: String = ""
var current_item_group_id: String = ""
var category_button_group: ButtonGroup
var subcategory_button_group: ButtonGroup
var item_button_group: ButtonGroup
var category_buttons: Dictionary = {}
var subcategory_buttons: Dictionary = {}
var item_buttons: Dictionary = {}
var thumbnail_cache: Dictionary = {}

var item_grid: GridContainer
var subcategory_flow: HFlowContainer
var category_title: Label
var lock_toggle: CheckButton
var status_label: Label
var undo_button: Button
var redo_button: Button
var reset_button: Button
var reset_dialog: ConfirmationDialog


func _ready() -> void:
	seed(Time.get_ticks_usec())
	catalog = ItemCatalogScript.new()
	var load_error: Error = catalog.load_catalog()
	if load_error != OK:
		_show_fatal_error("Không tải được data/catalog.json. Mã lỗi: %s" % load_error)
		return

	save_service = SaveServiceScript.new()
	game_state = GameStateScript.new()
	game_state.initialize(catalog, save_service.load_data())
	game_state.changed.connect(_on_state_changed)
	game_state.history_changed.connect(_on_history_changed)

	var category_ids: Array = catalog.get_visible_category_ids()
	current_main_category_id = str(category_ids[0]) if not category_ids.is_empty() else ""
	current_category_id = current_main_category_id
	_build_interface()
	_on_history_changed(game_state.can_undo(), game_state.can_redo())
	_select_category(current_main_category_id)
	_on_state_changed("ready")
	set_process_unhandled_input(true)


func _build_interface() -> void:
	var page := ColorRect.new()
	page.color = COLOR_PAGE
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(page)

	var page_margin := MarginContainer.new()
	page_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_margin.add_theme_constant_override("margin_left", 20)
	page_margin.add_theme_constant_override("margin_top", 16)
	page_margin.add_theme_constant_override("margin_right", 20)
	page_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(page_margin)

	var page_layout := VBoxContainer.new()
	page_layout.add_theme_constant_override("separation", 10)
	page_margin.add_child(page_layout)

	page_layout.add_child(_build_header())

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	page_layout.add_child(content)
	content.add_child(_build_stage_panel())
	content.add_child(_build_wardrobe_panel())

	status_label = Label.new()
	_build_dialogs()


func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 36)
	header.add_theme_constant_override("separation", 12)

	var title_group := VBoxContainer.new()
	title_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_group)

	var title := Label.new()
	title.text = "GAME THỜI TRANG"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", COLOR_TEXT)
	title_group.add_child(title)

	return header


func _build_stage_panel() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 1.7
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#ffffff"), 18, Color("#eadde8")))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	doll_view = DollViewScript.new()
	doll_view.name = "DollView"
	doll_view.custom_minimum_size = Vector2(560, 560)
	doll_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	doll_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	doll_view.configure(catalog, game_state)
	margin.add_child(doll_view)
	return panel


func _build_wardrobe_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(450, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 1.0
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(COLOR_PANEL, 18, Color("#eadde8")))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var wardrobe := VBoxContainer.new()
	wardrobe.add_theme_constant_override("separation", 10)
	margin.add_child(wardrobe)

	var category_label := Label.new()
	category_label.text = "TỦ ĐỒ"
	category_label.add_theme_font_size_override("font_size", 20)
	category_label.add_theme_color_override("font_color", COLOR_TEXT)
	wardrobe.add_child(category_label)

	category_button_group = ButtonGroup.new()
	var category_flow := HFlowContainer.new()
	category_flow.add_theme_constant_override("h_separation", 6)
	category_flow.add_theme_constant_override("v_separation", 6)
	wardrobe.add_child(category_flow)

	for category_id in catalog.get_visible_category_ids():
		var category: Dictionary = catalog.get_category(str(category_id))
		var button := Button.new()
		button.text = str(category.get("display_name", category_id))
		button.toggle_mode = true
		button.button_group = category_button_group
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(92, 34)
		_apply_button_style(button, "category")
		button.pressed.connect(_select_category.bind(str(category_id)))
		category_flow.add_child(button)
		category_buttons[str(category_id)] = button

	subcategory_flow = HFlowContainer.new()
	subcategory_flow.add_theme_constant_override("h_separation", 6)
	subcategory_flow.add_theme_constant_override("v_separation", 6)
	wardrobe.add_child(subcategory_flow)

	wardrobe.add_child(HSeparator.new())

	var category_header := HBoxContainer.new()
	wardrobe.add_child(category_header)

	category_title = Label.new()
	category_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	category_title.add_theme_font_size_override("font_size", 19)
	category_title.add_theme_color_override("font_color", COLOR_TEXT)
	category_header.add_child(category_title)

	lock_toggle = CheckButton.new()
	lock_toggle.text = "Khóa"
	lock_toggle.tooltip_text = "Giữ nguyên lựa chọn trong danh mục này."
	lock_toggle.custom_minimum_size = Vector2(96, 36)
	lock_toggle.add_theme_color_override("font_color", COLOR_TEXT)
	lock_toggle.add_theme_color_override("font_pressed_color", COLOR_ACCENT_DARK)
	lock_toggle.add_theme_font_size_override("font_size", 14)
	lock_toggle.toggled.connect(_on_lock_toggled)
	category_header.add_child(lock_toggle)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	wardrobe.add_child(scroll)

	item_grid = GridContainer.new()
	item_grid.columns = ITEM_GRID_COLUMNS
	item_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_grid.add_theme_constant_override("h_separation", 10)
	item_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(item_grid)

	wardrobe.add_child(HSeparator.new())
	wardrobe.add_child(_build_action_grid())
	return panel


func _build_action_grid() -> Control:
	var actions := HBoxContainer.new()
	actions.name = "ActionBar"
	actions.add_theme_constant_override("h_separation", 7)
	actions.alignment = BoxContainer.ALIGNMENT_CENTER

	undo_button = _action_button("UndoButton", ACTION_ICON_UNDO, "Hoàn tác", _undo)
	redo_button = _action_button("RedoButton", ACTION_ICON_REDO, "Làm lại", _redo)
	reset_button = _action_button("ResetButton", ACTION_ICON_RESET, "Reset", _ask_reset)
	actions.add_child(undo_button)
	actions.add_child(redo_button)
	actions.add_child(reset_button)
	return actions


func _action_button(node_name: String, icon_texture: Texture2D, accessible_label: String, callback: Callable) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = ""
	button.icon = icon_texture
	button.expand_icon = false
	button.add_theme_constant_override("icon_max_width", 24)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.tooltip_text = accessible_label
	button.accessibility_name = accessible_label
	button.custom_minimum_size = Vector2(52, 44)
	button.focus_mode = Control.FOCUS_ALL
	_apply_button_style(button, "action")
	button.add_theme_color_override("icon_normal_color", Color.WHITE)
	button.add_theme_color_override("icon_hover_color", Color.WHITE)
	button.add_theme_color_override("icon_pressed_color", Color.WHITE)
	button.add_theme_color_override("icon_focus_color", Color.WHITE)
	button.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 0.46))
	button.pressed.connect(callback)
	return button


func _build_dialogs() -> void:
	reset_dialog = ConfirmationDialog.new()
	reset_dialog.title = "Đặt lại trang phục"
	reset_dialog.dialog_text = "Khôi phục outfit và phông nền mặc định? Bạn vẫn có thể Hoàn tác sau đó."
	reset_dialog.ok_button_text = "Đặt lại"
	reset_dialog.cancel_button_text = "Hủy"
	reset_dialog.confirmed.connect(_reset_to_default)
	add_child(reset_dialog)



func _select_category(category_id: String) -> void:
	if not catalog.get_visible_category_ids().has(category_id):
		return
	current_main_category_id = category_id
	for id in category_buttons.keys():
		category_buttons[id].button_pressed = id == category_id
	_rebuild_subcategory_navigation()
	var subcategory_ids: Array = catalog.get_visible_subcategory_ids(category_id)
	if not subcategory_ids.is_empty():
		current_item_group_id = ""
		current_category_id = str(subcategory_ids[0])
		_select_subcategory(current_category_id)
		return
	current_category_id = category_id
	var item_groups: Array = catalog.get_visible_item_groups(category_id)
	current_item_group_id = str(item_groups[0].get("id", "")) if not item_groups.is_empty() else ""
	if current_item_group_id.is_empty():
		_select_subcategory(current_category_id)
	else:
		_select_item_group(current_item_group_id)


func _rebuild_subcategory_navigation() -> void:
	for child in subcategory_flow.get_children():
		child.queue_free()
	subcategory_buttons.clear()
	subcategory_button_group = ButtonGroup.new()
	var subcategory_ids: Array = catalog.get_visible_subcategory_ids(current_main_category_id)
	var item_groups: Array = catalog.get_visible_item_groups(current_main_category_id) if subcategory_ids.is_empty() else []
	subcategory_flow.visible = not subcategory_ids.is_empty() or not item_groups.is_empty()
	for category_id in subcategory_ids:
		var category: Dictionary = catalog.get_category(str(category_id))
		var button := Button.new()
		button.text = str(category.get("display_name", category_id))
		button.toggle_mode = true
		button.button_group = subcategory_button_group
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(92, 32)
		_apply_button_style(button, "category")
		button.pressed.connect(_select_subcategory.bind(str(category_id)))
		subcategory_flow.add_child(button)
		subcategory_buttons[str(category_id)] = button
	for group in item_groups:
		var group_id := str(group.get("id", ""))
		var button := Button.new()
		button.text = str(group.get("display_name", group_id))
		button.toggle_mode = true
		button.button_group = subcategory_button_group
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(92, 32)
		_apply_button_style(button, "category")
		button.pressed.connect(_select_item_group.bind(group_id))
		subcategory_flow.add_child(button)
		subcategory_buttons[group_id] = button


func _select_subcategory(category_id: String) -> void:
	var subcategory_ids: Array = catalog.get_visible_subcategory_ids(current_main_category_id)
	if not subcategory_ids.is_empty() and not subcategory_ids.has(category_id):
		return
	current_category_id = category_id
	current_item_group_id = ""
	for id in subcategory_buttons.keys():
		subcategory_buttons[id].button_pressed = id == category_id

	var category: Dictionary = catalog.get_category(category_id)
	category_title.text = str(category.get("display_name", category_id))
	lock_toggle.set_pressed_no_signal(bool(game_state.locks.get(category_id, false)))
	_rebuild_item_grid()


func _select_item_group(group_id: String) -> void:
	var groups: Array = catalog.get_visible_item_groups(current_main_category_id)
	if not groups.any(func(group: Dictionary) -> bool: return str(group.get("id", "")) == group_id):
		return
	current_category_id = current_main_category_id
	current_item_group_id = group_id
	for id in subcategory_buttons.keys():
		subcategory_buttons[id].button_pressed = id == group_id
	var group_name := group_id
	for group in groups:
		if str(group.get("id", "")) == group_id:
			group_name = str(group.get("display_name", group_id))
			break
	category_title.text = group_name
	lock_toggle.set_pressed_no_signal(bool(game_state.locks.get(current_category_id, false)))
	_rebuild_item_grid()


func _rebuild_item_grid() -> void:
	for child in item_grid.get_children():
		child.queue_free()
	item_buttons.clear()
	item_button_group = ButtonGroup.new()

	var selected_id := str(game_state.selected.get(current_category_id, ""))
	var visible_items: Array = catalog.get_items_for_category_group(current_category_id, current_item_group_id) if not current_item_group_id.is_empty() else catalog.get_items_for_category(current_category_id)
	for item in visible_items:
		var item_id := str(item.get("id", ""))
		var button := _build_item_tile(item)
		button.button_pressed = item_id == selected_id
		button.pressed.connect(_on_item_pressed.bind(item_id))
		item_grid.add_child(button)
		item_buttons[item_id] = button


func _build_item_tile(item: Dictionary) -> Button:
	var item_id := str(item.get("id", ""))
	var display_name := str(item.get("display_name", item_id))
	var accessible_name := str(item.get("accessible_name", display_name))
	var button: Button
	if str(item.get("render_key", "")) == "none":
		button = NoneTileButton.new()
	else:
		button = Button.new()
	button.text = ""
	button.tooltip_text = _item_tooltip(accessible_name, str(item.get("description", "")))
	button.toggle_mode = true
	button.button_group = item_button_group
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = ITEM_TILE_MIN_SIZE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	var texture := _tile_texture(item)
	if texture != null:
		button.icon = texture
	_apply_button_style(button, "item")
	return button


func _tile_texture(item: Dictionary) -> Texture2D:
	if DisplayServer.get_name() == "headless":
		return null
	if str(item.get("render_key", "")) == "none":
		return null

	var cache_key := _thumbnail_cache_key(item)
	if thumbnail_cache.has(cache_key):
		return thumbnail_cache[cache_key]

	var preview_image: Image = _tile_preview_image(item)
	if preview_image == null:
		return null

	var texture := ImageTexture.create_from_image(preview_image)
	thumbnail_cache[cache_key] = texture
	return texture


func _thumbnail_cache_key(item: Dictionary) -> String:
	var item_id := str(item.get("id", ""))
	var mode := thumbnail_preview_mode_for_item(item)
	var source_path := _preview_source_path(item)
	var skin_id := str(game_state.selected.get("skin", "")) if mode == "face_preview" else ""
	return "%s|%s|%s|%s" % [mode, item_id, source_path, skin_id]


func _tile_preview_image(item: Dictionary) -> Image:
	var mode := thumbnail_preview_mode_for_item(item)
	match mode:
		"none":
			return null
		"cover":
			return _make_background_preview(item)
		"face_preview":
			return _make_face_preview(item)
		"skin_swatch":
			return _make_skin_swatch_preview(item)
		"feature_crop":
			return _make_feature_crop_preview(item)
		"effect_crop":
			return _make_feature_crop_preview(item)
		"hair_preview":
			return _make_hair_preview(item)
		"top_crop":
			return _make_layer_focused_preview(item, Color("#f7f1f5"), 0.08)
		"bottom_crop":
			return _make_layer_focused_preview(item, Color("#f7f1f5"), 0.08)
		_:
			var source_path := _preview_source_path(item)
			if source_path.is_empty():
				return null
			return _make_visible_bounds_preview(source_path, item)


static func thumbnail_preview_mode_for_item(item: Dictionary) -> String:
	if str(item.get("render_key", "")) == "none":
		return "none"
	var configured_mode := str(item.get("preview_mode", "")).strip_edges()
	if not configured_mode.is_empty():
		return configured_mode
	if str(item.get("category", "")) == "background":
		return "cover"
	if str(item.get("category", "")) == "face":
		return "face_preview"
	return "visible_bounds"


func _preview_source_path(item: Dictionary) -> String:
	var thumbnail_path := str(item.get("thumbnail_path", "")).strip_edges()
	if not thumbnail_path.is_empty():
		return thumbnail_path

	var layers: Dictionary = item.get("layers", {})
	for path in layers.values():
		var layer_path := str(path).strip_edges()
		if not layer_path.is_empty():
			return layer_path

	return ""


func _make_visible_bounds_preview(path: String, item: Dictionary = {}) -> Image:
	var source := _load_preview_image(path)
	if source == null:
		return null
	var used_rect := _rect_from_array(item.get("preview_rect", []))
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		used_rect = _alpha_used_rect(source, THUMBNAIL_ALPHA_THRESHOLD)
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return null
	var crop_rect := _padded_rect(used_rect, source.get_size(), THUMBNAIL_PADDING_RATIO)
	return _fit_crop_to_thumbnail(source, crop_rect)


static func _rect_from_array(value: Variant) -> Rect2i:
	if typeof(value) != TYPE_ARRAY or value.size() != 4:
		return Rect2i()
	return Rect2i(int(value[0]), int(value[1]), int(value[2]), int(value[3]))


func _make_face_preview(item: Dictionary) -> Image:
	return _make_head_composite_preview(item, "head_preview_rect")


static func _make_skin_swatch_preview(item: Dictionary) -> Image:
	var image := Image.create(THUMBNAIL_SIZE.x, THUMBNAIL_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(skin_swatch_color_for_item(item))
	return image


func _make_feature_crop_preview(item: Dictionary) -> Image:
	return _make_layer_focused_preview(item, Color("#f1dfd4"), 0.16)


func _make_hair_preview(item: Dictionary) -> Image:
	return _make_layer_focused_preview(item, Color("#f7f1f5"), 0.06)


func _make_layer_focused_preview(item: Dictionary, default_background: Color, default_padding: float) -> Image:
	var source_path := _preview_source_path(item)
	if source_path.is_empty():
		return null
	var source := _load_preview_image(source_path)
	if source == null:
		return null
	var used_rect := thumbnail_preview_rect_for_item(item)
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		used_rect = _alpha_used_rect(source, THUMBNAIL_ALPHA_THRESHOLD)
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return null
	var padding_ratio := float(item.get("preview_padding_ratio", default_padding))
	var crop_rect := _padded_rect(used_rect, source.get_size(), padding_ratio)
	var background := _metadata_color(item, "preview_background", default_background)
	return _fit_crop_to_thumbnail(source, crop_rect, background)


func _make_head_composite_preview(item: Dictionary, rect_key: String) -> Image:
	var body_path := _skin_preview_source_path(item)
	if body_path.is_empty():
		return null

	var body := _load_preview_image(body_path)
	if body == null:
		return null

	var composite := body.duplicate()
	var feature_categories: Array = catalog.character.get("face_feature_categories", [])
	for category_id in feature_categories:
		var feature_item: Dictionary = item if str(item.get("category", "")) == str(category_id) else catalog.get_item(str(catalog.initial_state.get(str(category_id), "")))
		for path in Dictionary(feature_item.get("layers", {})).values():
			var feature := _load_preview_image(str(path))
			if feature != null:
				composite.blend_rect(feature, Rect2i(Vector2i.ZERO, feature.get_size()), Vector2i.ZERO)
	var crop_rect := face_metadata_rect(catalog.character, rect_key).intersection(Rect2i(Vector2i.ZERO, composite.get_size()))
	if crop_rect.size.x <= 0 or crop_rect.size.y <= 0:
		return null
	return _fit_crop_to_thumbnail(composite, crop_rect)


func _skin_preview_source_path(item: Dictionary) -> String:
	if str(item.get("category", "")) == "skin":
		return str(Dictionary(item.get("layers", {})).get("body_core", ""))
	var selected_skin: Dictionary = game_state.get_selected_item("skin")
	var selected_path := str(Dictionary(selected_skin.get("layers", {})).get("body_core", ""))
	if not selected_path.is_empty():
		return selected_path
	return str(Dictionary(catalog.character.get("layers", {})).get("body_core", ""))


static func face_metadata_rect(character: Dictionary, key: String) -> Rect2i:
	var metadata: Dictionary = character.get("face_import_metadata", {})
	var values: Array = metadata.get(key, [])
	if values.size() != 4:
		return Rect2i()
	return Rect2i(int(values[0]), int(values[1]), int(values[2]), int(values[3]))


static func thumbnail_preview_rect_for_item(item: Dictionary) -> Rect2i:
	return _rect_from_array(item.get("preview_rect", []))


static func skin_swatch_color_for_item(item: Dictionary) -> Color:
	return _metadata_color(item, "swatch_color", Color("#d9b99f"))


static func _metadata_color(item: Dictionary, key: String, fallback: Color) -> Color:
	var value := str(item.get(key, ""))
	return Color(value) if Color.html_is_valid(value) else fallback


func _make_background_preview(item: Dictionary) -> Image:
	var placeholder: Dictionary = item.get("placeholder", {})
	var primary := _placeholder_color(placeholder, "primary", Color("#dce7f5"))
	var secondary := _placeholder_color(placeholder, "secondary", Color("#f2d5cb"))
	var render_key := str(item.get("render_key", "background"))

	var image := Image.create(THUMBNAIL_SIZE.x, THUMBNAIL_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(primary)
	match render_key:
		"city":
			_fill_rect(image, Rect2i(0, 126, 192, 66), secondary.darkened(0.12))
			_fill_rect(image, Rect2i(18, 68, 36, 74), secondary.darkened(0.28))
			_fill_rect(image, Rect2i(68, 48, 44, 94), secondary.darkened(0.18))
			_fill_rect(image, Rect2i(128, 76, 42, 66), secondary.darkened(0.34))
			_fill_window_grid(image, Color("#fff6d8"))
		"cafe":
			_fill_rect(image, Rect2i(0, 118, 192, 74), secondary.darkened(0.08))
			_fill_rect(image, Rect2i(26, 38, 64, 58), primary.lightened(0.26))
			_fill_rect(image, Rect2i(116, 42, 48, 68), secondary.darkened(0.2))
			_fill_rect(image, Rect2i(20, 112, 70, 14), Color("#8f6b53"))
		"park":
			_fill_rect(image, Rect2i(0, 110, 192, 82), secondary.darkened(0.02))
			_fill_rect(image, Rect2i(28, 72, 16, 56), Color("#8b6547"))
			_fill_rect(image, Rect2i(116, 64, 18, 68), Color("#7a5a3c"))
			_draw_circle(image, Vector2i(36, 58), 34, primary.darkened(0.18))
			_draw_circle(image, Vector2i(126, 48), 38, primary.darkened(0.24))
		"studio":
			_fill_rect(image, Rect2i(0, 128, 192, 64), secondary.lightened(0.04))
			_fill_rect(image, Rect2i(34, 32, 124, 86), primary.lightened(0.12))
			_fill_rect(image, Rect2i(52, 50, 88, 50), secondary.lightened(0.2))
		_:
			_fill_rect(image, Rect2i(0, 118, 192, 74), secondary)
	return image


func _placeholder_color(placeholder: Dictionary, key: String, fallback: Color) -> Color:
	var value := str(placeholder.get(key, ""))
	if Color.html_is_valid(value):
		return Color(value)
	return fallback


func _load_preview_image(path: String) -> Image:
	return _load_preview_image_static(path)


static func thumbnail_used_rect_for_path(path: String, threshold: int = THUMBNAIL_ALPHA_THRESHOLD) -> Rect2i:
	var image := _load_preview_image_static(path)
	if image == null:
		return Rect2i()
	return _alpha_used_rect(image, threshold)


static func _load_preview_image_static(path: String) -> Image:
	if ResourceLoader.exists(path, "Texture2D"):
		var texture := load(path) as Texture2D
		if texture != null:
			var texture_image := texture.get_image()
			if _prepare_preview_image(texture_image):
				return texture_image

	var image := Image.load_from_file(path)
	if _prepare_preview_image(image):
		return image

	var file_path := path
	if file_path.begins_with("res://") or file_path.begins_with("user://"):
		file_path = ProjectSettings.globalize_path(file_path)
	image = Image.load_from_file(file_path)
	if _prepare_preview_image(image):
		return image
	return null


static func _prepare_preview_image(image: Image) -> bool:
	if image == null or image.is_empty():
		return false
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	return true


static func _alpha_used_rect(image: Image, threshold: int) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if int(roundi(image.get_pixel(x, y).a * 255.0)) >= threshold:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


static func _padded_rect(rect: Rect2i, image_size: Vector2i, padding_ratio: float) -> Rect2i:
	var pad_x := int(ceili(float(rect.size.x) * padding_ratio))
	var pad_y := int(ceili(float(rect.size.y) * padding_ratio))
	var x := maxi(0, rect.position.x - pad_x)
	var y := maxi(0, rect.position.y - pad_y)
	var right := mini(image_size.x, rect.position.x + rect.size.x + pad_x)
	var bottom := mini(image_size.y, rect.position.y + rect.size.y + pad_y)
	return Rect2i(x, y, right - x, bottom - y)


func _fit_crop_to_thumbnail(source: Image, crop_rect: Rect2i, background: Color = Color(1, 1, 1, 0)) -> Image:
	var crop := source.get_region(crop_rect)
	var target := Image.create(THUMBNAIL_SIZE.x, THUMBNAIL_SIZE.y, false, Image.FORMAT_RGBA8)
	target.fill(background)
	var scale := minf(float(THUMBNAIL_SIZE.x) / float(crop.get_width()), float(THUMBNAIL_SIZE.y) / float(crop.get_height()))
	var fitted_size := Vector2i(
		maxi(1, int(round(float(crop.get_width()) * scale))),
		maxi(1, int(round(float(crop.get_height()) * scale)))
	)
	crop.resize(fitted_size.x, fitted_size.y, Image.INTERPOLATE_LANCZOS)
	var offset := Vector2i(
		int((THUMBNAIL_SIZE.x - fitted_size.x) / 2),
		int((THUMBNAIL_SIZE.y - fitted_size.y) / 2)
	)
	target.blit_rect(crop, Rect2i(Vector2i.ZERO, fitted_size), offset)
	return target


func _fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	var clipped := rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	for y in range(clipped.position.y, clipped.position.y + clipped.size.y):
		for x in range(clipped.position.x, clipped.position.x + clipped.size.x):
			image.set_pixel(x, y, color)


func _fill_window_grid(image: Image, color: Color) -> void:
	for y in [84, 104, 124]:
		for x in [30, 80, 94, 140]:
			_fill_rect(image, Rect2i(x, y, 8, 10), color)


func _draw_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	var radius_squared := radius * radius
	var rect := Rect2i(center - Vector2i(radius, radius), Vector2i(radius * 2 + 1, radius * 2 + 1))
	var clipped := rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	for y in range(clipped.position.y, clipped.position.y + clipped.size.y):
		for x in range(clipped.position.x, clipped.position.x + clipped.size.x):
			var delta := Vector2i(x, y) - center
			if delta.x * delta.x + delta.y * delta.y <= radius_squared:
				image.set_pixel(x, y, color)


func _item_tooltip(accessible_name: String, description: String) -> String:
	if description.is_empty():
		return accessible_name
	return "%s\n%s" % [accessible_name, description]


func _on_item_pressed(item_id: String) -> void:
	game_state.select_item(item_id)


func _on_lock_toggled(value: bool) -> void:
	game_state.set_lock(current_category_id, value)


func _randomize() -> void:
	game_state.randomize()


func _undo() -> void:
	game_state.undo()


func _redo() -> void:
	game_state.redo()


func _ask_reset() -> void:
	reset_dialog.popup_centered()


func _reset_to_default() -> void:
	game_state.reset_to_default(true)


func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _save_look() -> void:
	await RenderingServer.frame_post_draw
	var viewport_image := get_viewport().get_texture().get_image()
	var capture_rect: Rect2i = doll_view.get_capture_rect()
	var image_bounds := Rect2i(Vector2i.ZERO, viewport_image.get_size())
	capture_rect = capture_rect.intersection(image_bounds)
	if capture_rect.size.x <= 0 or capture_rect.size.y <= 0:
		return

	var image := viewport_image.get_region(capture_rect)
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	var filename := "thoi-trang-with-thc-%s.png" % stamp

	if OS.has_feature("web"):
		_download_png_in_browser(image.save_png_to_buffer(), filename)
	else:
		image.save_png("user://%s" % filename)


func _download_png_in_browser(bytes: PackedByteArray, filename: String) -> void:
	var base64 := Marshalls.raw_to_base64(bytes)
	var safe_filename := filename.replace("'", "")
	var javascript := """
		(() => {
			const raw = atob('%s');
			const data = new Uint8Array(raw.length);
			for (let i = 0; i < raw.length; i++) data[i] = raw.charCodeAt(i);
			const blob = new Blob([data], {type: 'image/png'});
			const url = URL.createObjectURL(blob);
			const link = document.createElement('a');
			link.href = url;
			link.download = '%s';
			document.body.appendChild(link);
			link.click();
			link.remove();
			setTimeout(() => URL.revokeObjectURL(url), 1000);
		})();
	""" % [base64, safe_filename]
	JavaScriptBridge.eval(javascript)


func _on_state_changed(_reason: String) -> void:
	_ensure_current_category_visible()
	if item_grid != null and is_instance_valid(item_grid):
		lock_toggle.set_pressed_no_signal(bool(game_state.locks.get(current_category_id, false)))
		_rebuild_item_grid()
	var error: Error = save_service.save_data(game_state.export_save_data())
	if error != OK and status_label != null:
		status_label.text = "Cảnh báo: không lưu được trạng thái cục bộ (%s)." % error


func _ensure_current_category_visible() -> void:
	var visible_ids: Array = catalog.get_visible_category_ids()
	if visible_ids.is_empty():
		current_main_category_id = ""
		current_category_id = ""
		return
	if visible_ids.has(current_main_category_id):
		var subcategory_ids: Array = catalog.get_visible_subcategory_ids(current_main_category_id)
		if subcategory_ids.is_empty() or subcategory_ids.has(current_category_id):
			return
		current_category_id = str(subcategory_ids[0])
		return
	current_main_category_id = str(visible_ids[0])
	var subcategory_ids: Array = catalog.get_visible_subcategory_ids(current_main_category_id)
	current_category_id = str(subcategory_ids[0]) if not subcategory_ids.is_empty() else current_main_category_id
	for id in category_buttons.keys():
		category_buttons[id].button_pressed = id == current_main_category_id
	if category_title != null:
		var category: Dictionary = catalog.get_category(current_category_id)
		category_title.text = str(category.get("display_name", current_category_id))


func _on_history_changed(can_undo: bool, can_redo: bool) -> void:
	if undo_button != null:
		undo_button.disabled = not can_undo
	if redo_button != null:
		redo_button.disabled = not can_redo


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.ctrl_pressed and event.keycode == KEY_Z:
		_undo()
		get_viewport().set_input_as_handled()
	elif event.ctrl_pressed and event.keycode == KEY_Y:
		_redo()
		get_viewport().set_input_as_handled()


func _panel_style(background: Color, radius: int, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.25, 0.15, 0.23, 0.08)
	style.shadow_size = 8
	return style


func _apply_button_style(button: Button, role: String) -> void:
	var normal := _button_style(COLOR_BUTTON, Color("#d9ccd5"), 7, 1)
	var hover := _button_style(COLOR_BUTTON_HOVER, COLOR_ACCENT_SOFT, 7, 1)
	var pressed := _button_style(COLOR_ACCENT_DARK, COLOR_ACCENT_DARK, 7, 1)
	var disabled := _button_style(COLOR_BUTTON_DISABLED, Color("#d8d0d5"), 7, 1)
	var focus := _button_style(Color("#ffffff"), COLOR_ACCENT, 7, 2)
	var font_normal := COLOR_TEXT
	var font_pressed := Color.WHITE
	var font_disabled := Color("#8a7e86")

	match role:
		"category":
			normal = _button_style(Color("#fdf7fb"), Color("#d8ccd4"), 6, 1)
			hover = _button_style(Color("#f7e6ef"), COLOR_ACCENT_SOFT, 6, 1)
			pressed = _button_style(COLOR_ACCENT_DARK, COLOR_ACCENT_DARK, 6, 1)
		"item":
			normal = _button_style(Color("#fbf7fa"), Color("#ddd2da"), 8, 1)
			hover = _button_style(Color("#f5e4ed"), COLOR_ACCENT_SOFT, 8, 2)
			pressed = _button_style(Color("#fff1f7"), COLOR_ACCENT_DARK, 8, 4)
			focus = _button_style(Color("#ffffff"), COLOR_ACCENT, 8, 2)
		"action":
			normal = _button_style(Color("#fffafd"), Color("#d8ccd4"), 8, 1)
			hover = _button_style(Color("#f7e6ef"), COLOR_ACCENT, 8, 2)
			pressed = _button_style(Color("#efd3df"), COLOR_ACCENT_DARK, 8, 1)
			disabled = _button_style(COLOR_BUTTON_DISABLED, Color("#d8d0d5"), 8, 1)
			focus = _button_style(Color("#ffffff"), COLOR_ACCENT, 8, 2)
		"primary":
			normal = _button_style(COLOR_ACCENT, COLOR_ACCENT_DARK, 6, 1)
			hover = _button_style(COLOR_ACCENT_DARK, COLOR_ACCENT_DARK, 6, 1)
			pressed = _button_style(Color("#7f2f52"), Color("#7f2f52"), 6, 1)
			font_normal = Color.WHITE
		"strong":
			normal = _button_style(Color("#655d63"), Color("#51484f"), 6, 1)
			hover = _button_style(Color("#51484f"), Color("#51484f"), 6, 1)
			pressed = _button_style(Color("#3f373d"), Color("#3f373d"), 6, 1)
			font_normal = Color.WHITE
		"danger":
			normal = _button_style(Color("#fff9fb"), COLOR_DANGER, 6, 1)
			hover = _button_style(Color("#f8e9ec"), COLOR_DANGER, 6, 1)
			pressed = _button_style(COLOR_DANGER, COLOR_DANGER, 6, 1)
			font_normal = COLOR_DANGER

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_color_override("font_color", font_normal)
	button.add_theme_color_override("font_hover_color", font_normal)
	button.add_theme_color_override("font_pressed_color", font_pressed)
	button.add_theme_color_override("font_disabled_color", font_disabled)
	button.add_theme_font_size_override("font_size", 15)


func _button_style(background: Color, border_color: Color, radius: int, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _show_fatal_error(message: String) -> void:
	var label := Label.new()
	label.text = message
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)
