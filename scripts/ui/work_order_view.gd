class_name WorkOrderView
extends Control

signal findon_requested

@onready var mission_id_label: Label = %MissionIdLabel
@onready var mission_title_label: Label = %MissionTitleLabel
@onready var mission_summary_label: Label = %MissionSummaryLabel
@onready var scope_list: RichTextLabel = %ScopeList
@onready var account_list: RichTextLabel = %AccountList
@onready var findon_button: Button = %FindOnButton


func _ready() -> void:
	findon_button.pressed.connect(func() -> void: findon_requested.emit())


func configure(mission: Dictionary, identity: Dictionary) -> void:
	mission_id_label.text = "WORK ORDER  %s" % mission.get("mission_id", "")
	mission_title_label.text = str(mission.get("title", ""))
	mission_summary_label.text = str(mission.get("summary", ""))

	var scope_lines := PackedStringArray()
	for item in mission.get("scope", []):
		scope_lines.append("• %s" % item)
	scope_list.text = "\n".join(scope_lines)

	account_list.text = "업무용 이메일  %s\n계약 날짜       %s\n업무 ID         %s\n현재 사용자     %s\n접근 등급       %s" % [
		identity.get("email", ""),
		identity.get("contract_date", ""),
		identity.get("work_id", ""),
		identity.get("username", ""),
		identity.get("access_level", ""),
	]
