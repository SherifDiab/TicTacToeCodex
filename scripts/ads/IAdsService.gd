class_name IAdsService
extends RefCounted

func initialize() -> void:
	pass

func show_banner(position := "bottom") -> void:
	pass

func hide_banner() -> void:
	pass

func load_rewarded(ad_unit_key := "rewarded") -> void:
	pass

func is_rewarded_ready() -> bool:
	return false

func show_rewarded(on_reward: Callable, on_fail: Callable) -> void:
	pass

func request_consent_if_required(on_done: Callable) -> void:
	if on_done.is_valid():
		on_done.call()
