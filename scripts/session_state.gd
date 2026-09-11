class_name SessionState
extends RefCounted

signal mission_read_changed(is_read: bool)
signal page_visited(page_id: String)
signal content_observed(content_id: String)

var mission_id: String
var mission_read: bool = false
var visited_page_ids: Dictionary = {}
var observed_content_ids: Dictionary = {}


func _init(initial_mission_id: String) -> void:
	mission_id = initial_mission_id


func mark_mission_read() -> void:
	if mission_read:
		return
	mission_read = true
	mission_read_changed.emit(mission_read)


func mark_page_visited(page_id: String) -> void:
	if page_id.is_empty() or visited_page_ids.has(page_id):
		return
	visited_page_ids[page_id] = true
	page_visited.emit(page_id)


func mark_content_observed(content_id: String) -> void:
	if content_id.is_empty() or observed_content_ids.has(content_id):
		return
	observed_content_ids[content_id] = true
	content_observed.emit(content_id)


func has_visited(page_id: String) -> bool:
	return visited_page_ids.has(page_id)


func has_observed(content_id: String) -> bool:
	return observed_content_ids.has(content_id)
