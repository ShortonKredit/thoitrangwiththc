extends RefCounted

signal changed(reason: String)
signal history_changed(can_undo: bool, can_redo: bool)

const HistoryManagerScript = preload("res://scripts/core/history_manager.gd")

var catalog: RefCounted
var selected: Dictionary = {}
var locks: Dictionary = {}
var history: RefCounted


func initialize(item_catalog: RefCounted, restored: Dictionary = {}) -> void:
	catalog = item_catalog
	selected = catalog.get_default_state()
	locks.clear()
	for category_id in catalog.get_category_ids():
		locks[category_id] = false

	if not restored.is_empty():
		selected = catalog.sanitize_selection(_dictionary(restored.get("selected", {})))
		var restored_locks := _dictionary(restored.get("locks", {}))
		for category_id in locks.keys():
			locks[category_id] = bool(restored_locks.get(category_id, false))

	history = HistoryManagerScript.new(50)
	history.reset(snapshot())
	changed.emit("initialize")
	_emit_history_changed()


func select_item(item_id: String, reason: String = "select_item") -> bool:
	var item: Dictionary = catalog.get_item(item_id)
	if item.is_empty():
		return false

	var category_id := str(item.get("category", ""))
	if str(selected.get(category_id, "")) == item_id:
		return false

	_apply_item(item, false)
	_commit(reason)
	return true


func set_lock(category_id: String, value: bool) -> bool:
	if not locks.has(category_id) or bool(locks[category_id]) == value:
		return false
	locks[category_id] = value
	_commit("set_lock")
	return true


func randomize() -> void:
	var locked_snapshot := selected.duplicate(true)
	var category_ids: Array = catalog.get_category_ids()

	for category_id in category_ids:
		var category: Dictionary = catalog.get_category(category_id)
		if bool(category.get("hidden", false)):
			continue
		if bool(locks.get(category_id, false)) or not bool(category.get("random_default", true)):
			continue

		var candidates: Array = catalog.get_random_items_for_category(category_id)
		candidates.shuffle()
		for candidate in candidates:
			if _would_clear_locked_item(candidate, locked_snapshot):
				continue
			_apply_item(candidate, false)
			break

	_commit("randomize")


func reset_to_default(keep_locks: bool = true) -> void:
	selected = catalog.get_default_state()
	if not keep_locks:
		for category_id in locks.keys():
			locks[category_id] = false
	_commit("reset")


func undo() -> bool:
	var previous: Dictionary = history.undo()
	if previous.is_empty():
		return false
	_apply_snapshot(previous)
	changed.emit("undo")
	_emit_history_changed()
	return true


func redo() -> bool:
	var next: Dictionary = history.redo()
	if next.is_empty():
		return false
	_apply_snapshot(next)
	changed.emit("redo")
	_emit_history_changed()
	return true


func can_undo() -> bool:
	return history != null and history.can_undo()


func can_redo() -> bool:
	return history != null and history.can_redo()


func snapshot() -> Dictionary:
	return {
		"selected": selected.duplicate(true),
		"locks": locks.duplicate(true)
	}


func export_save_data() -> Dictionary:
	return {
		"version": 1,
		"selected": selected.duplicate(true),
		"locks": locks.duplicate(true)
	}


func get_selected_item(category_id: String) -> Dictionary:
	return catalog.get_item(str(selected.get(category_id, "")))


func _apply_item(item: Dictionary, _record_individually: bool) -> void:
	var category_id := str(item.get("category", ""))
	var occupied_slots: Array = item.get("occupies", [])
	var item_tags: Array = item.get("tags", [])
	var item_conflicts: Array = item.get("conflicts_with_tags", [])

	for other_category_id in selected.keys():
		if other_category_id == category_id:
			continue
		var other_item: Dictionary = catalog.get_item(str(selected[other_category_id]))
		if other_item.is_empty():
			continue

		var slot_conflict := _intersects(occupied_slots, other_item.get("occupies", []))
		var tag_conflict := (
			_intersects(item_conflicts, other_item.get("tags", []))
			or _intersects(other_item.get("conflicts_with_tags", []), item_tags)
		)
		if slot_conflict or tag_conflict:
			selected[other_category_id] = catalog.get_fallback_item_id(str(other_category_id))

	selected[category_id] = str(item.get("id", ""))


func _would_clear_locked_item(item: Dictionary, locked_snapshot: Dictionary) -> bool:
	var category_id := str(item.get("category", ""))
	for locked_category_id in locks.keys():
		if not bool(locks[locked_category_id]) or locked_category_id == category_id:
			continue
		var locked_item_id := str(locked_snapshot.get(locked_category_id, ""))
		var locked_item: Dictionary = catalog.get_item(locked_item_id)
		if locked_item.is_empty():
			continue
		if _intersects(item.get("occupies", []), locked_item.get("occupies", [])):
			return true
		if _intersects(item.get("conflicts_with_tags", []), locked_item.get("tags", [])):
			return true
		if _intersects(locked_item.get("conflicts_with_tags", []), item.get("tags", [])):
			return true
	return false


func _commit(reason: String) -> void:
	history.record(snapshot())
	changed.emit(reason)
	_emit_history_changed()


func _apply_snapshot(value: Dictionary) -> void:
	selected = catalog.sanitize_selection(_dictionary(value.get("selected", {})))
	var restored_locks := _dictionary(value.get("locks", {}))
	for category_id in locks.keys():
		locks[category_id] = bool(restored_locks.get(category_id, false))


func _emit_history_changed() -> void:
	history_changed.emit(can_undo(), can_redo())


func _intersects(left: Variant, right: Variant) -> bool:
	if typeof(left) != TYPE_ARRAY or typeof(right) != TYPE_ARRAY:
		return false
	for value in left:
		if right.has(value):
			return true
	return false


func _dictionary(value: Variant) -> Dictionary:
	return value.duplicate(true) if typeof(value) == TYPE_DICTIONARY else {}
