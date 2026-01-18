extends Control

@onready var difficulty_option: OptionButton = $MainLayout/OptionsPanel/OptionsContainer/DifficultyRow/DifficultyOption
@onready var symbol_option: OptionButton = $MainLayout/OptionsPanel/OptionsContainer/SymbolRow/SymbolOption
@onready var play_button: Button = $MainLayout/ButtonsContainer/PlayButton
@onready var stats_label: Label = $MainLayout/StatsPanel/StatsContainer/StatsLabel
@onready var reset_button: Button = $MainLayout/StatsPanel/StatsContainer/ResetStatsButton
@onready var confirm_reset: ConfirmationDialog = $ConfirmReset

func _ready() -> void:
	randomize()
	_setup_options()
	_refresh_stats()
	play_button.pressed.connect(_on_play_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	confirm_reset.confirmed.connect(_on_reset_confirmed)
	Ads.request_consent_if_required(func():
		Ads.show_banner("bottom")
	)
	Ads.load_rewarded()

func _setup_options() -> void:
	difficulty_option.clear()
	difficulty_option.add_item("Easy", GameSettings.Difficulty.EASY)
	difficulty_option.add_item("Medium", GameSettings.Difficulty.MEDIUM)
	difficulty_option.add_item("Hard", GameSettings.Difficulty.HARD)
	difficulty_option.select(GameSettings.difficulty)

	symbol_option.clear()
	symbol_option.add_item("Play as X", 0)
	symbol_option.add_item("Play as O", 1)
	symbol_option.select(0 if GameSettings.player_symbol == "X" else 1)

func _refresh_stats() -> void:
	stats_label.text = "Wins: %d\nLosses: %d\nDraws: %d" % [Stats.wins, Stats.losses, Stats.draws]

func _on_play_pressed() -> void:
	GameSettings.difficulty = difficulty_option.get_selected_id()
	GameSettings.player_symbol = "X" if symbol_option.get_selected_id() == 0 else "O"
	Ads.hide_banner()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_reset_pressed() -> void:
	confirm_reset.popup_centered()

func _on_reset_confirmed() -> void:
	Stats.reset_stats()
	_refresh_stats()
