class_name GameOverPanel
extends Control

signal play_again
signal main_menu
signal rewarded_requested

@onready var result_label: Label = $PanelContainer/Content/ResultLabel
@onready var ad_status_label: Label = $PanelContainer/Content/AdStatusLabel
@onready var rewarded_button: Button = $PanelContainer/Content/RewardedButton

func _ready() -> void:
	rewarded_button.pressed.connect(_on_rewarded_pressed)
	$PanelContainer/Content/PlayAgainButton.pressed.connect(func():
		play_again.emit()
	)
	$PanelContainer/Content/MainMenuButton.pressed.connect(func():
		main_menu.emit()
	)

func set_result(text: String) -> void:
	result_label.text = text
	ad_status_label.text = ""

func set_reward_available(available: bool) -> void:
	rewarded_button.disabled = not available
	if not available:
		ad_status_label.text = "Ad not available"
	else:
		ad_status_label.text = ""

func show_reward_message(message: String) -> void:
	ad_status_label.text = message

func _on_rewarded_pressed() -> void:
	rewarded_requested.emit()
