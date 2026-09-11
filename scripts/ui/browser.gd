class_name BrowserView
extends Control

signal route_changed(route: String)
signal page_visited(page_id: String)
signal content_observed(content_id: String)

@onready var back_button: Button = %BackButton
@onready var forward_button: Button = %ForwardButton
@onready var address_field: LineEdit = %AddressField
@onready var go_button: Button = %GoButton
@onready var copy_button: Button = %CopyButton
@onready var findon_panel: MarginContainer = %FindOnPanel
@onready var work_order_view: WorkOrderView = %WorkOrderView
@onready var web_page_view: WebPageView = %WebPageView
@onready var unknown_panel: MarginContainer = %UnknownPanel
@onready var unknown_route: Label = %UnknownRoute
@onready var findon_button: Button = %FindOnButton
@onready var slink_button: Button = %SLinkButton
@onready var unknown_findon_button: Button = %UnknownFindOnButton
@onready var search_field: LineEdit = %SearchField
@onready var search_button: Button = %SearchButton
@onready var search_status: Label = %SearchStatus
@onready var search_scroll: ScrollContainer = %SearchScroll
@onready var search_results: VBoxContainer = %SearchResults

var current_route: String = ""
var _findon_route: String = "https://findon.invalid/"
var _work_order_route: String = "https://s-link.invalid/work-orders/SR-001"
var _catalog: ContentCatalog
var _history: Array = []
var _history_index: int = -1


func _ready() -> void:
	back_button.pressed.connect(go_back)
	forward_button.pressed.connect(go_forward)
	go_button.pressed.connect(func() -> void: navigate_to_route(address_field.text))
	address_field.text_submitted.connect(func(value: String) -> void: navigate_to_route(value))
	copy_button.pressed.connect(_copy_current_address)
	findon_button.pressed.connect(open_findon)
	slink_button.pressed.connect(open_work_order)
	work_order_view.findon_requested.connect(open_findon)
	unknown_findon_button.pressed.connect(open_findon)
	search_button.pressed.connect(_submit_search)
	search_field.text_submitted.connect(func(_value: String) -> void: _submit_search())
	web_page_view.link_requested.connect(navigate_to_route)
	web_page_view.content_observed.connect(func(content_id: String) -> void: content_observed.emit(content_id))


func configure(catalog: ContentCatalog, mission: Dictionary, identity: Dictionary) -> void:
	_catalog = catalog
	_findon_route = str(mission.get("findon_route", _findon_route))
	_work_order_route = "https://s-link.invalid/work-orders/%s" % mission.get("mission_id", "SR-001")
	work_order_view.configure(mission, identity)
	web_page_view.configure(catalog)
	_history.clear()
	_history_index = -1
	_push_entry({"kind": "findon", "route": _findon_route, "query": "", "scroll": 0})


func open_findon() -> void:
	_push_entry({"kind": "findon", "route": _findon_route, "query": "", "scroll": 0})


func open_work_order() -> void:
	_push_entry({"kind": "work_order", "route": _work_order_route, "scroll": 0})


func navigate_to_route(route_value: String) -> void:
	var route := route_value.strip_edges()
	if route == _findon_route:
		open_findon()
		return
	if route == _work_order_route:
		open_work_order()
		return
	var page := _catalog.get_page_by_route(route)
	if not page.is_empty():
		_push_entry({"kind": "page", "route": route, "page_id": page["page_id"], "scroll": 0})
		return
	_push_entry({"kind": "unknown", "route": route, "scroll": 0})


func submit_search(query: String) -> void:
	search_field.text = query
	_submit_search()


func go_back() -> void:
	if _history_index <= 0:
		return
	_capture_current_scroll()
	_history_index -= 1
	_render_current_entry()


func go_forward() -> void:
	if _history_index >= _history.size() - 1:
		return
	_capture_current_scroll()
	_history_index += 1
	_render_current_entry()


func get_history_size() -> int:
	return _history.size()


func _submit_search() -> void:
	var query := search_field.text.strip_edges()
	var encoded_query := query.uri_encode()
	var display_route := _findon_route if query.is_empty() else "%s?q=%s" % [_findon_route, encoded_query]
	_push_entry({"kind": "findon", "route": display_route, "query": query, "scroll": 0})


func _push_entry(entry: Dictionary) -> void:
	_capture_current_scroll()
	if _history_index < _history.size() - 1:
		_history = _history.slice(0, _history_index + 1)
	_history.append(entry)
	_history_index = _history.size() - 1
	_render_current_entry()


func _render_current_entry() -> void:
	var entry: Dictionary = _history[_history_index]
	current_route = str(entry["route"])
	address_field.text = current_route
	_hide_content_views()

	match str(entry["kind"]):
		"findon":
			findon_panel.visible = true
			search_field.text = str(entry.get("query", ""))
			_render_search_results(search_field.text)
			call_deferred("_restore_findon_scroll", int(entry.get("scroll", 0)))
		"page":
			var page := _catalog.get_page(str(entry["page_id"]))
			web_page_view.visible = true
			web_page_view.show_page(page)
			page_visited.emit(str(entry["page_id"]))
			call_deferred("_restore_page_scroll", int(entry.get("scroll", 0)))
		"work_order":
			work_order_view.visible = true
		"unknown":
			unknown_panel.visible = true
			unknown_route.text = current_route if not current_route.is_empty() else "(빈 주소)"

	back_button.disabled = _history_index <= 0
	forward_button.disabled = _history_index >= _history.size() - 1
	route_changed.emit(current_route)


func _render_search_results(query: String) -> void:
	for child in search_results.get_children():
		child.free()

	if query.strip_edges().is_empty():
		search_status.text = "화면에서 확인한 단어를 조합해 검색하세요. 빈 검색은 결과를 표시하지 않습니다."
		return

	var results := _catalog.search_pages(query)
	if results.is_empty():
		search_status.text = "‘%s’에 대한 결과가 없습니다. 검색어를 바꾸거나 이전 페이지로 돌아가세요." % query
		return

	search_status.text = "‘%s’ 검색 결과 %d개" % [query, results.size()]
	for page_value in results:
		_add_search_result(page_value)


func _add_search_result(page: Dictionary) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 124)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	if page.has("search_image_id"):
		var image := _catalog.get_image(str(page["search_image_id"]))
		var thumbnail := TextureRect.new()
		thumbnail.custom_minimum_size = Vector2(132, 84)
		thumbnail.texture = load(str(image.get("texture_path", ""))) as Texture2D
		thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(thumbnail)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 4)
	row.add_child(details)
	var site := _catalog.get_site(str(page.get("site_id", "")))
	var site_label := _make_result_label(str(site.get("label", "")))
	site_label.add_theme_color_override("font_color", Color.html(str(site.get("header_color", "#79b8ff"))))
	site_label.add_theme_font_size_override("font_size", 14)
	details.add_child(site_label)
	var title_button := Button.new()
	title_button.text = str(page.get("title", ""))
	title_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_button.pressed.connect(navigate_to_route.bind(str(page.get("route", ""))))
	details.add_child(title_button)
	details.add_child(_make_result_label(str(page.get("search_summary", ""))))
	var route_label := _make_result_label(str(page.get("route", "")))
	route_label.add_theme_color_override("font_color", Color("7fbf9a"))
	route_label.add_theme_font_size_override("font_size", 14)
	details.add_child(route_label)
	search_results.add_child(card)


func _make_result_label(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _capture_current_scroll() -> void:
	if _history_index < 0 or _history_index >= _history.size():
		return
	var entry: Dictionary = _history[_history_index]
	match str(entry.get("kind", "")):
		"findon":
			entry["scroll"] = search_scroll.scroll_vertical
		"page":
			entry["scroll"] = web_page_view.get_scroll_position()
	_history[_history_index] = entry


func _restore_findon_scroll(value: int) -> void:
	search_scroll.scroll_vertical = value


func _restore_page_scroll(value: int) -> void:
	web_page_view.set_scroll_position(value)


func _hide_content_views() -> void:
	findon_panel.visible = false
	web_page_view.visible = false
	work_order_view.visible = false
	unknown_panel.visible = false


func _copy_current_address() -> void:
	DisplayServer.clipboard_set(current_route)
