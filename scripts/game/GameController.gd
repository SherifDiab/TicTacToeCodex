extends Control

const TicTacToeAI = preload("res://scripts/ai/TicTacToeAI.gd")

enum State {
	PLAYING,
	GAME_OVER
}

@onready var status_label: Label = $MainLayout/StatusLabel
@onready var grid: GridContainer = $MainLayout/GridContainer
@onready var restart_button: Button = $MainLayout/BottomBar/RestartButton
@onready var back_button: Button = $MainLayout/BottomBar/BackButton
@onready var game_over_panel: GameOverPanel = $GameOverPanel

var _board := Board.new()
var _ai := TicTacToeAI.new()
var _state := State.PLAYING
var _player_symbol := "X"
var _ai_symbol := "O"
var _current_player := "X"
var _reward_used := false

func _ready() -> void:
	randomize()
	Ads.hide_banner()
	_player_symbol = GameSettings.player_symbol
	_ai_symbol = "O" if _player_symbol == "X" else "X"
	_restart_match()
	_connect_grid_buttons()
	restart_button.pressed.connect(_on_restart_pressed)
	back_button.pressed.connect(_on_back_pressed)
	game_over_panel.play_again.connect(_on_restart_pressed)
	game_over_panel.main_menu.connect(_on_back_pressed)
	game_over_panel.rewarded_requested.connect(_on_rewarded_requested)

func _connect_grid_buttons() -> void:
	for child in grid.get_children():
		var button := child as Button
		if button:
			button.add_theme_font_size_override("font_size", 64)
			button.pressed.connect(func(): _on_grid_child_pressed(button))

func _restart_match() -> void:
	_board.reset()
	_reward_used = false
	_state = State.PLAYING
	game_over_panel.hide()
	_update_cells()
	_clear_highlights()
	_current_player = "X"
	_update_status()
	if _player_symbol == "O":
		_current_player = _ai_symbol
		await _run_ai_turn()

func _on_restart_pressed() -> void:
	Ads.hide_banner()
	_restart_match()

func _on_back_pressed() -> void:
	Ads.hide_banner()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_cell_pressed(index: int) -> void:
	if _state != State.PLAYING:
		return
	if _current_player != _player_symbol:
		return
	if _board.apply_move(index, _player_symbol):
		_update_cells()
		if _check_game_over():
			return
		_current_player = _ai_symbol
		await _run_ai_turn()

func _run_ai_turn() -> void:
	if _state != State.PLAYING:
		return
	status_label.text = "Engine thinking..."
	await get_tree().create_timer(0.35).timeout
	var move := _ai.choose_move(_board, _ai_symbol, GameSettings.difficulty)
	if move >= 0:
		_board.apply_move(move, _ai_symbol)
		_update_cells()
	if _check_game_over():
		return
	_current_player = _player_symbol
	_update_status()

func _update_cells() -> void:
	for i in range(grid.get_child_count()):
		var button := grid.get_child(i) as Button
		button.text = _board.get_cell(i)

func _clear_highlights() -> void:
	for i in range(grid.get_child_count()):
		var button := grid.get_child(i) as Button
		button.modulate = Color.WHITE

func _highlight_line(line: Array) -> void:
	for index in line:
		var button := grid.get_child(index) as Button
		button.modulate = Color(1.0, 0.9, 0.5)

func _check_game_over() -> bool:
	var result := _board.get_winner()
	if result["winner"] == "":
		_update_status()
		return false
	_state = State.GAME_OVER
	if result["winner"] == "draw":
		status_label.text = "It's a draw!"
		Stats.record_result("draw")
		game_over_panel.set_result("Draw")
	else:
		var winner := result["winner"]
		_highlight_line(result["line"])
		if winner == _player_symbol:
			status_label.text = "You win!"
			Stats.record_result("win")
			game_over_panel.set_result("You Win!")
		else:
			status_label.text = "Engine wins!"
			Stats.record_result("loss")
			game_over_panel.set_result("Engine Wins")
	Ads.show_banner("bottom")
	Ads.load_rewarded()
	game_over_panel.show()
	game_over_panel.set_reward_available(Ads.is_rewarded_ready() and not _reward_used)
	return true

func _update_status() -> void:
	if _current_player == _player_symbol:
		status_label.text = "Your turn (%s)" % _player_symbol
	else:
		status_label.text = "Engine turn (%s)" % _ai_symbol

func _on_rewarded_requested() -> void:
	if _reward_used:
		game_over_panel.set_reward_available(false)
		return
	if not Ads.is_rewarded_ready():
		game_over_panel.set_reward_available(false)
		return
	Ads.show_rewarded(
		func():
			_apply_rewarded_undo(),
		func():
			game_over_panel.show_reward_message("Ad not available")
	)

func _apply_rewarded_undo() -> void:
	_reward_used = true
	var last_move := _board.undo_last_move()
	if last_move.is_empty():
		game_over_panel.show_reward_message("No moves to undo")
		return
	_clear_highlights()
	game_over_panel.hide()
	Ads.hide_banner()
	_state = State.PLAYING
	_current_player = _player_symbol
	_update_cells()
	_update_status()

func _on_grid_child_pressed(button: Button) -> void:
	var index := grid.get_children().find(button)
	if index != -1:
		_on_cell_pressed(index)
