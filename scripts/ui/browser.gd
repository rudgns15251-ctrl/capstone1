class_name BrowserView
extends Control

signal route_changed(route: String)

@onready var address_field: LineEdit = %AddressField
@onready var findon_panel: MarginContainer = %FindOnPanel
@onready var work_order_view: WorkOrderView = %WorkOrderView
@onready var findon_button: Button = %FindOnButton
@onready var slink_button: Button = %SLinkButton

var current_route: String = ""
var _findon_route: String = "https://findon.invalid/"


func _ready() -> void:
	findon_button.pressed.connect(open_findon)
	slink_button.pressed.connect(open_work_order)
	work_order_view.findon_requested.connect(open_findon)


func configure(mission: Dictionary, identity: Dictionary) -> void:
	_findon_route = str(mission.get("findon_route", _findon_route))
	work_order_view.configure(mission, identity)
	open_findon()


func open_findon() -> void:
	current_route = _findon_route
	address_field.text = current_route
	findon_panel.visible = true
	work_order_view.visible = false
	route_changed.emit(current_route)


func open_work_order() -> void:
	current_route = "https://s-link.invalid/work-orders/SR-001"
	address_field.text = current_route
	findon_panel.visible = false
	work_order_view.visible = true
	route_changed.emit(current_route)
