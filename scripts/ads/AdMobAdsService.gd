class_name AdMobAdsService
extends IAdsService

const AdsConfig = preload("res://config/ads_config.gd")

const _SINGLETON_NAMES := ["AdMob", "GodotAdMob", "PoingAdMob"]

var _admob: Object
var _rewarded_ready := false
var _pending_reward: Callable
var _pending_fail: Callable

func initialize() -> void:
	if not OS.has_feature("android"):
		return
	_admob = _resolve_singleton()
	if _admob == null:
		push_warning("AdMob plugin singleton not found. Ads disabled.")
		return
	if _admob.has_method("set_app_id"):
		_admob.call("set_app_id", AdsConfig.ADMOB_APP_ID)
	if _admob.has_method("initialize"):
		_admob.call("initialize")
	elif _admob.has_method("init"):
		_admob.call("init")
	_connect_signals()

func show_banner(position := "bottom") -> void:
	if _admob == null:
		return
	if _admob.has_method("load_banner"):
		_admob.call("load_banner", AdsConfig.BANNER_AD_UNIT_ID, position)
	elif _admob.has_method("load_banner_ad"):
		_admob.call("load_banner_ad", AdsConfig.BANNER_AD_UNIT_ID, position)
	if _admob.has_method("show_banner"):
		_admob.call("show_banner")
	elif _admob.has_method("show_banner_ad"):
		_admob.call("show_banner_ad")

func hide_banner() -> void:
	if _admob == null:
		return
	if _admob.has_method("hide_banner"):
		_admob.call("hide_banner")
	elif _admob.has_method("hide_banner_ad"):
		_admob.call("hide_banner_ad")

func load_rewarded(ad_unit_key := "rewarded") -> void:
	if _admob == null:
		return
	_rewarded_ready = false
	if _admob.has_method("load_rewarded"):
		_admob.call("load_rewarded", AdsConfig.REWARDED_AD_UNIT_ID)
	elif _admob.has_method("load_rewarded_ad"):
		_admob.call("load_rewarded_ad", AdsConfig.REWARDED_AD_UNIT_ID)

func is_rewarded_ready() -> bool:
	return _rewarded_ready

func show_rewarded(on_reward: Callable, on_fail: Callable) -> void:
	if _admob == null:
		if on_fail.is_valid():
			on_fail.call()
		return
	_pending_reward = on_reward
	_pending_fail = on_fail
	if _admob.has_method("show_rewarded"):
		_admob.call("show_rewarded")
	elif _admob.has_method("show_rewarded_ad"):
		_admob.call("show_rewarded_ad")
	else:
		if on_fail.is_valid():
			on_fail.call()

func request_consent_if_required(on_done: Callable) -> void:
	if _admob == null:
		if on_done.is_valid():
			on_done.call()
		return
	if _admob.has_method("request_consent_if_required"):
		_admob.call("request_consent_if_required", on_done)
	elif _admob.has_method("request_consent_info_update"):
		_admob.call("request_consent_info_update", on_done)
	else:
		if on_done.is_valid():
			on_done.call()

func _resolve_singleton() -> Object:
	for name in _SINGLETON_NAMES:
		if Engine.has_singleton(name):
			return Engine.get_singleton(name)
	return null

func _connect_signals() -> void:
	if _admob == null:
		return
	if _admob.has_signal("rewarded_ad_loaded"):
		_admob.connect("rewarded_ad_loaded", Callable(self, "_on_rewarded_loaded"))
	if _admob.has_signal("rewarded_ad_failed_to_load"):
		_admob.connect("rewarded_ad_failed_to_load", Callable(self, "_on_rewarded_failed_to_load"))
	if _admob.has_signal("rewarded_ad_user_earned_reward"):
		_admob.connect("rewarded_ad_user_earned_reward", Callable(self, "_on_rewarded_earned"))
	if _admob.has_signal("rewarded_ad_failed_to_show"):
		_admob.connect("rewarded_ad_failed_to_show", Callable(self, "_on_rewarded_failed_to_show"))
	if _admob.has_signal("rewarded_ad_closed"):
		_admob.connect("rewarded_ad_closed", Callable(self, "_on_rewarded_closed"))

func _on_rewarded_loaded() -> void:
	_rewarded_ready = true

func _on_rewarded_failed_to_load(_error := 0) -> void:
	_rewarded_ready = false
	if _pending_fail.is_valid():
		_pending_fail.call()

func _on_rewarded_failed_to_show(_error := 0) -> void:
	_rewarded_ready = false
	if _pending_fail.is_valid():
		_pending_fail.call()

func _on_rewarded_earned() -> void:
	_rewarded_ready = false
	if _pending_reward.is_valid():
		_pending_reward.call()

func _on_rewarded_closed() -> void:
	_pending_reward = Callable()
	_pending_fail = Callable()
