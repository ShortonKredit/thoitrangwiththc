extends RefCounted

const DEFAULT_CATALOG_PATH := "res://data/catalog.json"

var character: Dictionary = {}
var categories: Array = []
var items: Array = []
var initial_state: Dictionary = {}

var _categories_by_id: Dictionary = {}
var _items_by_id: Dictionary = {}
var _items_by_category: Dictionary = {}


func load_catalog(path: String = DEFAULT_CATALOG_PATH) -> Error:
	clear()
	if not FileAccess.file_exists(path):
		push_error("Không tìm thấy catalog: %s" % path)
		return ERR_FILE_NOT_FOUND

	var raw_text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Catalog JSON không hợp lệ: %s" % path)
		return ERR_PARSE_ERROR

	var root: Dictionary = parsed
	character = _as_dictionary(root.get("character", {}))
	initial_state = _as_dictionary(root.get("initial_state", {}))

	var raw_categories: Array = _as_array(root.get("categories", []))
	for raw_category in raw_categories:
		if typeof(raw_category) != TYPE_DICTIONARY:
			continue
		var category: Dictionary = raw_category.duplicate(true)
		var category_id := str(category.get("id", "")).strip_edges()
		if category_id.is_empty():
			continue
		category["id"] = category_id
		category["display_name"] = str(category.get("display_name", category_id))
		category["allow_none"] = bool(category.get("allow_none", false))
		category["random_default"] = bool(category.get("random_default", true))
		category["order"] = int(category.get("order", categories.size()))
		categories.append(category)
		_categories_by_id[category_id] = category
		_items_by_category[category_id] = []

	categories.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 0)) < int(b.get("order", 0))
	)

	var raw_items: Array = _as_array(root.get("items", []))
	for raw_item in raw_items:
		if typeof(raw_item) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw_item.duplicate(true)
		var item_id := str(item.get("id", "")).strip_edges()
		var category_id := str(item.get("category", "")).strip_edges()
		if item_id.is_empty() or not _categories_by_id.has(category_id):
			continue
		item["id"] = item_id
		item["category"] = category_id
		item["display_name"] = str(item.get("display_name", item_id))
		item["description"] = str(item.get("description", ""))
		item["render_key"] = str(item.get("render_key", "none"))
		item["random_enabled"] = bool(item.get("random_enabled", true))
		item["hidden"] = bool(item.get("hidden", false))
		item["order"] = int(item.get("order", items.size()))
		item["occupies"] = _string_array(item.get("occupies", []))
		item["tags"] = _string_array(item.get("tags", []))
		item["conflicts_with_tags"] = _string_array(item.get("conflicts_with_tags", []))
		item["layers"] = _as_dictionary(item.get("layers", {}))
		item["placeholder"] = _as_dictionary(item.get("placeholder", {}))
		items.append(item)
		_items_by_id[item_id] = item
		_items_by_category[category_id].append(item)

	for category_id in _items_by_category.keys():
		var category_items: Array = _items_by_category[category_id]
		category_items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("order", 0)) < int(b.get("order", 0))
		)

	var errors := validate()
	if not errors.is_empty():
		for message in errors:
			push_error(message)
		return ERR_INVALID_DATA

	return OK


func clear() -> void:
	character.clear()
	categories.clear()
	items.clear()
	initial_state.clear()
	_categories_by_id.clear()
	_items_by_id.clear()
	_items_by_category.clear()


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if categories.is_empty():
		errors.append("Catalog phải có ít nhất một category.")
	if items.is_empty():
		errors.append("Catalog phải có ít nhất một item.")

	for category in categories:
		var category_id := str(category.get("id", ""))
		var category_items := get_items_for_category(category_id, true)
		if category_items.is_empty():
			errors.append("Category '%s' chưa có item." % category_id)
		if bool(category.get("allow_none", false)) and get_none_item_id(category_id).is_empty():
			errors.append("Category '%s' cho phép tháo nhưng chưa có item render_key='none'." % category_id)

	for category_id in get_category_ids():
		var initial_item_id := str(initial_state.get(category_id, ""))
		if initial_item_id.is_empty():
			errors.append("initial_state thiếu category '%s'." % category_id)
		elif not has_item(initial_item_id):
			errors.append("initial_state tham chiếu item không tồn tại: '%s'." % initial_item_id)
		elif str(get_item(initial_item_id).get("category", "")) != category_id:
			errors.append("Item '%s' không thuộc category '%s'." % [initial_item_id, category_id])

	return errors


func get_category_ids() -> Array:
	var result: Array = []
	for category in categories:
		result.append(str(category.get("id", "")))
	return result


func get_category(category_id: String) -> Dictionary:
	if not _categories_by_id.has(category_id):
		return {}
	return _categories_by_id[category_id].duplicate(true)


func get_item(item_id: String) -> Dictionary:
	if not _items_by_id.has(item_id):
		return {}
	return _items_by_id[item_id].duplicate(true)


func get_items_for_category(category_id: String, include_hidden: bool = false) -> Array:
	var result: Array = []
	for item in _items_by_category.get(category_id, []):
		if not include_hidden and bool(item.get("hidden", false)):
			continue
		result.append(item.duplicate(true))
	return result


func get_random_items_for_category(category_id: String) -> Array:
	var result: Array = []
	for item in get_items_for_category(category_id):
		if bool(item.get("random_enabled", true)):
			result.append(item)
	return result


func get_none_item_id(category_id: String) -> String:
	for item in _items_by_category.get(category_id, []):
		if str(item.get("render_key", "")) == "none":
			return str(item.get("id", ""))
	return ""


func get_fallback_item_id(category_id: String) -> String:
	var none_id := get_none_item_id(category_id)
	if not none_id.is_empty():
		return none_id
	var category_items := get_items_for_category(category_id)
	if category_items.is_empty():
		return ""
	return str(category_items[0].get("id", ""))


func get_default_state() -> Dictionary:
	return initial_state.duplicate(true)


func has_item(item_id: String) -> bool:
	return _items_by_id.has(item_id)


func sanitize_selection(candidate: Dictionary) -> Dictionary:
	var result := get_default_state()
	for category_id in get_category_ids():
		var candidate_id := str(candidate.get(category_id, ""))
		if has_item(candidate_id) and str(get_item(candidate_id).get("category", "")) == category_id:
			result[category_id] = candidate_id
	return result


func _as_dictionary(value: Variant) -> Dictionary:
	return value.duplicate(true) if typeof(value) == TYPE_DICTIONARY else {}


func _as_array(value: Variant) -> Array:
	return value.duplicate(true) if typeof(value) == TYPE_ARRAY else []


func _string_array(value: Variant) -> Array:
	var result: Array = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		result.append(str(entry))
	return result
