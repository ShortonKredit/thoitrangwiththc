extends RefCounted

var max_entries: int = 40
var _entries: Array = []
var _cursor: int = -1


func _init(limit: int = 40) -> void:
	max_entries = maxi(limit, 2)


func reset(snapshot: Dictionary) -> void:
	_entries = [snapshot.duplicate(true)]
	_cursor = 0


func record(snapshot: Dictionary) -> bool:
	var clean_snapshot := snapshot.duplicate(true)
	if _cursor >= 0 and _entries[_cursor] == clean_snapshot:
		return false

	if _cursor < _entries.size() - 1:
		_entries = _entries.slice(0, _cursor + 1)

	_entries.append(clean_snapshot)
	_cursor = _entries.size() - 1

	while _entries.size() > max_entries:
		_entries.pop_front()
		_cursor -= 1

	return true


func can_undo() -> bool:
	return _cursor > 0


func can_redo() -> bool:
	return _cursor >= 0 and _cursor < _entries.size() - 1


func undo() -> Dictionary:
	if not can_undo():
		return {}
	_cursor -= 1
	return _entries[_cursor].duplicate(true)


func redo() -> Dictionary:
	if not can_redo():
		return {}
	_cursor += 1
	return _entries[_cursor].duplicate(true)


func size() -> int:
	return _entries.size()
