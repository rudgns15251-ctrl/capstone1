class_name WebPageView
extends Control

signal link_requested(route: String)
signal content_observed(content_id: String)

@onready var scroll: ScrollContainer = %PageScroll
@onready var site_header: Label = %SiteHeader
@onready var title_label: Label = %TitleLabel
@onready var meta_label: Label = %MetaLabel
@onready var blocks_container: VBoxContainer = %Blocks

var _catalog: ContentCatalog
var _pending_observations: Array = []
var _observed_on_page: Dictionary = {}


func _ready() -> void:
	scroll.get_v_scroll_bar().value_changed.connect(func(_value: float) -> void: _emit_visible_content())


func configure(catalog: ContentCatalog) -> void:
	_catalog = catalog


func show_page(page: Dictionary) -> void:
	_clear_blocks()
	_pending_observations.clear()
	_observed_on_page.clear()

	var site := _catalog.get_site(str(page.get("site_id", "")))
	site_header.text = str(site.get("label", "Unknown Site"))
	var header_color := Color.html(str(site.get("header_color", "#79b8ff")))
	site_header.add_theme_color_override("font_color", header_color)
	title_label.text = str(page.get("title", "제목 없음"))
	var author := str(page.get("author", ""))
	var display_date := str(page.get("display_date", ""))
	meta_label.text = "작성자  %s%s" % [author, "    |    %s" % display_date if not display_date.is_empty() else ""]

	for block_value in page.get("blocks", []):
		_render_block(block_value)
	call_deferred("_emit_visible_content")


func get_scroll_position() -> int:
	return scroll.scroll_vertical


func set_scroll_position(value: int) -> void:
	scroll.scroll_vertical = value
	call_deferred("_emit_visible_content")


func _render_block(block: Dictionary) -> void:
	match str(block.get("type", "")):
		"text":
			blocks_container.add_child(_make_text_label(str(block.get("text", ""))))
		"redactable_text":
			var label := _make_text_label("%s%s%s" % [block.get("prefix", ""), block.get("value", ""), block.get("suffix", "")])
			label.add_theme_color_override("font_color", Color("ffd6a5"))
			blocks_container.add_child(label)
			_track_observation(label, str(block.get("block_id", "")))
		"link":
			var link := LinkButton.new()
			link.text = "→ %s" % block.get("label", "링크")
			link.pressed.connect(_request_route.bind(str(block.get("route", ""))))
			blocks_container.add_child(link)
		"image":
			_render_image_block(block)
		"comment":
			_render_comment_block(block)


func _render_image_block(block: Dictionary) -> void:
	var image_id := str(block.get("image_id", ""))
	var image := _catalog.get_image(image_id)
	var texture := load(str(image.get("texture_path", ""))) as Texture2D
	var image_box := VBoxContainer.new()
	image_box.add_theme_constant_override("separation", 6)

	var texture_rect := TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(0, 350)
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_box.add_child(texture_rect)

	var caption := _make_text_label("파일  %s    |    업로더  %s    |    %s" % [image.get("filename", ""), image.get("uploader", ""), image.get("source_label", "")])
	caption.add_theme_color_override("font_color", Color("a9bacb"))
	caption.add_theme_font_size_override("font_size", 15)
	image_box.add_child(caption)

	if block.has("source_route"):
		var source_link := LinkButton.new()
		source_link.text = "원본 출처 열기"
		source_link.pressed.connect(_request_route.bind(str(block["source_route"])))
		image_box.add_child(source_link)

	blocks_container.add_child(image_box)
	_track_observation(texture_rect, image_id)


func _render_comment_block(block: Dictionary) -> void:
	var panel := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 9)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)
	var author := _make_text_label(str(block.get("author", "")))
	author.add_theme_color_override("font_color", Color("79b8ff"))
	column.add_child(author)
	column.add_child(_make_text_label(str(block.get("text", ""))))
	if block.has("route"):
		var link := LinkButton.new()
		link.text = "작성자 페이지"
		link.pressed.connect(_request_route.bind(str(block["route"])))
		column.add_child(link)
	blocks_container.add_child(panel)


func _make_text_label(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _track_observation(node: Control, content_id: String) -> void:
	_pending_observations.append({"node": node, "content_id": content_id})


func _emit_visible_content() -> void:
	var visible_rect := Rect2(scroll.global_position, scroll.size)
	for item in _pending_observations:
		var node: Control = item["node"]
		var content_id := str(item["content_id"])
		if _observed_on_page.has(content_id) or not is_instance_valid(node):
			continue
		if visible_rect.intersects(Rect2(node.global_position, node.size)):
			_observed_on_page[content_id] = true
			content_observed.emit(content_id)


func _request_route(route: String) -> void:
	link_requested.emit(route)


func _clear_blocks() -> void:
	for child in blocks_container.get_children():
		child.free()
