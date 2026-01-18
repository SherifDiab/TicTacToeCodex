class_name StatsStore
extends Node

const _SAVE_PATH := "user://stats.cfg"

var wins := 0
var losses := 0
var draws := 0

func _ready() -> void:
	load_stats()

func load_stats() -> void:
	var config := ConfigFile.new()
	if config.load(_SAVE_PATH) == OK:
		wins = int(config.get_value("stats", "wins", 0))
		losses = int(config.get_value("stats", "losses", 0))
		draws = int(config.get_value("stats", "draws", 0))
	else:
		wins = 0
		losses = 0
		draws = 0

func save_stats() -> void:
	var config := ConfigFile.new()
	config.set_value("stats", "wins", wins)
	config.set_value("stats", "losses", losses)
	config.set_value("stats", "draws", draws)
	config.save(_SAVE_PATH)

func record_result(result: String) -> void:
	match result:
		"win":
			wins += 1
		"loss":
			losses += 1
		"draw":
			draws += 1
	save_stats()

func reset_stats() -> void:
	wins = 0
	losses = 0
	draws = 0
	save_stats()
