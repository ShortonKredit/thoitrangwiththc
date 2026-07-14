extends Control

const ItemCatalogScript = preload("res://scripts/core/item_catalog.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")
const SaveServiceScript = preload("res://scripts/core/save_service.gd")
const DollViewScript = preload("res://scripts/rendering/doll_view.gd")

const COLOR_PAGE := Color("#f7f1f8")
const COLOR_PANEL := Color("#fffafd")
const COLOR_ACCENT := Color("#c65e88")
const COLOR_ACCENT_SOFT := Color("#f3d5e1")
const COLOR_TEXT := Color("#493b43")
const COLOR_MUTED := Color("#806f78")

var catalog: RefCounted
var game_state: RefCounted
var save_service: RefCounted
var doll_view: Control

var current_category_id: String = ""
var category_button_group: ButtonGroup
var item_button_group: ButtonGroup
var category_buttons: Dictionary = {}
var item_buttons: Dictionary = {}

var item_grid: GridContainer
var category_title: Label
var category_help: Label
var lock_toggle: CheckButton
var status_label: Label
var undo_button: Button
var redo_button: Button
var reset_dialog: ConfirmationDialog
var clear_data_dialog: ConfirmationDialog


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

	var category_ids: Array = catalog.get_category_ids()
	current_category_id = str(category_ids[0]) if not category_ids.is_empty() else ""
	_build_interface()
	_select_category(current_category_id)
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
	page_layout.add_theme_constant_override("separation", 12)
	page_margin.add_child(page_layout)

	page_layout.add_child(_build_header())

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	page_layout.add_child(content)
	content.add_child(_build_stage_panel())
	content.add_child(_build_wardrobe_panel())

	status_label = Label.new()
	status_label.text = "Sẵn sàng phối đồ. Phím tắt: Ctrl+Z, Ctrl+Y, R và F11."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", COLOR_MUTED)
	status_label.add_theme_font_size_override("font_size", 13)
	page_layout.add_child(status_label)

	_build_dialogs()


func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)

	var title_group := VBoxContainer.new()
	title_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_group)

	var title := Label.new()
	title.text = "THỜI TRANG WITH THC"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", COLOR_TEXT)
	title_group.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Phối đồ đời thường thời trang • Không đăng nhập • Dữ liệu lưu trên thiết bị"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", COLOR_MUTED)
	title_group.add_child(subtitle)

	var privacy_badge := Label.new()
	privacy_badge.text = "LOCAL ONLY"
	privacy_badge.tooltip_text = "Game không cần tài khoản và không có backend người dùng."
	privacy_badge.add_theme_font_size_override("font_size", 13)
	privacy_badge.add_theme_color_override("font_color", COLOR_ACCENT)
	privacy_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(privacy_badge)
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

	for category in catalog.categories:
		var category_id := str(category.get("id", ""))
		var button := Button.new()
		button.text = str(category.get("display_name", category_id))
		button.toggle_mode = true
		button.button_group = category_button_group
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(92, 34)
		button.pressed.connect(_select_category.bind(category_id))
		category_flow.add_child(button)
		category_buttons[category_id] = button

	wardrobe.add_child(HSeparator.new())

	var category_header := HBoxContainer.new()
	wardrobe.add_child(category_header)

	var title_group := VBoxContainer.new()
	title_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	category_header.add_child(title_group)

	category_title = Label.new()
	category_title.add_theme_font_size_override("font_size", 19)
	category_title.add_theme_color_override("font_color", COLOR_TEXT)
	title_group.add_child(category_title)

	category_help = Label.new()
	category_help.add_theme_font_size_override("font_size", 12)
	category_help.add_theme_color_override("font_color", COLOR_MUTED)
	category_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_group.add_child(category_help)

	lock_toggle = CheckButton.new()
	lock_toggle.text = "Khóa"
	lock_toggle.tooltip_text = "Giữ nguyên danh mục này khi bấm Phối ngẫu nhiên."
	lock_toggle.toggled.connect(_on_lock_toggled)
	category_header.add_child(lock_toggle)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	wardrobe.add_child(scroll)

	item_grid = GridContainer.new()
	item_grid.columns = 2
	item_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_grid.add_theme_constant_override("h_separation", 8)
	item_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(item_grid)

	wardrobe.add_child(HSeparator.new())
	wardrobe.add_child(_build_action_grid())
	return panel


func _build_action_grid() -> Control:
	var actions := GridContainer.new()
	actions.columns = 3
	actions.add_theme_constant_override("h_separation", 7)
	actions.add_theme_constant_override("v_separation", 7)

	undo_button = _action_button("Hoàn tác", _undo, "Ctrl+Z")
	redo_button = _action_button("Làm lại", _redo, "Ctrl+Y")
	actions.add_child(undo_button)
	actions.add_child(redo_button)
	actions.add_child(_action_button("Ngẫu nhiên", _randomize, "R"))
	actions.add_child(_action_button("Đặt lại", _ask_reset))
	actions.add_child(_action_button("Lưu PNG", _save_look))
	actions.add_child(_action_button("Toàn màn hình", _toggle_fullscreen, "F11"))

	var clear_button := _action_button("Xóa dữ liệu lưu", _ask_clear_data)
	clear_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(clear_button)
	return actions


func _action_button(text: String, callback: Callable, shortcut_text: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 42)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	if not shortcut_text.is_empty():
		button.tooltip_text = "Phím tắt: %s" % shortcut_text
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

	clear_data_dialog = ConfirmationDialog.new()
	clear_data_dialog.title = "Xóa dữ liệu đã lưu"
	clear_data_dialog.dialog_text = "Xóa outfit và các khóa đã lưu trên trình duyệt/máy này?"
	clear_data_dialog.ok_button_text = "Xóa dữ liệu"
	clear_data_dialog.cancel_button_text = "Hủy"
	clear_data_dialog.confirmed.connect(_clear_saved_data)
	add_child(clear_data_dialog)


func _select_category(category_id: String) -> void:
	if catalog.get_category(category_id).is_empty():
		return
	current_category_id = category_id
	for id in category_buttons.keys():
		category_buttons[id].button_pressed = id == category_id

	var category: Dictionary = catalog.get_category(category_id)
	category_title.text = str(category.get("display_name", category_id))
	category_help.text = str(category.get("description", "Chọn một item để mặc ngay."))
	lock_toggle.set_pressed_no_signal(bool(game_state.locks.get(category_id, false)))
	_rebuild_item_grid()


func _rebuild_item_grid() -> void:
	for child in item_grid.get_children():
		child.queue_free()
	item_buttons.clear()
	item_button_group = ButtonGroup.new()

	var selected_id := str(game_state.selected.get(current_category_id, ""))
	for item in catalog.get_items_for_category(current_category_id):
		var item_id := str(item.get("id", ""))
		var button := Button.new()
		button.text = str(item.get("display_name", item_id))
		button.tooltip_text = str(item.get("description", ""))
		button.toggle_mode = true
		button.button_group = item_button_group
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 56)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.button_pressed = item_id == selected_id
		button.pressed.connect(_on_item_pressed.bind(item_id))
		item_grid.add_child(button)
		item_buttons[item_id] = button


func _on_item_pressed(item_id: String) -> void:
	var item: Dictionary = catalog.get_item(item_id)
	if game_state.select_item(item_id):
		status_label.text = "%s: %s" % [category_title.text, str(item.get("display_name", item_id))]


func _on_lock_toggled(value: bool) -> void:
	if game_state.set_lock(current_category_id, value):
		status_label.text = "%s danh mục %s khi phối ngẫu nhiên." % ["Đã khóa" if value else "Đã mở khóa", category_title.text]


func _randomize() -> void:
	game_state.randomize()
	status_label.text = "Đã tạo một outfit ngẫu nhiên. Các danh mục bị khóa được giữ nguyên."


func _undo() -> void:
	if game_state.undo():
		status_label.text = "Đã hoàn tác thao tác gần nhất."


func _redo() -> void:
	if game_state.redo():
		status_label.text = "Đã thực hiện lại thao tác."


func _ask_reset() -> void:
	reset_dialog.popup_centered()


func _reset_to_default() -> void:
	game_state.reset_to_default(true)
	status_label.text = "Đã khôi phục outfit mặc định; các khóa vẫn được giữ."


func _ask_clear_data() -> void:
	clear_data_dialog.popup_centered()


func _clear_saved_data() -> void:
	var error: Error = save_service.clear_data()
	if error == OK:
		game_state.reset_to_default(false)
		status_label.text = "Đã xóa dữ liệu cục bộ và khôi phục trạng thái ban đầu."
	else:
		status_label.text = "Không xóa được dữ liệu. Mã lỗi: %s" % error


func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		status_label.text = "Đã thoát toàn màn hình."
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		status_label.text = "Đang ở chế độ toàn màn hình."


func _save_look() -> void:
	status_label.text = "Đang tạo ảnh PNG..."
	await RenderingServer.frame_post_draw
	var viewport_image := get_viewport().get_texture().get_image()
	var capture_rect: Rect2i = doll_view.get_capture_rect()
	var image_bounds := Rect2i(Vector2i.ZERO, viewport_image.get_size())
	capture_rect = capture_rect.intersection(image_bounds)
	if capture_rect.size.x <= 0 or capture_rect.size.y <= 0:
		status_label.text = "Không xác định được khu vực nhân vật để lưu ảnh."
		return

	var image := viewport_image.get_region(capture_rect)
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	var filename := "thoi-trang-with-thc-%s.png" % stamp

	if OS.has_feature("web"):
		_download_png_in_browser(image.save_png_to_buffer(), filename)
		status_label.text = "Đã gửi ảnh PNG tới trình duyệt để tải xuống."
	else:
		var relative_path := "user://%s" % filename
		var error := image.save_png(relative_path)
		status_label.text = (
			"Đã lưu tại: %s" % ProjectSettings.globalize_path(relative_path)
			if error == OK
			else "Không lưu được ảnh. Mã lỗi: %s" % error
		)


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
	if item_grid != null and is_instance_valid(item_grid):
		lock_toggle.set_pressed_no_signal(bool(game_state.locks.get(current_category_id, false)))
		_rebuild_item_grid()
	var error: Error = save_service.save_data(game_state.export_save_data())
	if error != OK and status_label != null:
		status_label.text = "Cảnh báo: không lưu được trạng thái cục bộ (%s)." % error


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
	elif event.keycode == KEY_R:
		_randomize()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F11:
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
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


func _show_fatal_error(message: String) -> void:
	var label := Label.new()
	label.text = message
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)
