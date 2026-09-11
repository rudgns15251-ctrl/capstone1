extends Node

const CHAPTER_PATH := "res://content/chapter_01.json"
const ContentCatalogScript := preload("res://scripts/content_catalog.gd")
const SessionStateScript := preload("res://scripts/session_state.gd")

@onready var postone_button: Button = $Desktop/Surface/MainColumn/AppButtons/PostOneButton
@onready var browser_button: Button = $Desktop/Surface/MainColumn/AppButtons/BrowserButton
@onready var user_label: Label = $Desktop/Surface/MainColumn/TopBar/UserLabel
@onready var system_message: Label = $Desktop/Surface/MainColumn/SystemMessage
@onready var browser: BrowserView = $Desktop/Surface/MainColumn/AppArea/Browser
@onready var mail_view: MailView = $Desktop/Surface/MainColumn/AppArea/MailView

var catalog: ContentCatalog
var session_state: SessionState


func _ready() -> void:
	catalog = ContentCatalogScript.new()
	if not catalog.load_chapter(CHAPTER_PATH):
		_show_startup_error(catalog.error_message)
		return

	var mission := catalog.get_mission()
	var identity := catalog.get_work_identity()
	var initial_mail := catalog.get_initial_mail()
	session_state = SessionStateScript.new(str(mission.get("mission_id", "")))

	user_label.text = "%s  |  %s" % [identity.get("username", ""), identity.get("access_level", "")]
	mail_view.configure(initial_mail, identity, session_state.mission_read)
	browser.configure(catalog, mission, identity)

	postone_button.pressed.connect(_show_mail)
	browser_button.pressed.connect(_show_browser)
	mail_view.mission_opened.connect(_on_mission_opened)
	mail_view.findon_requested.connect(_on_findon_requested)
	browser.page_visited.connect(session_state.mark_page_visited)
	browser.content_observed.connect(session_state.mark_content_observed)
	session_state.mission_read_changed.connect(mail_view.set_read_state)

	_show_mail()


func _show_mail() -> void:
	if session_state != null:
		mail_view.set_read_state(session_state.mission_read)
	mail_view.visible = true
	browser.visible = false
	system_message.text = "POSTONE  |  사내 업무 메일"


func _show_browser() -> void:
	mail_view.visible = false
	browser.visible = true
	system_message.text = "BROWSER  |  관리되는 업무 환경"


func _on_mission_opened() -> void:
	session_state.mark_mission_read()


func _on_findon_requested() -> void:
	browser.open_findon()
	_show_browser()


func _show_startup_error(message: String) -> void:
	push_error(message)
	system_message.text = "콘텐츠 로딩 오류: %s" % message
	postone_button.disabled = true
	browser_button.disabled = true
