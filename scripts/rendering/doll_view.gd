extends Control

const LOGICAL_SIZE := Vector2(512.0, 768.0)
const SKIN := Color("#efc3a5")
const SKIN_SHADOW := Color("#d9a78a")
const OUTLINE := Color("#5d4852")
const WHITE := Color("#fffafc")
const BLACK := Color("#352d33")
const BASE_TOP := Color("#f8edf3")
const BASE_BOTTOM := Color("#c27d91")
const BASE_TRIM := Color("#d9a8ba")

var catalog: RefCounted
var game_state: RefCounted
var _texture_cache: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func configure(item_catalog: RefCounted, state: RefCounted) -> void:
	catalog = item_catalog
	game_state = state
	if not game_state.changed.is_connected(_on_state_changed):
		game_state.changed.connect(_on_state_changed)
	queue_redraw()


func get_capture_rect() -> Rect2i:
	var rect := get_global_rect()
	return Rect2i(Vector2i(rect.position.round()), Vector2i(rect.size.round()))


static func get_base_outfit_layer_order() -> PackedStringArray:
	return PackedStringArray(["body_core", "fallback_top", "fallback_bottom", "fashion"])


static func get_png_layer_paths(item_catalog: RefCounted, state: RefCounted) -> Dictionary:
	var layers: Dictionary = {}
	var character_layers: Dictionary = item_catalog.character.get("layers", {})

	var dress: Dictionary = state.get_selected_item("dress")
	var top: Dictionary = state.get_selected_item("top")
	var bottom: Dictionary = state.get_selected_item("bottom")
	var has_dress := _is_selected_item(dress)
	var has_top := _is_selected_item(top)
	var has_bottom := _is_selected_item(bottom)

	if character_layers.has("body_core"):
		layers["body_core"] = str(character_layers["body_core"])

	if not has_dress:
		if not has_bottom and character_layers.has("fallback_bottom"):
			layers["fallback_bottom"] = str(character_layers["fallback_bottom"])
		if not has_top and character_layers.has("fallback_top"):
			layers["fallback_top"] = str(character_layers["fallback_top"])

	for category_id in item_catalog.get_category_ids():
		var item: Dictionary = state.get_selected_item(str(category_id))
		if str(category_id) == "top" and (has_dress or not has_top):
			continue
		if str(category_id) == "bottom" and (has_dress or not has_bottom):
			continue
		if str(category_id) == "dress" and not has_dress:
			continue
		var item_layers: Dictionary = item.get("layers", {})
		for layer_name in item_layers.keys():
			layers[str(layer_name)] = str(item_layers[layer_name])

	return layers


func _on_state_changed(_reason: String) -> void:
	queue_redraw()


func _draw() -> void:
	if catalog == null or game_state == null:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#f4edf6"))
		return

	var background: Dictionary = game_state.get_selected_item("background")
	_draw_background(background)

	var character_mode := str(catalog.character.get("mode", "procedural"))
	if character_mode == "png":
		var source_rect := _get_png_source_rect()
		var target_rect := _fit_rect(source_rect.size, Rect2(Vector2.ZERO, size))
		_draw_png_character(target_rect)
	else:
		var target_rect := _fit_rect(LOGICAL_SIZE, Rect2(Vector2.ZERO, size))
		_draw_procedural_character(target_rect)


func _fit_rect(content_size: Vector2, bounds: Rect2) -> Rect2:
	var scale_factor := minf(bounds.size.x / content_size.x, bounds.size.y / content_size.y)
	var result_size := content_size * scale_factor
	return Rect2(bounds.position + (bounds.size - result_size) * 0.5, result_size)


func _draw_background(item: Dictionary) -> void:
	var placeholder: Dictionary = item.get("placeholder", {})
	var primary := _color(placeholder.get("primary", "#f2e8f3"), Color("#f2e8f3"))
	var secondary := _color(placeholder.get("secondary", "#dfcce6"), Color("#dfcce6"))
	draw_rect(Rect2(Vector2.ZERO, size), primary)

	match str(item.get("render_key", "studio")):
		"city":
			var horizon := size.y * 0.63
			draw_rect(Rect2(0, horizon, size.x, size.y - horizon), secondary)
			for index in range(7):
				var width := size.x / 9.0
				var height := size.y * (0.18 + (index % 3) * 0.05)
				var x := size.x * 0.06 + index * size.x * 0.135
				draw_rect(Rect2(x, horizon - height, width, height), secondary.darkened(0.08 + index * 0.015))
				for row in range(3):
					for col in range(2):
						draw_rect(Rect2(x + 12 + col * 24, horizon - height + 18 + row * 30, 10, 15), Color(1, 1, 1, 0.38))
		"cafe":
			var floor_y := size.y * 0.72
			draw_rect(Rect2(0, floor_y, size.x, size.y - floor_y), secondary)
			draw_rect(Rect2(size.x * 0.08, size.y * 0.12, size.x * 0.25, size.y * 0.28), Color(1, 1, 1, 0.48))
			draw_circle(Vector2(size.x * 0.82, size.y * 0.22), 48, Color(1, 1, 1, 0.35))
			draw_line(Vector2(size.x * 0.12, floor_y), Vector2(size.x * 0.04, size.y), secondary.darkened(0.12), 6)
		"park":
			var ground_y := size.y * 0.70
			draw_rect(Rect2(0, ground_y, size.x, size.y - ground_y), secondary)
			for ratio in [0.10, 0.30, 0.76, 0.91]:
				var base := Vector2(size.x * ratio, ground_y + 20)
				draw_line(base, base + Vector2(0, -120), Color("#86634f"), 18, true)
				draw_circle(base + Vector2(0, -150), 70, Color("#73b982"))
		"studio", _:
			var floor_y := size.y * 0.79
			draw_rect(Rect2(0, floor_y, size.x, size.y - floor_y), secondary)
			draw_circle(Vector2(size.x * 0.5, size.y * 0.45), minf(size.x, size.y) * 0.33, Color(1, 1, 1, 0.36))
			for ratio in [0.15, 0.85]:
				draw_line(Vector2(size.x * ratio, 0), Vector2(size.x * 0.48, floor_y), Color(1, 1, 1, 0.16), 50)


func _draw_procedural_character(target_rect: Rect2) -> void:
	var scale_factor := target_rect.size.x / LOGICAL_SIZE.x
	draw_set_transform(target_rect.position, 0.0, Vector2(scale_factor, scale_factor))

	var hair: Dictionary = game_state.get_selected_item("hair")
	var top: Dictionary = game_state.get_selected_item("top")
	var bottom: Dictionary = game_state.get_selected_item("bottom")
	var dress: Dictionary = game_state.get_selected_item("dress")
	var shoes: Dictionary = game_state.get_selected_item("shoes")
	var glasses: Dictionary = game_state.get_selected_item("glasses")
	var headwear: Dictionary = game_state.get_selected_item("headwear")
	var accessory: Dictionary = game_state.get_selected_item("accessory")

	_draw_hair_back(hair)
	_draw_legs()
	_draw_torso()
	_draw_base_outfit()
	_draw_bottom(bottom)
	_draw_top(top)
	_draw_dress(dress)
	_draw_arms()
	_draw_head()
	_draw_hair_front(hair)
	_draw_face()
	_draw_shoes(shoes)
	_draw_glasses(glasses)
	_draw_headwear(headwear)
	_draw_accessory(accessory)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_png_character(target_rect: Rect2) -> void:
	var layers := get_png_layer_paths(catalog, game_state)
	var layer_order: Array = catalog.character.get("layer_order", [])
	var source_rect := _get_png_source_rect()
	for layer_name in layer_order:
		var path := str(layers.get(str(layer_name), ""))
		if path.is_empty():
			continue
		var texture := _load_texture(path)
		if texture != null:
			draw_texture_rect_region(texture, target_rect, source_rect)


func _get_png_source_rect() -> Rect2:
	var canvas_size := _vector2_from_array(catalog.character.get("canvas_size", []), LOGICAL_SIZE)
	var visible_rect: Array = catalog.character.get("visible_canvas_rect", [])
	if visible_rect.size() == 4:
		return Rect2(
			Vector2(float(visible_rect[0]), float(visible_rect[1])),
			Vector2(float(visible_rect[2]), float(visible_rect[3]))
		)
	return Rect2(Vector2.ZERO, canvas_size)


func _load_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path]
	if not ResourceLoader.exists(path, "Texture2D"):
		push_warning("Thiếu texture layer: %s" % path)
		return null
	var texture: Texture2D = load(path)
	_texture_cache[path] = texture
	return texture


func _draw_hair_back(item: Dictionary) -> void:
	var key := str(item.get("render_key", "long_straight"))
	var color := _item_primary(item, Color("#4c3028"))
	match key:
		"bob":
			draw_circle(Vector2(256, 135), 64, color)
			draw_rect(Rect2(198, 135, 116, 70), color)
		"ponytail":
			draw_circle(Vector2(256, 132), 63, color)
			draw_circle(Vector2(330, 150), 33, color)
			draw_polygon(PackedVector2Array([Vector2(323, 145), Vector2(360, 205), Vector2(326, 250)]), PackedColorArray([color]))
		"soft_waves":
			for point in [Vector2(205, 122), Vector2(233, 95), Vector2(270, 93), Vector2(304, 118), Vector2(195, 165), Vector2(317, 165), Vector2(208, 218), Vector2(304, 218), Vector2(220, 280), Vector2(292, 280)]:
				draw_circle(point, 32, color)
		"long_straight", _:
			draw_circle(Vector2(256, 132), 66, color)
			draw_polygon(PackedVector2Array([Vector2(195, 130), Vector2(317, 130), Vector2(306, 340), Vector2(206, 340)]), PackedColorArray([color]))


func _draw_legs() -> void:
	draw_line(Vector2(233, 430), Vector2(228, 674), SKIN, 31, true)
	draw_line(Vector2(279, 430), Vector2(284, 674), SKIN, 31, true)
	draw_line(Vector2(233, 430), Vector2(228, 674), SKIN_SHADOW, 2, true)
	draw_line(Vector2(279, 430), Vector2(284, 674), SKIN_SHADOW, 2, true)


func _draw_torso() -> void:
	draw_polygon(PackedVector2Array([Vector2(207, 222), Vector2(305, 222), Vector2(292, 422), Vector2(220, 422)]), PackedColorArray([SKIN]))


func _draw_base_outfit() -> void:
	draw_polygon(PackedVector2Array([Vector2(207, 225), Vector2(305, 225), Vector2(297, 358), Vector2(215, 358)]), PackedColorArray([BASE_TOP]))
	draw_polygon(PackedVector2Array([Vector2(207, 225), Vector2(184, 280), Vector2(204, 292), Vector2(222, 246)]), PackedColorArray([BASE_TOP]))
	draw_polygon(PackedVector2Array([Vector2(305, 225), Vector2(328, 280), Vector2(308, 292), Vector2(290, 246)]), PackedColorArray([BASE_TOP]))
	draw_line(Vector2(218, 225), Vector2(294, 225), BASE_TRIM, 4)
	draw_line(Vector2(216, 358), Vector2(296, 358), BASE_TRIM, 4)
	draw_polygon(PackedVector2Array([Vector2(216, 350), Vector2(296, 350), Vector2(290, 438), Vector2(262, 438), Vector2(256, 391), Vector2(250, 438), Vector2(222, 438)]), PackedColorArray([BASE_BOTTOM]))
	draw_line(Vector2(220, 365), Vector2(292, 365), BASE_TRIM, 4)


func _draw_top(item: Dictionary) -> void:
	var key := str(item.get("render_key", "none"))
	if key == "none":
		return
	var primary := _item_primary(item, Color("#f4a6bd"))
	var secondary := _item_secondary(item, primary.lightened(0.2))
	match key:
		"tee":
			draw_polygon(PackedVector2Array([Vector2(205, 225), Vector2(307, 225), Vector2(297, 345), Vector2(215, 345)]), PackedColorArray([primary]))
			draw_polygon(PackedVector2Array([Vector2(205, 228), Vector2(174, 278), Vector2(202, 291), Vector2(222, 247)]), PackedColorArray([primary]))
			draw_polygon(PackedVector2Array([Vector2(307, 228), Vector2(338, 278), Vector2(310, 291), Vector2(290, 247)]), PackedColorArray([primary]))
		"cardigan":
			draw_polygon(PackedVector2Array([Vector2(205, 225), Vector2(307, 225), Vector2(298, 370), Vector2(214, 370)]), PackedColorArray([primary]))
			draw_line(Vector2(256, 230), Vector2(256, 369), secondary, 5)
			for y in [264, 300, 336]:
				draw_circle(Vector2(256, y), 4, secondary.darkened(0.18))
		"shirt":
			draw_polygon(PackedVector2Array([Vector2(205, 225), Vector2(307, 225), Vector2(298, 362), Vector2(214, 362)]), PackedColorArray([primary]))
			draw_polygon(PackedVector2Array([Vector2(232, 225), Vector2(256, 255), Vector2(246, 273), Vector2(218, 232)]), PackedColorArray([secondary]))
			draw_polygon(PackedVector2Array([Vector2(280, 225), Vector2(256, 255), Vector2(266, 273), Vector2(294, 232)]), PackedColorArray([secondary]))
			draw_line(Vector2(256, 255), Vector2(256, 362), secondary.darkened(0.12), 3)
		"knit":
			draw_polygon(PackedVector2Array([Vector2(200, 225), Vector2(312, 225), Vector2(301, 370), Vector2(211, 370)]), PackedColorArray([primary]))
			for y in range(247, 356, 18):
				draw_line(Vector2(218, y), Vector2(294, y), Color(1, 1, 1, 0.22), 3)
		"denim_jacket":
			draw_polygon(PackedVector2Array([Vector2(201, 225), Vector2(311, 225), Vector2(300, 357), Vector2(212, 357)]), PackedColorArray([primary]))
			draw_line(Vector2(256, 229), Vector2(256, 357), secondary, 4)
			draw_rect(Rect2(221, 285, 25, 24), secondary, false, 3)
			draw_rect(Rect2(266, 285, 25, 24), secondary, false, 3)
		"blouse", _:
			draw_polygon(PackedVector2Array([Vector2(202, 225), Vector2(310, 225), Vector2(299, 365), Vector2(213, 365)]), PackedColorArray([primary]))
			draw_arc(Vector2(256, 229), 28, 0.25, PI - 0.25, 24, secondary, 6, true)
			draw_circle(Vector2(256, 270), 10, secondary)
			draw_polygon(PackedVector2Array([Vector2(248, 272), Vector2(226, 292), Vector2(250, 296)]), PackedColorArray([secondary]))
			draw_polygon(PackedVector2Array([Vector2(264, 272), Vector2(286, 292), Vector2(262, 296)]), PackedColorArray([secondary]))


func _draw_bottom(item: Dictionary) -> void:
	var key := str(item.get("render_key", "none"))
	if key == "none":
		return
	var primary := _item_primary(item, Color("#8ea7d8"))
	var secondary := _item_secondary(item, primary.lightened(0.18))
	match key:
		"jeans":
			draw_polygon(PackedVector2Array([Vector2(218, 350), Vector2(294, 350), Vector2(281, 535), Vector2(259, 535), Vector2(256, 390), Vector2(253, 535), Vector2(231, 535)]), PackedColorArray([primary]))
			draw_line(Vector2(256, 370), Vector2(256, 520), secondary.darkened(0.15), 3)
		"wide_leg":
			draw_polygon(PackedVector2Array([Vector2(214, 350), Vector2(298, 350), Vector2(300, 550), Vector2(261, 550), Vector2(256, 398), Vector2(251, 550), Vector2(212, 550)]), PackedColorArray([primary]))
		"shorts":
			draw_polygon(PackedVector2Array([Vector2(214, 350), Vector2(298, 350), Vector2(292, 440), Vector2(262, 440), Vector2(256, 388), Vector2(250, 440), Vector2(220, 440)]), PackedColorArray([primary]))
			draw_line(Vector2(218, 370), Vector2(294, 370), secondary, 4)
		"midi_skirt":
			draw_polygon(PackedVector2Array([Vector2(218, 350), Vector2(294, 350), Vector2(326, 535), Vector2(186, 535)]), PackedColorArray([primary]))
			draw_line(Vector2(219, 366), Vector2(293, 366), secondary, 5)
		"cargo":
			draw_polygon(PackedVector2Array([Vector2(214, 350), Vector2(298, 350), Vector2(286, 535), Vector2(260, 535), Vector2(256, 393), Vector2(252, 535), Vector2(226, 535)]), PackedColorArray([primary]))
			draw_rect(Rect2(219, 420, 31, 35), secondary, false, 3)
			draw_rect(Rect2(262, 420, 31, 35), secondary, false, 3)
		"pleated_skirt", _:
			draw_polygon(PackedVector2Array([Vector2(217, 350), Vector2(295, 350), Vector2(323, 472), Vector2(189, 472)]), PackedColorArray([primary]))
			for x in [210, 232, 256, 280, 302]:
				draw_line(Vector2(x, 365), Vector2(256 + (x - 256) * 1.55, 463), Color(1, 1, 1, 0.30), 3)


func _draw_dress(item: Dictionary) -> void:
	var key := str(item.get("render_key", "none"))
	if key == "none":
		return
	var primary := _item_primary(item, Color("#e790b0"))
	var secondary := _item_secondary(item, primary.lightened(0.22))
	match key:
		"denim_dress":
			draw_polygon(PackedVector2Array([Vector2(218, 225), Vector2(294, 225), Vector2(304, 470), Vector2(208, 470)]), PackedColorArray([primary]))
			draw_line(Vector2(235, 225), Vector2(235, 280), secondary, 7)
			draw_line(Vector2(277, 225), Vector2(277, 280), secondary, 7)
			draw_rect(Rect2(237, 305, 38, 42), secondary, false, 4)
		"shirt_dress":
			draw_polygon(PackedVector2Array([Vector2(202, 225), Vector2(310, 225), Vector2(324, 495), Vector2(188, 495)]), PackedColorArray([primary]))
			draw_line(Vector2(256, 248), Vector2(256, 480), secondary.darkened(0.15), 3)
			for y in range(275, 444, 34):
				draw_circle(Vector2(256, y), 4, secondary)
		"wrap_dress":
			draw_polygon(PackedVector2Array([Vector2(203, 225), Vector2(309, 225), Vector2(333, 500), Vector2(179, 500)]), PackedColorArray([primary]))
			draw_line(Vector2(215, 235), Vector2(293, 375), secondary, 6)
			draw_line(Vector2(297, 235), Vector2(219, 375), Color(1, 1, 1, 0.35), 4)
		"simple_evening":
			draw_polygon(PackedVector2Array([Vector2(216, 225), Vector2(296, 225), Vector2(342, 535), Vector2(170, 535)]), PackedColorArray([primary]))
			draw_arc(Vector2(256, 230), 31, 0.15, PI - 0.15, 24, secondary, 7, true)
			draw_line(Vector2(218, 357), Vector2(294, 357), secondary, 7)
		"casual_dress", _:
			draw_polygon(PackedVector2Array([Vector2(205, 225), Vector2(307, 225), Vector2(320, 493), Vector2(192, 493)]), PackedColorArray([primary]))
			draw_line(Vector2(214, 355), Vector2(298, 355), secondary, 7)
			for x in [213, 235, 256, 277, 299]:
				draw_line(Vector2(x, 370), Vector2(256 + (x - 256) * 1.45, 485), Color(1, 1, 1, 0.25), 3)


func _draw_arms() -> void:
	draw_line(Vector2(207, 248), Vector2(164, 445), SKIN, 24, true)
	draw_line(Vector2(305, 248), Vector2(348, 445), SKIN, 24, true)
	draw_circle(Vector2(161, 452), 14, SKIN)
	draw_circle(Vector2(351, 452), 14, SKIN)


func _draw_head() -> void:
	draw_line(Vector2(240, 184), Vector2(238, 222), SKIN, 20, true)
	draw_line(Vector2(272, 184), Vector2(274, 222), SKIN, 20, true)
	draw_circle(Vector2(256, 137), 52, SKIN)


func _draw_hair_front(item: Dictionary) -> void:
	var key := str(item.get("render_key", "long_straight"))
	var color := _item_primary(item, Color("#4c3028"))
	draw_arc(Vector2(256, 133), 51, PI, TAU, 30, color, 18, true)
	match key:
		"bob":
			draw_polygon(PackedVector2Array([Vector2(206, 125), Vector2(247, 86), Vector2(262, 132), Vector2(228, 155)]), PackedColorArray([color]))
		"ponytail":
			draw_polygon(PackedVector2Array([Vector2(205, 124), Vector2(250, 83), Vector2(264, 130), Vector2(231, 154)]), PackedColorArray([color]))
		"soft_waves":
			draw_circle(Vector2(216, 109), 23, color)
			draw_circle(Vector2(244, 91), 24, color)
			draw_circle(Vector2(277, 93), 24, color)
			draw_circle(Vector2(303, 112), 22, color)
		"long_straight", _:
			draw_polygon(PackedVector2Array([Vector2(205, 125), Vector2(250, 82), Vector2(267, 132), Vector2(229, 156)]), PackedColorArray([color]))


func _draw_face() -> void:
	draw_arc(Vector2(234, 138), 8, 0.2, PI - 0.2, 16, BLACK, 3, true)
	draw_arc(Vector2(278, 138), 8, 0.2, PI - 0.2, 16, BLACK, 3, true)
	draw_circle(Vector2(234, 141), 3, BLACK)
	draw_circle(Vector2(278, 141), 3, BLACK)
	draw_arc(Vector2(256, 158), 14, 0.25, PI - 0.25, 20, Color("#b95770"), 3, true)
	draw_circle(Vector2(216, 156), 8, Color(1, 0.45, 0.55, 0.12))
	draw_circle(Vector2(296, 156), 8, Color(1, 0.45, 0.55, 0.12))


func _draw_shoes(item: Dictionary) -> void:
	var key := str(item.get("render_key", "sneakers"))
	var primary := _item_primary(item, Color("#f5f1ef"))
	var secondary := _item_secondary(item, primary.darkened(0.15))
	match key:
		"flats":
			draw_polygon(PackedVector2Array([Vector2(210, 665), Vector2(242, 665), Vector2(246, 697), Vector2(202, 697)]), PackedColorArray([primary]))
			draw_polygon(PackedVector2Array([Vector2(270, 665), Vector2(302, 665), Vector2(310, 697), Vector2(266, 697)]), PackedColorArray([primary]))
		"ankle_boots":
			draw_rect(Rect2(204, 638, 42, 61), primary)
			draw_rect(Rect2(266, 638, 42, 61), primary)
			draw_line(Vector2(205, 677), Vector2(245, 677), secondary, 5)
			draw_line(Vector2(267, 677), Vector2(307, 677), secondary, 5)
		"loafers":
			draw_polygon(PackedVector2Array([Vector2(205, 663), Vector2(244, 663), Vector2(247, 697), Vector2(199, 697)]), PackedColorArray([primary]))
			draw_polygon(PackedVector2Array([Vector2(268, 663), Vector2(307, 663), Vector2(313, 697), Vector2(265, 697)]), PackedColorArray([primary]))
			draw_line(Vector2(211, 676), Vector2(239, 676), secondary, 4)
			draw_line(Vector2(274, 676), Vector2(302, 676), secondary, 4)
		"sneakers", _:
			draw_polygon(PackedVector2Array([Vector2(204, 658), Vector2(242, 658), Vector2(248, 697), Vector2(197, 697)]), PackedColorArray([primary]))
			draw_polygon(PackedVector2Array([Vector2(270, 658), Vector2(308, 658), Vector2(315, 697), Vector2(264, 697)]), PackedColorArray([primary]))
			draw_line(Vector2(207, 681), Vector2(243, 681), secondary, 4)
			draw_line(Vector2(273, 681), Vector2(309, 681), secondary, 4)


func _draw_glasses(item: Dictionary) -> void:
	var key := str(item.get("render_key", "none"))
	if key == "none":
		return
	var color := _item_primary(item, OUTLINE)
	match key:
		"sunglasses":
			draw_rect(Rect2(218, 129, 32, 22), Color(color, 0.78))
			draw_rect(Rect2(262, 129, 32, 22), Color(color, 0.78))
			draw_line(Vector2(250, 139), Vector2(262, 139), color, 4)
		"cat_eye":
			draw_polygon(PackedVector2Array([Vector2(216, 134), Vector2(249, 128), Vector2(246, 153), Vector2(220, 151)]), PackedColorArray([Color(color, 0.18)]))
			draw_polygon(PackedVector2Array([Vector2(263, 128), Vector2(296, 134), Vector2(292, 151), Vector2(266, 153)]), PackedColorArray([Color(color, 0.18)]))
			draw_polyline(PackedVector2Array([Vector2(216, 134), Vector2(249, 128), Vector2(246, 153), Vector2(220, 151), Vector2(216, 134)]), color, 3)
			draw_polyline(PackedVector2Array([Vector2(263, 128), Vector2(296, 134), Vector2(292, 151), Vector2(266, 153), Vector2(263, 128)]), color, 3)
		"round", _:
			draw_arc(Vector2(234, 140), 18, 0, TAU, 24, color, 3, true)
			draw_arc(Vector2(278, 140), 18, 0, TAU, 24, color, 3, true)
			draw_line(Vector2(252, 140), Vector2(260, 140), color, 3)


func _draw_headwear(item: Dictionary) -> void:
	var key := str(item.get("render_key", "none"))
	if key == "none":
		return
	var primary := _item_primary(item, Color("#d784a2"))
	var secondary := _item_secondary(item, primary.lightened(0.2))
	match key:
		"cap":
			draw_arc(Vector2(256, 92), 48, PI, TAU, 24, primary, 20, true)
			draw_polygon(PackedVector2Array([Vector2(256, 92), Vector2(315, 98), Vector2(286, 111)]), PackedColorArray([primary]))
		"headband":
			draw_arc(Vector2(256, 116), 54, PI + 0.25, TAU - 0.25, 24, primary, 8, true)
			draw_circle(Vector2(306, 105), 12, secondary)
		"beret", _:
			_draw_filled_ellipse(Vector2(256, 83), Vector2(58, 23), primary)
			draw_line(Vector2(256, 61), Vector2(263, 50), secondary.darkened(0.25), 4)


func _draw_accessory(item: Dictionary) -> void:
	var key := str(item.get("render_key", "none"))
	if key == "none":
		return
	var primary := _item_primary(item, Color("#d46f97"))
	var secondary := _item_secondary(item, primary.lightened(0.2))
	match key:
		"crossbody":
			draw_line(Vector2(205, 250), Vector2(332, 453), secondary.darkened(0.2), 6)
			draw_rect(Rect2(306, 420, 67, 58), primary, true)
		"necklace":
			draw_arc(Vector2(256, 221), 35, 0.25, PI - 0.25, 24, primary, 4, true)
			draw_circle(Vector2(256, 252), 8, secondary)
		"bracelet":
			draw_arc(Vector2(350, 430), 12, 0, TAU, 18, primary, 5, true)
		"tote":
			draw_rect(Rect2(337, 405, 70, 82), primary, true)
			draw_arc(Vector2(372, 407), 24, PI, TAU, 20, secondary.darkened(0.2), 5, true)
		"handbag", _:
			draw_rect(Rect2(327, 420, 65, 62), primary, true)
			draw_arc(Vector2(359, 422), 22, PI, TAU, 20, secondary.darkened(0.25), 5, true)
			draw_circle(Vector2(359, 452), 5, secondary)


func _draw_filled_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(36):
		var angle := TAU * float(index) / 36.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_polygon(points, PackedColorArray([color]))


func _item_primary(item: Dictionary, fallback: Color) -> Color:
	return _color(_dictionary(item.get("placeholder", {})).get("primary", fallback), fallback)


func _item_secondary(item: Dictionary, fallback: Color) -> Color:
	return _color(_dictionary(item.get("placeholder", {})).get("secondary", fallback), fallback)


func _color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	var text := str(value)
	return Color(text) if Color.html_is_valid(text) else fallback


func _dictionary(value: Variant) -> Dictionary:
	return value if typeof(value) == TYPE_DICTIONARY else {}


static func _is_selected_item(item: Dictionary) -> bool:
	return not item.is_empty() and str(item.get("render_key", "none")) != "none"


func _vector2_from_array(value: Variant, fallback: Vector2) -> Vector2:
	if typeof(value) != TYPE_ARRAY or value.size() < 2:
		return fallback
	return Vector2(float(value[0]), float(value[1]))
