extends RefCounted

const SAVE_PATH := "user://outfit_state.json"

var save_path: String = SAVE_PATH


func _init(path: String = SAVE_PATH) -> void:
	save_path = path


func load_data() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}
	var text := FileAccess.get_file_as_string(save_path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Không đọc được save data; game sẽ dùng trạng thái mặc định.")
		return {}
	return parsed


func save_data(data: Dictionary) -> Error:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "  ", false))
	file.close()
	return OK


func clear_data() -> Error:
	if not FileAccess.file_exists(save_path):
		return OK
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
