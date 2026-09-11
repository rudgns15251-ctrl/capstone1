class_name SessionState
extends RefCounted

signal mission_read_changed(is_read: bool)

var mission_id: String
var mission_read: bool = false


func _init(initial_mission_id: String) -> void:
	mission_id = initial_mission_id


func mark_mission_read() -> void:
	if mission_read:
		return
	mission_read = true
	mission_read_changed.emit(mission_read)
