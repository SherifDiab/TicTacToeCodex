class_name AdsServiceFactory
extends Node

const AdMobAdsService = preload("res://scripts/ads/AdMobAdsService.gd")
const NullAdsService = preload("res://scripts/ads/NullAdsService.gd")

static func create_service() -> IAdsService:
	if OS.has_feature("android"):
		return AdMobAdsService.new()
	return NullAdsService.new()
