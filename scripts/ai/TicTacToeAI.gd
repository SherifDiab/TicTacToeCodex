class_name TicTacToeAI
extends RefCounted

const GameSettings = preload("res://scripts/game/GameSettings.gd")

func choose_move(board: Board, ai_player: String, difficulty: int) -> int:
	match difficulty:
		GameSettings.Difficulty.EASY:
			return _choose_easy(board, ai_player)
		GameSettings.Difficulty.MEDIUM:
			return _choose_medium(board, ai_player)
		_:
			return _choose_hard(board, ai_player)

func _choose_easy(board: Board, ai_player: String) -> int:
	var opponent := _other_player(ai_player)
	var winning_move := _find_immediate_win(board, ai_player)
	if winning_move != -1:
		return winning_move
	if randi() % 5 == 0:
		var block_move := _find_immediate_win(board, opponent)
		if block_move != -1:
			return block_move
	return _random_move(board)

func _choose_medium(board: Board, ai_player: String) -> int:
	var opponent := _other_player(ai_player)
	var winning_move := _find_immediate_win(board, ai_player)
	if winning_move != -1:
		return winning_move
	if randi() % 3 == 0:
		var block_move := _find_immediate_win(board, opponent)
		if block_move != -1:
			return block_move
	var depth := 3
	return _minimax_move(board, ai_player, depth, true)

func _choose_hard(board: Board, ai_player: String) -> int:
	return _minimax_move(board, ai_player, 9, false)

func _minimax_move(board: Board, ai_player: String, depth: int, allow_random: bool) -> int:
	var best_score := -1000
	var best_moves: Array[int] = []
	var cells := board.get_cells_copy()
	for move in board.get_available_moves():
		cells[move] = ai_player
		var score := _minimax(cells, depth - 1, false, ai_player, -1000, 1000)
		cells[move] = ""
		if score > best_score:
			best_score = score
			best_moves = [move]
		elif score == best_score:
			best_moves.append(move)
	if best_moves.is_empty():
		return _random_move(board)
	if allow_random and best_moves.size() > 1 and randi() % 3 == 0:
		return best_moves[randi() % best_moves.size()]
	return best_moves[0]

func _minimax(cells: Array[String], depth: int, is_maximizing: bool, ai_player: String, alpha: int, beta: int) -> int:
	var winner := _evaluate_winner(cells)
	if winner != "":
		if winner == "draw":
			return 0
		return 10 if winner == ai_player else -10
	if depth <= 0:
		return 0
	var current_player := ai_player if is_maximizing else _other_player(ai_player)
	var best_score := -1000 if is_maximizing else 1000
	for i in range(9):
		if cells[i] == "":
			cells[i] = current_player
			var score := _minimax(cells, depth - 1, not is_maximizing, ai_player, alpha, beta)
			cells[i] = ""
			if is_maximizing:
				best_score = max(best_score, score)
				alpha = max(alpha, best_score)
				if beta <= alpha:
					break
			else:
				best_score = min(best_score, score)
				beta = min(beta, best_score)
				if beta <= alpha:
					break
	return best_score

func _evaluate_winner(cells: Array[String]) -> String:
	var lines := [
		[0, 1, 2],
		[3, 4, 5],
		[6, 7, 8],
		[0, 3, 6],
		[1, 4, 7],
		[2, 5, 8],
		[0, 4, 8],
		[2, 4, 6]
	]
	for line in lines:
		var a := cells[line[0]]
		var b := cells[line[1]]
		var c := cells[line[2]]
		if a != "" and a == b and b == c:
			return a
	for i in range(9):
		if cells[i] == "":
			return ""
	return "draw"

func _find_immediate_win(board: Board, player: String) -> int:
	var cells := board.get_cells_copy()
	for move in board.get_available_moves():
		cells[move] = player
		if _evaluate_winner(cells) == player:
			return move
		cells[move] = ""
	return -1

func _random_move(board: Board) -> int:
	var moves := board.get_available_moves()
	if moves.is_empty():
		return -1
	return moves[randi() % moves.size()]

func _other_player(player: String) -> String:
	return "O" if player == "X" else "X"
