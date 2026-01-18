class_name Board
extends RefCounted

var cells: Array[String] = []
var move_stack: Array[Dictionary] = []

func _init() -> void:
	reset()

func reset() -> void:
	cells = []
	for i in range(9):
		cells.append("")
	move_stack.clear()

func get_cell(index: int) -> String:
	return cells[index]

func is_move_legal(index: int) -> bool:
	return index >= 0 and index < 9 and cells[index] == ""

func apply_move(index: int, player: String) -> bool:
	if not is_move_legal(index):
		return false
	cells[index] = player
	move_stack.append({"index": index, "player": player})
	return true

func undo_last_move() -> Dictionary:
	if move_stack.is_empty():
		return {}
	var last_move := move_stack.pop_back()
	cells[last_move["index"]] = ""
	return last_move

func get_available_moves() -> Array[int]:
	var moves: Array[int] = []
	for i in range(9):
		if cells[i] == "":
			moves.append(i)
	return moves

func get_winner() -> Dictionary:
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
			return {"winner": a, "line": line}
	if get_available_moves().is_empty():
		return {"winner": "draw", "line": []}
	return {"winner": "", "line": []}

func get_cells_copy() -> Array[String]:
	return cells.duplicate()
