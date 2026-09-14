class_name ContentCatalog
extends RefCounted

var error_message: String = ""
var _chapter: Dictionary = {}
var _sites_by_id: Dictionary = {}
var _pages_by_id: Dictionary = {}
var _pages_by_route: Dictionary = {}
var _images_by_id: Dictionary = {}


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
	if not _validate_data():
		return false
	_build_indexes()
	return true


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


func get_page(page_id: String) -> Dictionary:
	return _pages_by_id.get(page_id, {}).duplicate(true)


func get_page_by_route(route: String) -> Dictionary:
	return _pages_by_route.get(route, {}).duplicate(true)


func get_site(site_id: String) -> Dictionary:
	return _sites_by_id.get(site_id, {}).duplicate(true)


func get_image(image_id: String) -> Dictionary:
	return _images_by_id.get(image_id, {}).duplicate(true)


func get_search_candidates() -> Array:
	return _chapter.get("search_candidates", []).duplicate(true)


func search_pages(query: String) -> Array:
	var tokens := _tokenize(query)
	if tokens.is_empty():
		return []

	var matches: Array = []
	for page_value in _pages_by_id.values():
		var page: Dictionary = page_value
		var fields := _search_fields(page)
		var matches_all := true
		for token in tokens:
			if not fields["all"].contains(token):
				matches_all = false
				break
		if not matches_all:
			continue

		var score := 0
		for token in tokens:
			if fields["title"].contains(token):
				score += 5
			if fields["author"].contains(token):
				score += 4
			if fields["filename"].contains(token):
				score += 4
			if fields["terms"].contains(token):
				score += 2
			if fields["aliases"].contains(token):
				score += 1

		var result := page.duplicate(true)
		result["_score"] = score
		matches.append(result)

	matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["_score"] == b["_score"]:
			return str(a["page_id"]) < str(b["page_id"])
		return int(a["_score"]) > int(b["_score"])
	)
	for result in matches:
		result.erase("_score")
	return matches


func _validate_data() -> bool:
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

	for section_name in ["sites", "pages", "images", "search_candidates"]:
		if typeof(_chapter.get(section_name)) != TYPE_ARRAY:
			return _fail("필수 배열이 없거나 형식이 잘못되었습니다: %s" % section_name)

	var site_ids: Dictionary = {}
	for site_value in _chapter["sites"]:
		if typeof(site_value) != TYPE_DICTIONARY:
			return _fail("sites 항목은 객체여야 합니다.")
		var site: Dictionary = site_value
		for key in ["site_id", "label", "header_color"]:
			if not _require_non_empty_string(site, key, "sites"):
				return false
		var site_id := str(site["site_id"])
		if site_ids.has(site_id):
			return _fail("중복 site_id: %s" % site_id)
		site_ids[site_id] = true

	var image_ids: Dictionary = {}
	for image_value in _chapter["images"]:
		if typeof(image_value) != TYPE_DICTIONARY:
			return _fail("images 항목은 객체여야 합니다.")
		var image: Dictionary = image_value
		for key in ["image_id", "texture_path", "filename", "uploader", "source_label"]:
			if not _require_non_empty_string(image, key, "images"):
				return false
		var image_id := str(image["image_id"])
		if image_ids.has(image_id):
			return _fail("중복 image_id: %s" % image_id)
		if not FileAccess.file_exists(str(image["texture_path"])):
			return _fail("이미지 에셋을 찾을 수 없습니다(%s): %s" % [image_id, image["texture_path"]])
		image_ids[image_id] = true

	var page_ids: Dictionary = {}
	var routes: Dictionary = {}
	var block_ids: Dictionary = {}
	var supported_block_types := ["text", "link", "image", "redactable_text", "comment"]
	for page_value in _chapter["pages"]:
		if typeof(page_value) != TYPE_DICTIONARY:
			return _fail("pages 항목은 객체여야 합니다.")
		var page: Dictionary = page_value
		for key in ["page_id", "site_id", "route", "title", "author", "search_summary"]:
			if not _require_non_empty_string(page, key, "pages"):
				return false
		var page_id := str(page["page_id"])
		var route := str(page["route"])
		if page_ids.has(page_id):
			return _fail("중복 page_id: %s" % page_id)
		if routes.has(route):
			return _fail("중복 page route: %s" % route)
		if not site_ids.has(str(page["site_id"])):
			return _fail("페이지가 없는 site_id를 참조합니다(%s): %s" % [page_id, page["site_id"]])
		for list_key in ["search_terms", "search_aliases", "blocks"]:
			if typeof(page.get(list_key)) != TYPE_ARRAY:
				return _fail("pages.%s.%s는 배열이어야 합니다." % [page_id, list_key])
		if page.has("search_image_id") and not image_ids.has(str(page["search_image_id"])):
			return _fail("페이지 검색 이미지 참조가 없습니다(%s): %s" % [page_id, page["search_image_id"]])
		for block_value in page["blocks"]:
			if typeof(block_value) != TYPE_DICTIONARY:
				return _fail("페이지 블록은 객체여야 합니다: %s" % page_id)
			var block: Dictionary = block_value
			for key in ["block_id", "type"]:
				if not _require_non_empty_string(block, key, "pages.%s.blocks" % page_id):
					return false
			var block_id := str(block["block_id"])
			if block_ids.has(block_id):
				return _fail("중복 block_id: %s" % block_id)
			if not supported_block_types.has(str(block["type"])):
				return _fail("지원하지 않는 block type(%s): %s" % [block_id, block["type"]])
			block_ids[block_id] = true
		page_ids[page_id] = true
		routes[route] = true

	for image_value in _chapter["images"]:
		var image: Dictionary = image_value
		if image.has("origin_image_id"):
			var origin_id := str(image["origin_image_id"])
			if origin_id == str(image["image_id"]) or not image_ids.has(origin_id):
				return _fail("잘못된 origin_image_id(%s): %s" % [image["image_id"], origin_id])

	var candidate_ids: Dictionary = {}
	var candidate_texts: Dictionary = {}
	for candidate_value in _chapter["search_candidates"]:
		if typeof(candidate_value) != TYPE_DICTIONARY:
			return _fail("search_candidates 항목은 객체여야 합니다.")
		var candidate: Dictionary = candidate_value
		for key in ["candidate_id", "text", "unlock_type"]:
			if not _require_non_empty_string(candidate, key, "search_candidates"):
				return false
		var candidate_id := str(candidate["candidate_id"])
		var candidate_text := str(candidate["text"])
		if candidate_ids.has(candidate_id):
			return _fail("중복 candidate_id: %s" % candidate_id)
		if candidate_texts.has(candidate_text):
			return _fail("중복 검색 후보 문자열: %s" % candidate_text)
		candidate_ids[candidate_id] = true
		candidate_texts[candidate_text] = true
		match str(candidate["unlock_type"]):
			"mission_read":
				pass
			"visited_page":
				if not _require_non_empty_string(candidate, "unlock_id", "search_candidates.%s" % candidate_id):
					return false
				if not page_ids.has(str(candidate["unlock_id"])):
					return _fail("검색 후보가 없는 page_id를 참조합니다(%s): %s" % [candidate_id, candidate["unlock_id"]])
			"observed_content":
				if not _require_non_empty_string(candidate, "unlock_id", "search_candidates.%s" % candidate_id):
					return false
				var unlock_id := str(candidate["unlock_id"])
				if not block_ids.has(unlock_id) and not image_ids.has(unlock_id):
					return _fail("검색 후보가 없는 content ID를 참조합니다(%s): %s" % [candidate_id, unlock_id])
			_:
				return _fail("지원하지 않는 검색 후보 unlock_type(%s): %s" % [candidate_id, candidate["unlock_type"]])

	for page_value in _chapter["pages"]:
		var page: Dictionary = page_value
		for block_value in page["blocks"]:
			var block: Dictionary = block_value
			match str(block["type"]):
				"text":
					if not _require_non_empty_string(block, "text", "blocks.%s" % block["block_id"]):
						return false
				"link":
					for key in ["label", "route"]:
						if not _require_non_empty_string(block, key, "blocks.%s" % block["block_id"]):
							return false
					if not routes.has(str(block["route"])):
						return _fail("링크가 없는 route를 참조합니다(%s): %s" % [block["block_id"], block["route"]])
				"image":
					if not _require_non_empty_string(block, "image_id", "blocks.%s" % block["block_id"]):
						return false
					if not image_ids.has(str(block["image_id"])):
						return _fail("이미지 블록 참조가 없습니다(%s): %s" % [block["block_id"], block["image_id"]])
					if block.has("source_route") and not routes.has(str(block["source_route"])):
						return _fail("이미지 출처 route가 없습니다(%s): %s" % [block["block_id"], block["source_route"]])
				"redactable_text":
					for key in ["prefix", "value", "suffix", "redacted_value"]:
						if not _require_non_empty_string(block, key, "blocks.%s" % block["block_id"]):
							return false
				"comment":
					for key in ["author", "text"]:
						if not _require_non_empty_string(block, key, "blocks.%s" % block["block_id"]):
							return false

	return true


func _build_indexes() -> void:
	_sites_by_id.clear()
	_pages_by_id.clear()
	_pages_by_route.clear()
	_images_by_id.clear()
	for site in _chapter["sites"]:
		_sites_by_id[str(site["site_id"])] = site
	for image in _chapter["images"]:
		_images_by_id[str(image["image_id"])] = image
	for page in _chapter["pages"]:
		_pages_by_id[str(page["page_id"])] = page
		_pages_by_route[str(page["route"])] = page


func _search_fields(page: Dictionary) -> Dictionary:
	var filename := ""
	if page.has("search_image_id"):
		filename = str(_images_by_id.get(str(page["search_image_id"]), {}).get("filename", ""))
	var terms := " ".join(PackedStringArray(page.get("search_terms", [])))
	var aliases := " ".join(PackedStringArray(page.get("search_aliases", [])))
	var fields := {
		"title": _normalize(str(page.get("title", ""))),
		"author": _normalize(str(page.get("author", ""))),
		"filename": _normalize(filename),
		"terms": _normalize(terms),
		"aliases": _normalize(aliases),
	}
	fields["all"] = " ".join(PackedStringArray([fields["title"], fields["author"], fields["filename"], fields["terms"], fields["aliases"]]))
	return fields


func _tokenize(value: String) -> PackedStringArray:
	var normalized := _normalize(value)
	if normalized.is_empty():
		return PackedStringArray()
	return normalized.split(" ", false)


func _normalize(value: String) -> String:
	var normalized := value.strip_edges().to_lower()
	for separator in ["\t", "\n", "\r", ",", ".", "/", "_", "-", "?", "!", "(", ")", "[", "]"]:
		normalized = normalized.replace(separator, " ")
	while normalized.contains("  "):
		normalized = normalized.replace("  ", " ")
	return normalized.strip_edges()


func _require_non_empty_string(data: Dictionary, key: String, context: String) -> bool:
	if typeof(data.get(key)) != TYPE_STRING or str(data[key]).strip_edges().is_empty():
		return _fail("%s.%s는 비어 있지 않은 문자열이어야 합니다." % [context, key])
	return true


func _fail(message: String) -> bool:
	error_message = message
	return false
