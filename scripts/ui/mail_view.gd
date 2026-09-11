class_name MailView
extends Control

signal mission_opened
signal findon_requested

@onready var inbox_button: Button = %InboxButton
@onready var empty_message: Label = %EmptyMessage
@onready var mail_body: MarginContainer = %MailBody
@onready var subject_label: Label = %SubjectLabel
@onready var sender_label: Label = %SenderLabel
@onready var received_label: Label = %ReceivedLabel
@onready var identity_label: Label = %IdentityLabel
@onready var body_text: RichTextLabel = %BodyText
@onready var findon_button: Button = %FindOnButton

var _mail: Dictionary = {}
var _is_read: bool = false


func _ready() -> void:
	inbox_button.pressed.connect(_open_mail)
	findon_button.pressed.connect(func() -> void: findon_requested.emit())


func configure(mail: Dictionary, identity: Dictionary, mission_is_read: bool) -> void:
	_mail = mail.duplicate(true)
	subject_label.text = str(_mail.get("subject", ""))
	sender_label.text = "보낸 사람  %s" % _mail.get("sender", "")
	received_label.text = "받은 시각  %s" % _mail.get("received_at", "")
	identity_label.text = "받는 계정  %s" % identity.get("email", "")
	findon_button.text = str(_mail.get("link_label", "FindOn 열기"))

	var paragraphs := PackedStringArray()
	for paragraph in _mail.get("body", []):
		paragraphs.append(str(paragraph))
	body_text.text = "\n\n".join(paragraphs)
	set_read_state(mission_is_read)


func set_read_state(value: bool) -> void:
	_is_read = value
	inbox_button.text = "%s%s" % ["" if _is_read else "●  ", _mail.get("subject", "새 메일")]
	mail_body.visible = _is_read
	empty_message.visible = not _is_read


func _open_mail() -> void:
	set_read_state(true)
	mission_opened.emit()
