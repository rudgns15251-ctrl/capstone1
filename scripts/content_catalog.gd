class_name ContentCatalog
extends RefCounted

var error_message: String = ""
var _chapter: Dictionary = {}


func load_chapter(path: String) -> bool:
	error_message = ""
	_chapter.clear()

	if not FileAccess.file_exists(path):
		return _fail("콘텐츠 파일을 찾을 수 없습니다: %s" % path)

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("콘텐츠 파일을 열 수 없습니다: %s" % path)

	var parser := JSON.new()
	var parse_result := parser.parse(file.get_as_text())
	if parse_result != OK:
		return _fail("JSON 파싱 오류(%d행): %s" % [parser.get_error_line(), parser.get_error_message()])

	if typeof(parser.data) != TYPE_DICTIONARY:
		return _fail("chapter_01.json의 최상위 값은 객체여야 합니다.")

	_chapter = parser.data
	return _validate_m1_data()


func get_work_identity() -> Dictionary:
	return _chapter.get("work_identity", {}).duplicate(true)


func get_mission() -> Dictionary:
	return _chapter.get("mission", {}).duplicate(true)


func get_initial_mail() -> Dictionary:
	var mission: Dictionary = _chapter.get("mission", {})
	var initial_mail_id := str(mission.get("initial_mail_id", ""))
	var mails: Array = _chapter.get("mails", [])
	for mail in mails:
		if typeof(mail) == TYPE_DICTIONARY and str(mail.get("mail_id", "")) == initial_mail_id:
			return mail.duplicate(true)
	return {}


func _validate_m1_data() -> bool:
	for section_name in ["work_identity", "mission"]:
		if typeof(_chapter.get(section_name)) != TYPE_DICTIONARY:
			return _fail("필수 객체가 없거나 형식이 잘못되었습니다: %s" % section_name)

	if typeof(_chapter.get("mails")) != TYPE_ARRAY:
		return _fail("필수 배열이 없거나 형식이 잘못되었습니다: mails")

	var identity: Dictionary = _chapter["work_identity"]
	for key in ["email", "contract_date", "work_id", "username", "access_level"]:
		if not _require_non_empty_string(identity, key, "work_identity"):
			return false

	var mission: Dictionary = _chapter["mission"]
	for key in ["mission_id", "title", "summary", "initial_mail_id", "findon_route"]:
		if not _require_non_empty_string(mission, key, "mission"):
			return false

	if typeof(mission.get("scope")) != TYPE_ARRAY or mission["scope"].is_empty():
		return _fail("mission.scope는 비어 있지 않은 배열이어야 합니다.")
	for scope_item in mission["scope"]:
		if typeof(scope_item) != TYPE_STRING or scope_item.strip_edges().is_empty():
			return _fail("mission.scope에는 비어 있지 않은 문자열만 사용할 수 있습니다.")

	var initial_mail := get_initial_mail()
	if initial_mail.is_empty():
		return _fail("mission.initial_mail_id가 유효한 메일을 가리키지 않습니다.")
	for key in ["sender", "subject", "received_at", "link_label", "link_route"]:
		if not _require_non_empty_string(initial_mail, key, "mails.%s" % mission["initial_mail_id"]):
			return false
	if typeof(initial_mail.get("body")) != TYPE_ARRAY or initial_mail["body"].is_empty():
		return _fail("초기 메일 body는 비어 있지 않은 배열이어야 합니다.")
	if initial_mail["link_route"] != mission["findon_route"]:
		return _fail("초기 메일 링크와 mission.findon_route가 일치하지 않습니다.")

	return true


func _require_non_empty_string(data: Dictionary, key: String, context: String) -> bool:
	if typeof(data.get(key)) != TYPE_STRING or str(data[key]).strip_edges().is_empty():
		return _fail("%s.%s는 비어 있지 않은 문자열이어야 합니다." % [context, key])
	return true


func _fail(message: String) -> bool:
	error_message = message
	return false
