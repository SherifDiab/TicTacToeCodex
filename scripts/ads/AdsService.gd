class_name AdsService
extends Node

const AdsServiceFactory = preload("res://scripts/ads/AdsServiceFactory.gd")

var _service: IAdsService

func _ready() -> void:
	_service = AdsServiceFactory.create_service()
	_service.initialize()

func show_banner(position := "bottom") -> void:
	_service.show_banner(position)

func hide_banner() -> void:
	_service.hide_banner()

func load_rewarded(ad_unit_key := "rewarded") -> void:
	_service.load_rewarded(ad_unit_key)

func is_rewarded_ready() -> bool:
	return _service.is_rewarded_ready()

func show_rewarded(on_reward: Callable, on_fail: Callable) -> void:
	_service.show_rewarded(on_reward, on_fail)

func request_consent_if_required(on_done: Callable) -> void:
	_service.request_consent_if_required(on_done)
